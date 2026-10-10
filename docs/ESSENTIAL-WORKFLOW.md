# Essential Workflow — Archther OS

Verified against Hyprland 0.56.2 with the modular configuration in
`config/hypr/`. Package list: `packages/essential-workflow.txt`.

## User-confirmed working (do not regress)

| Shortcut | Action |
|---|---|
| `SUPER+R` | Opens Wofi (`wofi --show drun`) |
| Wofi → type `kitty` → Enter | Launches Kitty terminal |

## Essential shortcuts and their commands

| Shortcut | Command | Package | Status |
|---|---|---|---|
| `SUPER+Q` | `kitty` | `kitty` | Installed (user-confirmed via Wofi) |
| `SUPER+R` | `wofi --show drun` | `wofi` | Installed, user-confirmed |
| `SUPER+E` | `dolphin` | `dolphin` | Installed; launch untested |
| `SUPER+C` | close window | — | Unchanged stock behaviour |
| `SUPER+M` | `hyprshutdown` or `hyprctl` fallback | `hyprland` | `hyprshutdown` absent; fallback path preserved, untested |
| `SUPER+V / P / J` | float toggle / pseudo / togglesplit | — | Unchanged stock behaviour |
| Arrows, `SUPER+1..0`, `SHIFT` variants, `S`, scroll, mouse drag/resize | Focus / workspace / special-workspace movement | — | Unchanged; 48 binds registered, verified via `hyprctl` |
| `XF86Audio*` volume/mute | `wpctl …` | `wireplumber` | Installed; audible effect untested |
| `XF86MonBrightnessUp/Down` | `brightnessctl -e4 -n2 set ±5%` | `brightnessctl` | **Installed by Task 005** (was missing); device discovery + read verified, actual adjustment untested |
| `XF86AudioNext/Pause/Play/Prev` | `playerctl …` | `playerctl` | **Installed by Task 005** (was missing); no active player present, control untested |

Screenshots (`grim` + `slurp`, both installed) have **no binding yet** —
deferred to the workflow task that designs the capture flow.

## What was fixed vs already working

- Fixed: installed `brightnessctl 0.5.1-3` and `playerctl 2.4.1-5` from
  official `extra` (2 and 4 dead binds respectively). No binding text
  changed — the stock commands were already correct.
- Already working, preserved untouched: Wofi binding/mode, Kitty launch,
  `hyprshutdown` fallback logic, module-loading architecture, all other
  shortcuts and settings.

## Validation performed

- Every `exec_cmd` target resolved to an installed executable with
  `pacman -Qo` package ownership (except the two fixed helpers, before
  install, and the knowingly-absent `hyprshutdown`).
- Backlight device exposed: `intel_backlight`, readable value confirmed;
  **write permission for the desktop user not established** (no groups/udev
  changes made — out of scope). Brightness keys may need a follow-up
  permission decision; test manually first.
- `playerctl --list-all`: no players found — dependency resolved, runtime
  target absent (expected; nothing was played/paused for testing).
- `hyprctl`: session responsive, `configerrors` empty, 48 binds registered
  (task: re-verify count at report time).
- `git diff --check` clean; secret review clean (package names only).

## Manual tests for the owner

1. `SUPER+R`, type `kitty`, Enter (re-confirm after this task).
2. `SUPER+E` → Dolphin opens.
3. Volume keys → audible change; mute toggles.
4. Brightness keys → visible change. If nothing happens, run
   `brightnessctl set 5%+` in a terminal: a permission error means the
   follow-up task is backlight permissions, not the binding.
5. With music playing in a player: Next/Pause/Prev keys.
6. `SUPER+Q` opens a second terminal; `SUPER+C` closes one.

## Remaining missing helpers

- `hyprshutdown`: fallback (`hyprctl dispatch exit`) covers it; no action.
- `brightnessctl` write access for the desktop user: unknown, needs the
  manual test above before any permission change is even discussed.
