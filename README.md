# macos-hyprland

Yabai, SKHD, and SketchyBar configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

From this repository:

```bash
chmod +x init.sh watch.sh
./init.sh
```

The old `homebrew/cask-fonts` tap is intentionally not listed because current Homebrew rejects it as deprecated; the font casks are available without that tap.

`init.sh` will:

1. Install Homebrew if it is unavailable.
2. Install the dependencies listed in `Brewfile`.
3. Remove the existing managed paths:
   - `~/.config/yabai`
   - `~/.config/sketchybar`
   - `~/.skhdrc`
4. Stow the `config` package into `$HOME`.
5. Start SketchyBar with `brew services` and start yabai/skhd with their native LaunchAgent commands when their Homebrew formulae do not provide service definitions.

The managed paths are intentionally removed to eliminate Stow conflicts, including the old testing `~/.config/yabai/.skhdrc`. Do not run `init.sh` if those paths contain unrelated files you need to keep.

## Watch for changes

Run the watcher manually from the repository root:

```bash
./watch.sh
```

The watcher observes only the grouped `config/` package, never the symlinked destination directories. It restows the package and restarts only the service affected by a change:

| Changed package | Action |
| --- | --- |
| `config/.config/yabai/` | Restow and restart yabai |
| `config/.skhdrc` | Restow and restart skhd |
| `config/.config/sketchybar/` | Restow and restart SketchyBar |

The yabai and skhd Homebrew formulae currently do not expose Homebrew service definitions, so the scripts use `yabai --start-service` / `skhd --start-service` and their corresponding restart commands for those two services.

Press `Ctrl-C` to stop it. No login LaunchAgent is installed for the watcher.

## Repository layout

```text
├── Brewfile
├── init.sh
├── watch.sh
└── config/
    ├── .skhdrc
    └── .config/
        ├── yabai/yabairc
        └── sketchybar/
```

Yabai Accessibility/Scripting Addition permissions remain macOS-level prerequisites and are not configured by this repository.
