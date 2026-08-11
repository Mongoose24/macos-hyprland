#argdo setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2 | retab! | normal! gg=G | update!/bin/sh

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

source "$CONFIG_DIR/colors.sh"

if [ "$SELECTED" = true ]; then
  sketchybar --set "$NAME"                          \
    background.drawing=on                           \
    background.color="$ACCENT_COLOR"                \
    background.corner_radius=100                    \
    background.height=24                            \
    icon.color="$BAR_TEXT_COLOR"                         \
    label.color="$BAR_TEXT_COLOR"
else
  sketchybar --set "$NAME"                          \
    background.drawing=off                          \
    icon.color="$ACCENT_COLOR"                      \
    label.color="$ACCENT_COLOR"
fi
