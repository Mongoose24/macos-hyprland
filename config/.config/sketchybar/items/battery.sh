#argdo setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2 | retab! | normal! gg=G | update!/bin/bash

sketchybar --add item battery right \
--set battery update_freq=120 \
script="$PLUGIN_DIR/battery.sh" \
--subscribe battery system_woke power_source_change
