#!/bin/bash

# Keep reloads idempotent if the item already exists.
sketchybar --remove memory >/dev/null 2>&1 || true

memory=(
  update_freq=2
  updates=on
  icon=􀫦
  icon.font="$FONT:Bold:14.0"
  script="$PLUGIN_DIR/memory.sh"
)

sketchybar --add item memory right \
           --set memory "${memory[@]}"
