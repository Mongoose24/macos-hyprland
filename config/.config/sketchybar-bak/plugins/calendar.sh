#argdo setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2 | retab! | normal! gg=G | update!/bin/bash

sketchybar --set "$NAME" label="$(date +'%I:%M %p  -  %m/%d/%y')"
