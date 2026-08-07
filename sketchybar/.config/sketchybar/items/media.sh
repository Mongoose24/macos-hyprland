#!/bin/bash

sketchybar --add item media right \
           --set media \
             drawing=off \
             label.color="$BAR_COLOR" \
             label.max_chars=20 \
             label.padding_right=7 \
             icon="􀑪" \
             icon.color="$BAR_COLOR" \
             icon.padding_left=7 \
             icon.padding_right=3 \
             scroll_texts=on \
             background.drawing=on \
             background.color="$ACCENT_COLOR" \
             background.corner_radius=100 \
             background.height=24
