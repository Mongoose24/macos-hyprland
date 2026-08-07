#!/usr/bin/env bash
set -uo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEBOUNCE_SECONDS="${DEBOUNCE_SECONDS:-0.25}"

CONFIG_DIR="$REPO_DIR/config"
YABAI_DIR="$CONFIG_DIR/.config/yabai"
SKHD_DIR="$CONFIG_DIR/.skhdrc"
SKETCHYBAR_DIR="$CONFIG_DIR/.config/sketchybar"

log() {
  printf '[watch] %s\n' "$*"
}

fail() {
  printf '[watch] ERROR: %s\n' "$*" >&2
  exit 1
}

# macOS ships Bash 3.2, whose `read -t` only accepts whole seconds.
# Round the configured debounce interval up for the quiet-period read.
DEBOUNCE_TIMEOUT="$(awk -v value="$DEBOUNCE_SECONDS" 'BEGIN {
  if (value !~ /^[0-9]+([.][0-9]+)?$/) exit 1
  value = int(value + 0.999999)
  if (value < 1) value = 1
  print value
}')" || fail "DEBOUNCE_SECONDS must be a non-negative number."

command -v fswatch >/dev/null 2>&1 || fail "fswatch is required. Run ./init.sh first."
command -v stow >/dev/null 2>&1 || fail "GNU Stow is required. Run ./init.sh first."
command -v brew >/dev/null 2>&1 || fail "Homebrew is required. Run ./init.sh first."

classify_path() {
  local changed_path="$1"

  case "$changed_path" in
    "$YABAI_DIR"|"$YABAI_DIR"/*)
      needs_yabai=1
      ;;
    "$SKHD_DIR"|"$SKHD_DIR"/*)
      needs_skhd=1
      ;;
    "$SKETCHYBAR_DIR"|"$SKETCHYBAR_DIR"/*)
      needs_sketchybar=1
      ;;
  esac
}

restart_service() {
  local service="$1"

  case "$service" in
    yabai|skhd)
      # These formulae do not provide Homebrew service definitions; their
      # native commands manage their user LaunchAgents.
      "$service" --restart-service
      ;;
    sketchybar)
      brew services restart sketchybar
      ;;
    *)
      log "Unknown service: $service"
      return 1
      ;;
  esac
}

stow_target() {
  local service="$1"

  case "$service" in
    yabai) printf '%s\n' "$HOME/.config/yabai" ;;
    skhd) printf '%s\n' "$HOME/.skhdrc" ;;
    sketchybar) printf '%s\n' "$HOME/.config/sketchybar" ;;
    *) return 1 ;;
  esac
}

restow_needed() {
  local service="$1"
  local target
  target="$(stow_target "$service")" || return 0

  # Stow creates symlinks for these package roots. Once the root link exists,
  # edits and new files below it are immediately visible without restowing.
  [[ ! -L "$target" || ! -e "$target" ]]
}

restow_and_restart() {
  local package="$1"
  local service="$2"

  if restow_needed "$service"; then
    log "Stowing $package (package link missing)..."
    if ! (cd "$REPO_DIR" && stow --target="$HOME" --restow "$package"); then
      log "Stow failed for $package; leaving $service unchanged."
      return
    fi
  fi

  log "Restarting $service..."
  if ! restart_service "$service"; then
    log "Unable to restart $service; inspect service status/logs."
  fi
}

cleanup() {
  log "Stopped."
}
trap cleanup INT TERM EXIT

log "Watching $REPO_DIR (press Ctrl-C to stop)..."

# NUL-delimited paths handle spaces safely. Events are coalesced manually so
# editor save sequences cause one restow/restart per affected service.
fswatch --print0 --latency 0.10 "$YABAI_DIR" "$SKHD_DIR" "$SKETCHYBAR_DIR" |
while IFS= read -r -d '' changed_path; do
  needs_yabai=0
  needs_skhd=0
  needs_sketchybar=0
  classify_path "$changed_path"

  # Keep collecting events until the filesystem has been quiet for the
  # debounce interval. This handles editor save sequences whose events are
  # spread out over multiple reads (temporary file, rename, chmod, etc.).
  while IFS= read -r -d '' -t "$DEBOUNCE_TIMEOUT" queued_path; do
    classify_path "$queued_path"
  done

  (( needs_yabai )) && restow_and_restart config yabai
  (( needs_skhd )) && restow_and_restart config skhd
  (( needs_sketchybar )) && restow_and_restart config sketchybar
 done
