#!/bin/bash

if [ "$SENDER" = "space_windows_change" ]; then
  space="$(echo "$INFO" | jq -r '.space')"
  apps="$(echo "$INFO" | jq -r '.apps | keys[]')"

  if [ -z "$apps" ]; then
    sketchybar --set "space.$space" \
      label="" \
      drawing=off
    exit 0
  fi

  icon_strip=""

  while read -r app; do
    icon_strip+=" $("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app")"
  done <<< "$apps"

  sketchybar --set "space.$space" \
    label="$icon_strip" \
    drawing=on
fi
