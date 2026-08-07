#argdo setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2 | retab! | normal! gg=G | update!/bin/bash

sketchybar --add item calendar center \
--set calendar icon=􀧞  \
update_freq=30 \
script="$PLUGIN_DIR/calendar.sh"
