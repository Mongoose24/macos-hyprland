#!/bin/bash

SPACE_SIDS=(1 2 3 4 5 6 7 8 9 10)

# Refresh the selected-space styling whenever Mission Control/yabai changes
# spaces. Keep subscriptions separate for compatibility with older builds.
for sid in "${SPACE_SIDS[@]}"
do
  sketchybar --add space space.$sid left \
    --set space.$sid associated_space=$sid \
      icon=$sid \
      padding_left=8 \
      padding_right=8 \
      label.font="sketchybar-app-font:Regular:14.0" \
      label.color=$PEACH \
      label.padding_right=11 \
      label.y_offset=-1 \
      script="$PLUGIN_DIR/space.sh"
  sketchybar --subscribe space.$sid mouse.clicked
  sketchybar --subscribe space.$sid space_change
  sketchybar --subscribe space.$sid display_change
done

# The separator is intentionally a plain item (the old space_windows.sh
# helper was removed; yabai.sh now updates each space's app-icon label).
sketchybar --add item space_separator left \
  --set space_separator icon="􀆊" \
    icon.color=$PEACH \
    icon.padding_left=2 \
    label.drawing=off \
    background.drawing=off \
    click_script='yabai -m space --create && sketchybar --trigger space_change --trigger windows_on_spaces'
