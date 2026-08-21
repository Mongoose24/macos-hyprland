#!/bin/bash

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected.
source "$CONFIG_DIR/colors.sh"

update() {
  if [ "$SELECTED" = true ]; then
    sketchybar --set "$NAME" \
      background.drawing=on \
      background.color="$PEACH" \
      background.corner_radius=100 \
      background.height=24 \
      icon.color="$BAR_TEXT_COLOR" \
      label.color="$BAR_TEXT_COLOR"
  else
    sketchybar --set "$NAME" \
      background.drawing=off \
      icon.color="$PEACH" \
      label.color="$ACCENT_COLOR"
  fi
}

mouse_clicked() {
  # Keep the normal left-click behaviour useful even when yabai's scripting
  # addition is unavailable.  Right-click removes a space, matching the
  # original space component behaviour.
  if [ "$BUTTON" = right ]; then
    yabai -m space --destroy "$SID" 2>/dev/null || return 0
  else
    yabai -m space --focus "$SID" 2>/dev/null || return 0
  fi

  # Yabai normally emits these signals itself; explicitly triggering them
  # also keeps labels correct with older yabai/macOS notification paths.
  sketchybar --trigger space_change --trigger windows_on_spaces
}

case "$SENDER" in
  mouse.clicked) mouse_clicked ;;
  *) update ;;
esac
