#argdo setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2 | retab! | normal! gg=G | update!/bin/bash

sketchybar --add item volume right \
--set volume script="$PLUGIN_DIR/volume.sh" \
--subscribe volume volume_change 
