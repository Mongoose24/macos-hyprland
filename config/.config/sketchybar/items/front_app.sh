#!/bin/bash
#argdo setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2 | retab! | normal! gg=G | update!/bin/bash

sketchybar --add item front_app left \
           --set front_app \
             drawing=on \
             padding_left=1 \
             padding_right=1 \
             background.drawing=on \
             background.color="$ACCENT_COLOR" \
             icon.drawing=on \
             icon.color="$BAR_COLOR" \
             icon.font="sketchybar-app-font:Regular:12.0" \
             label.drawing=on \
             label.color="$BAR_COLOR" \
             script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched
