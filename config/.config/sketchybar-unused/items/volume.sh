#!/bin/bash

volume_slider=(
  # Keep the slider item for volume-change updates, but hide its visual bar.
  drawing=off
  script="$PLUGIN_DIR/volume.sh"
  updates=on
  label.drawing=off
  icon.drawing=off
  slider.highlight_color=$ACCENT_COLOR
  slider.background.height=5
  slider.background.corner_radius=3
  slider.background.color=$BACKGROUND_2
  slider.knob=􀀁
  slider.knob.drawing=off
)

volume_icon=(
  click_script="$PLUGIN_DIR/volume_click.sh"
  padding_left=10
  padding_right=8
  icon=$VOLUME_100
  icon.width=0
  icon.align=left
  icon.color=$ACCENT_COLOR
  icon.font="$FONT:Regular:14.0"
  label.width=25
  label.align=left
  label.color=$ACCENT_COLOR
  label.font="$FONT:Regular:14.0"
)

# Remove the legacy right-side island if it survived a config reload.
sketchybar --remove status >/dev/null 2>&1 || true

sketchybar --add slider volume right            \
           --set volume "${volume_slider[@]}"   \
           --subscribe volume volume_change     \
                              mouse.clicked     \
                              mouse.entered     \
                              mouse.exited      \
                                                \
           --add item volume_icon right         \
           --set volume_icon "${volume_icon[@]}"
