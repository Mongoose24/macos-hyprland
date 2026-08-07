#!/usr/bin/env bash
set -uo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEBOUNCE_SECONDS="${DEBOUNCE_SECONDS:-0.25}"

YABAI_DIR="$REPO_DIR/yabai"
SKHD_DIR="$REPO_DIR/skhd"
SKETCHYBAR_DIR="$REPO_DIR/sketchybar"

log() {
  printf '[watch] %s\n' "$*"
}

fail() {
  printf '[watch] ERROR: %s\n' "$*" >&2
  exit 1
}

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

restow_and_restart() {
  local package="$1"
  local service="$2"

  log "Stowing $package..."
  if ! (cd "$REPO_DIR" && stow --target="$HOME" --restow "$package"); then
    log "Stow failed for $package; leaving $service unchanged."
    return
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

  sleep "$DEBOUNCE_SECONDS"

  # Drain events already queued during the debounce window.
  while IFS= read -r -d '' -t 0 queued_path; do
    classify_path "$queued_path"
  done

  (( needs_yabai )) && restow_and_restart yabai yabai
  (( needs_skhd )) && restow_and_restart skhd skhd
  (( needs_sketchybar )) && restow_and_restart sketchybar sketchybar
 done
