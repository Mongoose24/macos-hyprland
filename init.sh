#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME:?HOME must be set}"
BREWFILE="$REPO_DIR/Brewfile"

log() {
  printf '[init] %s\n' "$*"
}

fail() {
  printf '[init] ERROR: %s\n' "$*" >&2
  exit 1
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  fail "This setup is intended for macOS."
fi

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  log "Homebrew not found; running the official installer..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    fail "Homebrew installation completed, but brew could not be located."
  fi
}

ensure_brew
[[ -f "$BREWFILE" ]] || fail "Missing $BREWFILE"

install_formula() {
  local formula="$1"
  if brew list --formula "$formula" >/dev/null 2>&1; then
    log "  formula already installed: $formula"
  else
    log "  installing formula: $formula"
    brew install "$formula"
  fi
}

install_cask() {
  local cask="$1"
  if brew list --cask "$cask" >/dev/null 2>&1; then
    log "  cask already installed: $cask"
  else
    log "  installing cask: $cask"
    brew install --cask "$cask"
  fi
}

log "Installing Homebrew dependencies..."
brew tap FelixKratz/formulae
for formula in stow yabai skhd fswatch jq nowplaying-cli media-control sketchybar; do
  install_formula "$formula"
done
for cask in font-hack-nerd-font font-sf-pro sf-symbols karabiner-elements; do
  install_cask "$cask"
done

command -v stow >/dev/null 2>&1 || fail "GNU Stow is not available after dependency installation."

# These are the managed destinations. They are intentionally removed so that
# Stow cannot encounter conflicts with old regular files or test symlinks.
managed_paths=(
  "$TARGET_HOME/.config/yabai"
  "$TARGET_HOME/.config/sketchybar"
  "$TARGET_HOME/.skhdrc"
)

log "Removing existing managed config paths..."
for path in "${managed_paths[@]}"; do
  if [[ -e "$path" || -L "$path" ]]; then
    log "  removing $path"
    rm -rf -- "$path"
  fi
done

log "Stowing the config package..."
cd "$REPO_DIR"
stow --target="$TARGET_HOME" config

log "Ensuring config scripts are executable..."
find "$REPO_DIR/config" \
  -type f \( -name '*.sh' -o -name 'yabairc' -o -name '.skhdrc' \) \
  -exec chmod +x {} +
chmod +x "$REPO_DIR/init.sh" "$REPO_DIR/watch.sh"

start_service() {
  local service="$1"

  # yabai and skhd currently do not ship Homebrew service definitions. Try
  # brew services first to honor the common interface, then use each tool's
  # native LaunchAgent command when Homebrew cannot start it.
  if brew services start "$service" >/dev/null 2>&1; then
    return
  fi

  case "$service" in
    yabai|skhd)
      log "  brew services has no $service definition; using $service --start-service"
      "$service" --start-service
      ;;
    *)
      fail "Unable to start $service with brew services."
      ;;
  esac
}

log "Starting yabai, skhd, and sketchybar services..."
start_service yabai
start_service skhd
start_service sketchybar

log "Setup complete. Run ./watch.sh to watch for configuration changes."
