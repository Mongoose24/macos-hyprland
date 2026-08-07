#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

: "${SKETCHYBAR_PID:?SketchyBar PID was not provided}"

MEDIA_CONTROL="$(command -v media-control)"
SKETCHYBAR="$(command -v sketchybar)"

if [[ -z "$MEDIA_CONTROL" || -z "$SKETCHYBAR" ]]; then
  echo "media-control or sketchybar not found" >&2
  exit 1
fi

cleanup() {
  kill "$MONITOR_PID" 2>/dev/null
}
trap cleanup EXIT INT TERM

# Exit when the SketchyBar process that started this watcher exits.
(
  while kill -0 "$SKETCHYBAR_PID" 2>/dev/null; do
    sleep 5
  done

  kill "$$"
) &
MONITOR_PID=$!

last_label=""
last_playing=""

"$MEDIA_CONTROL" stream --no-diff --no-artwork |
while IFS= read -r line; do
  playing="$(jq -r '.payload.playing // false' <<< "$line")"
  title="$(jq -r '.payload.title // empty' <<< "$line")"
  artist="$(jq -r '.payload.artist // empty' <<< "$line")"

  if [[ "$playing" == "true" && -n "$title" ]]; then
    if [[ -n "$artist" ]]; then
      label="$title - $artist"
    else
      label="$title"
    fi

    if [[ "$label" != "$last_label" || "$playing" != "$last_playing" ]]; then
      "$SKETCHYBAR" --set media \
        label="$label" \
        drawing=on \
        background.drawing=on

      last_label="$label"
      last_playing="$playing"
    fi
  else
    if [[ "$last_playing" != "false" ]]; then
      "$SKETCHYBAR" --set media drawing=off
      last_playing="false"
      last_label=""
    fi
  fi
done
