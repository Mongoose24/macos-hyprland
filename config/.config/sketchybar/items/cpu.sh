#argdo setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2 | retab! | normal! gg=G | update!/bin/bash

sketchybar --add item cpu right \
--set cpu  update_freq=2 \
icon=􀧓  \
script="$PLUGIN_DIR/cpu.sh"
