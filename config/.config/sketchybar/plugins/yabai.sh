#!/bin/bash

# SketchyBar does not export the variables from sketchybarrc to scripts that
# are started later by an event.  Keep the config path available for dynamic
# space creation and make this script safe to invoke directly.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

space_item_exists() {
  sketchybar --query "space.$1" >/dev/null 2>&1
}

ensure_space_item() {
  local sid="$1"
  space_item_exists "$sid" && return 0

  sketchybar --add space "space.$sid" left \
    --set "space.$sid" \
      associated_space="$sid" \
      icon="$sid" \
      padding_left=8 \
      padding_right=8 \
      label.font="sketchybar-app-font:Regular:14.0" \
      label.color="$ACCENT_COLOR" \
      label.padding_right=11 \
      label.y_offset=-1 \
      script="$CONFIG_DIR/plugins/space.sh"
  sketchybar --subscribe "space.$sid" mouse.clicked
  sketchybar --subscribe "space.$sid" space_change
  sketchybar --subscribe "space.$sid" display_change
}

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
  local sid apps icon_strip app windows_json
  local max_sid
  max_sid=$(jq -r 'map(.index) | max // 0' <<< "$spaces_json" 2>/dev/null)
  # Keep the ten spaces configured by items/spaces.sh, while also adding any
  # desktop created beyond that range.  Space indices are reused by yabai, so
  # stale items are simply hidden below when they no longer exist.
  [ "$max_sid" -lt 10 ] 2>/dev/null && max_sid=10

  for sid in $(seq 1 "$max_sid"); do
    ensure_space_item "$sid"
    if ! jq -e --argjson sid "$sid" 'any(.[]; .index == $sid)' <<< "$spaces_json" >/dev/null; then
      args+=(--set "space.$sid" drawing=off label.drawing=off label="")
      continue
    fi

    # Ignore hidden utility windows (for example ServicesUIAgent) and keep
    # one icon per real application. Inactive spaces report normal windows
    # as is-visible=false, so do not filter on that field. If the query fails
    # (for example while Accessibility is being re-authorized), leave the
    # previous label untouched instead of hiding every space.
    windows_json=$(yabai -m query --windows --space "$sid" 2>/dev/null) || continue
    apps=$(jq -r '
      map(select(
        .app != null and .app != "" and
        .["is-hidden"] != true and
        .["is-minimized"] != true
      ) | .app) | unique[]
    ' <<< "$windows_json" 2>/dev/null) || continue
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

  # Also clear dynamically-created items whose spaces were removed and whose
  # indices are now above yabai's current maximum.
  while IFS= read -r configured_sid; do
    [ -n "$configured_sid" ] || continue
    if ! jq -e --argjson sid "$configured_sid" 'any(.[]; .index == $sid)' <<< "$spaces_json" >/dev/null; then
      args+=(--set "space.$configured_sid" drawing=off label.drawing=off label="")
    fi
  done < <(sketchybar --query bar 2>/dev/null | jq -r '.items[] | select(startswith("space.")) | sub("^space\\."; "")' 2>/dev/null)

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
  "windows_on_spaces"|"space_change"|"display_change"|"front_app_switched") windows_on_spaces
  ;;
esac
