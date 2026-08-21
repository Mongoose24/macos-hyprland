#!/bin/bash

FRONT_APP_SCRIPT='sketchybar --set "$NAME" label="$INFO" icon="$($HOME/.config/sketchybar/plugins/icon_map.sh "$INFO")"'

# This helper is intentionally non-visual, but must remain drawable so
# SketchyBar dispatches its subscribed events. The global default is
# updates=when_shown, which otherwise makes space labels stale until reload.
yabai=(
  drawing=on
  icon.drawing=off
  label.drawing=off
  # Keep a one-pixel drawable item; fully hidden items do not receive events.
  width=1
  padding_left=0
  padding_right=0
  script="$PLUGIN_DIR/yabai.sh"
  associated_display=active
)

front_app=(
  script="$FRONT_APP_SCRIPT"
  icon.drawing=on
  icon.font="sketchybar-app-font:Regular:16.0"
  icon.width=24
  padding_left=0
  label.color=$BLUE
  label.font="$FONT:Black:12.0"
  associated_display=active
)

# Recreate this event-only helper on reload; an item created with drawing=off
# can retain stale event-dispatch state across SketchyBar reloads.
sketchybar --remove yabai >/dev/null 2>&1 || true
sketchybar --add event window_focus
sketchybar --add event windows_on_spaces
sketchybar --add event display_change
sketchybar --add item yabai left
sketchybar --set yabai "${yabai[@]}"

# Keep these as separate commands. This avoids older SketchyBar builds
# treating the arguments after the first event as positional options.
sketchybar --subscribe yabai window_focus
sketchybar --subscribe yabai windows_on_spaces
sketchybar --subscribe yabai space_change
sketchybar --subscribe yabai display_change
sketchybar --subscribe yabai front_app_switched
sketchybar --subscribe yabai mouse.clicked

sketchybar --add item front_app left
sketchybar --set front_app "${front_app[@]}"
sketchybar --subscribe front_app front_app_switched
