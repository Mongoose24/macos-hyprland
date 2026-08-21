#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

# Homebrew expects a real terminal type when checking cask metadata.
export TERM=xterm-256color
export HOMEBREW_NO_AUTO_UPDATE=1

# SketchyBar may run outside the shell environment where Homebrew is on PATH.
BREW_BIN=/opt/homebrew/bin/brew
if [[ ! -x "$BREW_BIN" ]]; then
  BREW_BIN=/usr/local/bin/brew
fi
if [[ ! -x "$BREW_BIN" ]]; then
  BREW_BIN=$(command -v brew 2>/dev/null || true)
fi

if [[ -z "$BREW_BIN" || ! -x "$BREW_BIN" ]]; then
  sketchybar --set "$NAME" label="?" icon.color="$YELLOW"
  exit 0
fi

# Check formulae here: cask checks can spawn child processes that conflict
# with SketchyBar's process handling. Retry briefly if Brew is still locked
# after an update or install.
BREW_OK=0
for attempt in 1 2 3; do
  if OUTDATED=$("$BREW_BIN" outdated --formula 2>/dev/null); then
    BREW_OK=1
    break
  fi
  sleep 1
done

if [[ "$BREW_OK" -eq 0 ]]; then
  sketchybar --set "$NAME" label="?" icon.color="$YELLOW"
  exit 0
fi

COUNT=$(printf '%s\n' "$OUTDATED" | awk 'NF { count++ } END { print count + 0 }')

COLOR=$RED

case "$COUNT" in
  [3-5][0-9]) COLOR=$ORANGE
  ;;
  [1-2][0-9]) COLOR=$YELLOW
  ;;
  [1-9]) COLOR=$WHITE
  ;;
  0) COLOR=$GREEN
     COUNT=􀆅
  ;;
esac

sketchybar --set "$NAME" label="$COUNT" icon.color="$COLOR"
