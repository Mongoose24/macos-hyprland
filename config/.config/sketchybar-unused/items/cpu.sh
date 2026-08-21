#!/bin/bash

# Remove the graph-based CPU items from the previous configuration on reload.
for item in cpu.top cpu.percent cpu.sys cpu.user; do
  sketchybar --remove "$item" >/dev/null 2>&1 || true
done

sketchybar --add item cpu right \
           --set cpu update_freq=2 \
                     updates=on \
                     icon=􀧓 \
                     icon.color=$BLUE \
                     label.color=$BLUE \
                     script="$PLUGIN_DIR/cpu.sh"
