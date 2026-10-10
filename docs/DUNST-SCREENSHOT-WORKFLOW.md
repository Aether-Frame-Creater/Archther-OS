# Dunst + Screenshot Workflow — Archther OS

## Dunst theme (`config/dunst/dunstrc`)

Standalone file for Dunst 1.13 (every key checked against the installed
reference; all colors quoted). Live path: `~/.config/dunst/dunstrc`
(previously absent — nothing was replaced).

- Geometry/behaviour: 300px wide, dynamic height, top-right, offset
  (10,50), limit 20, mouse/age/duplicate handling at stock defaults.
- Frame: 2px navy `#0B2A6F`; 8px corner radius; dark separator.
- Text: Adwaita Sans 10 (verified installed), bold-summary format.
- Urgencies: low = surface `#111827` + muted `#94A3B8`; normal = background
  `#0B0F14` + primary `#F8FAFC`; critical = same with **gold frame**
  `#E8A11C`, no timeout. Text tones are supporting colors, not brand tokens.

## Screenshot scripts (`scripts/`, installed to `~/.local/bin/`)

Bash, `set -Eeuo pipefail`, quoted throughout, no `eval`:

- `archther-screenshot-full`: verifies grim, ensures
  `~/Pictures/Screenshots`, timestamped `full-<ts>.png` with numeric
  collision suffix, prints the path, optional `notify-send` (works without).
- `archther-screenshot-region`: same, but selects via slurp first;
  cancellation (Esc/empty) exits 0 silently with no file.

Repo copies carry the executable bit; live copies are owner-only (700).

## Shortcuts (in `config/hypr/modules/keybindings.lua`)

- `Print` → full screenshot.
- `SHIFT + Print` → region screenshot.
- `SUPER+SHIFT+S` was the suggested region key but is already the
  scratchpad-move binding (verified conflict), so the GNOME convention was
  used instead. Binds call `$HOME/.local/bin/…` (shell-expanded; `~/.local/bin`
  is not on PATH, so absolute-via-`$HOME` is required). All 48 prior binds
  untouched — 50 total registered.

## Required utilities

`dunst 1.13.2`, `grim 1.5.0`, `slurp 1.5.0`, `notify-send` (libnotify,
optional), `dunstctl` (reload + history inspection). No packages installed
or removed by this task.

## Tests actually performed

- Static: dunstrc key audit (zero unknown keys), `bash -n` both scripts,
  missing-dependency exits (clean messages, status 1), `luac` keybindings,
  no-duplicate-binds, `git diff --check`, secret review.
- Runtime: full-capture script ran headless in a sandbox HOME → two real
  1920x1080 PNGs, collision suffix exercised; `dunstctl reload` with zero
  journal warnings; one normal test notification delivered with correct
  formatted summary/body; `hyprctl reload` ok, 50 binds, both new binds
  once each, `configerrors` empty.

## Manual tests for the owner

1. `Print` → `~/Pictures/Screenshots/full-<ts>.png` appears + readable
   notification. 2. `SHIFT+Print`, drag a small region → `region-<ts>.png`
   appears. 3. Esc during selection → nothing happens, no file, no error.
4. Send a test critical notification
   (`notify-send -u critical Test Body`) → gold-framed, persistent popup.
5. Re-confirm `SUPER+R`, brightness, volume, media keys unchanged.

## Backup and rollback

Pre-deploy backup holds the prior Hyprland tree (dunst/`~/.local/bin` did
not exist). Rollback: preserve failed files aside, restore the backup,
`diff -r` to confirm, `dunstctl reload` + `hyprctl reload`, verify counts;
revert in-repo via `git revert` on a new branch. Never delete backups
before recovery is verified.

## Deferred

Wofi-geometry tuning, Dunst action/context-menu flows, screenshot
upload/share integrations (explicitly out of scope), Dolphin/Zen theming.
