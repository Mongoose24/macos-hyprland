#!/bin/bash

window_state() {
  source "$HOME/.config/sketchybar/colors.sh"
  source "$HOME/.config/sketchybar/icons.sh"

  WINDOW=$(yabai -m query --windows --window)
  CURRENT=$(echo "$WINDOW" | jq '.["stack-index"]' 2>/dev/null)

  args=()
  if [[ $CURRENT -gt 0 ]]; then
    LAST=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
    args+=(--set "$NAME" icon=$YABAI_STACK icon.color=$RED label.drawing=on label=$(printf "[%s/%s]" "$CURRENT" "$LAST"))
    yabai -m config active_window_border_color $RED > /dev/null 2>&1 &

  else
    args+=(--set "$NAME" label.drawing=off)
    case "$(echo "$WINDOW" | jq '.["is-floating"]')" in
      "false")
        if [ "$(echo "$WINDOW" | jq '.["has-fullscreen-zoom"]')" = "true" ]; then
          args+=(--set "$NAME" icon=$YABAI_FULLSCREEN_ZOOM icon.color=$GREEN)
          yabai -m config active_window_border_color $GREEN > /dev/null 2>&1 &
        elif [ "$(echo "$WINDOW" | jq '.["has-parent-zoom"]')" = "true" ]; then
          args+=(--set "$NAME" icon=$YABAI_PARENT_ZOOM icon.color=$BLUE)
          yabai -m config active_window_border_color $BLUE > /dev/null 2>&1 &
        else
          args+=(--set "$NAME" icon=$YABAI_GRID icon.color=$ORANGE)
          yabai -m config active_window_border_color $WHITE > /dev/null 2>&1 &
        fi
        ;;
      "true")
        args+=(--set "$NAME" icon=$YABAI_FLOAT icon.color=$MAGENTA)
        yabai -m config active_window_border_color $MAGENTA > /dev/null 2>&1 &
        ;;
    esac
  fi

  sketchybar -m "${args[@]}"
}

# Keep every space item in sync with yabai.  In particular, clear old labels
# and hide both configured-but-nonexistent and currently empty spaces.
windows_on_spaces() {
  local spaces_json
  spaces_json=$(yabai -m query --spaces 2>/dev/null) || return 0

  local args=()
  local sid apps icon_strip app
  for sid in {1..10}; do
    if ! jq -e --argjson sid "$sid" 'any(.[]; .index == $sid)' <<< "$spaces_json" >/dev/null; then
      args+=(--set "space.$sid" drawing=off label.drawing=off label="")
      continue
    fi

    # Ignore hidden utility windows (for example ServicesUIAgent) and keep
    # one icon per real application. Inactive spaces report normal windows
    # as is-visible=false, so do not filter on that field.
    apps=$(yabai -m query --windows --space "$sid" 2>/dev/null | jq -r '
      map(select(
        .app != null and .app != "" and
        .["is-hidden"] != true and
        .["is-minimized"] != true and
        .["has-ax-reference"] == true
      ) | .app) | unique[]
    ' 2>/dev/null)
    if [ -z "$apps" ]; then
      args+=(--set "space.$sid" drawing=off label.drawing=off label="")
      continue
    fi

    icon_strip=""
    while IFS= read -r app; do
      [ -n "$app" ] || continue
      icon_strip+=" $($HOME/.config/sketchybar/plugins/icon_map.sh "$app")"
    done <<< "$apps"
    args+=(--set "space.$sid" drawing=on label="$icon_strip" label.drawing=on)
  done

  [ "${#args[@]}" -gt 0 ] && sketchybar -m "${args[@]}"
}

mouse_clicked() {
  yabai -m window --toggle float
  window_state
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "forced") windows_on_spaces
  ;;
  "window_focus") window_state
  ;;
  "windows_on_spaces"|"space_change") windows_on_spaces
  ;;
esac
