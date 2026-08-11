#!/bin/bash

# Catppuccin Frappe palette
#
# WHITE is kept as a compatibility alias for TEXT.  It is not literal white;
# it is Catppuccin's light text color.
export ROSEWATER=0xfff2d5cf
export FLAMINGO=0xffeebebe
export PINK=0xfff4b8e4
export MAUVE=0xffca9ee6
export RED=0xffe78284
export MAROON=0xffea999c
export PEACH=0xffef9f76
export YELLOW=0xffe5c890
export GREEN=0xffa6d189
export TEAL=0xff81c8be
export SKY=0xff99d1db
export SAPPHIRE=0xff85c1dc
export BLUE=0xff8caaee
export LAVENDER=0xffbabbf1
export TEXT=0xffc6d0f5
export SUBTEXT1=0xffb5bfe2
export SUBTEXT0=0xffa5adce
export OVERLAY2=0xff949cbb
export OVERLAY1=0xff838ba7
export OVERLAY0=0xff737994
export SURFACE2=0xff626880
export SURFACE1=0xff51576d
export SURFACE0=0xff414559
export BASE=0xff303446
export MANTLE=0xff292c3c
export CRUST=0xff232634

# Compatibility alias used by the existing configuration. This is not
# literal white; it is the Catppuccin text color above.
export WHITE="$TEXT"

# -- Gray Scheme --
# Keep the bar background independent from foreground content. BAR_COLOR may
# be transparent; this color is intentionally always opaque.
export BAR_COLOR=0x800C0C0C
export BAR_TEXT_COLOR=0xff0C0C0C
export ITEM_BG_COLOR=0xff353c3f
export ACCENT_COLOR="$TEXT"
