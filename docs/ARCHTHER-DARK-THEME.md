# Archther Dark Theme — Hyprland Integration

First official Archther theme integration (Hyprland window borders only).
No other application is themed by this task.

## Palette and token values

Canonical tokens (`config/hypr/themes/archther.lua`, mirroring
`context/ui-tokens.md`):

| Token | Hex | Role here |
|---|---|---|
| `navy` | `0B2A6F` | Active-border gradient start |
| `gold` | `E8A11C` | Active-border gradient end |
| `background` | `0B0F14` | Reserved for future integrations |
| `cyan` | `38BDF8` | Reserved for future integrations |
| `navy_dim` | `071A46` | Derived (navy darkened): inactive border |

`background` and `cyan` are intentionally unused in Hyprland so far — they
stay centralized for Kitty/Wofi/Dunst/Waybar work, not forced into
unrelated settings.

## Module purpose and consumption

- `config/hypr/themes/archther.lua`: pure-data module (returns a table, no
  `hl.*` calls, no bindings, no globals). The `hypr` subtable maps canonical
  hex to the installed API's `rgba()` gradient form.
- `config/hypr/modules/settings.lua`: loads it via
  `local theme = require("themes.archther")` (resolves under the config dir
  per the verified `package.path` behaviour) and references
  `theme.hypr.active_border` / `theme.hypr.inactive_border`. No hardcoded
  color copies remain in settings.

## Border treatment

- Focused: navy→gold gradient, `angle = 45`, near-opaque (`ee` alpha) —
  border size 2 and angle preserved from stock.
- Unfocused: flat muted navy (`navy_dim`, opaque).
- Everything else (gaps, layout, decoration, animations, input, monitors,
  keybindings, rules, opacity): byte-identical behaviour, verified by diff.

## Version and API references

- Installed: Hyprland 0.56.2-4 (Lua config API).
- Official 0.56 `Configuring/Basics/Variables`: gradient accepts
  `{ colors = { "rgba(...)", "rgba(...)" }, angle? = 45 }` — the format used.
- Upstream `example/hyprland.lua`: structural reference only; all values
  migrated from the live config, never upstream.

## Static validation results

- `luac -p` on all affected files: pass (syntax only — stated explicitly).
- Theme module executed under stock Lua 5.4: emitted strings byte-exact
  (`rgba(0B2A6Fee)`, `rgba(E8A11Cee)`, angle 45, `rgba(071A46ff)`).
- Diff review: only the `col` block + one `require` line changed;
  `keybindings.lua`/`variables.lua` untouched (Wofi, brightness, volume,
  media binds preserved); `git diff --check` clean; secret review clean.

## Runtime and visual tests performed

- `hyprctl reload` → ok; `configerrors` empty; binds stable at 48 across
  reload; monitor unchanged; compositor responsive.
- `hyprctl getoption` confirms the applied values: active
  `ee0b2a6f eee8a11c 45deg`, inactive `ff071a46`, both `set: true`.
- No visual inspection was possible from this shell — borders are proven
  *applied*, not *seen*.

## Manual visual check for the owner

Open two windows (e.g. `SUPER+Q` twice), focus each in turn: the focused
frame should show the navy→gold gradient, the unfocused frame flat dark
navy. If colors look wrong, report — do not edit live files directly.

## Limitations and future work

- Kitty, Wofi, Dunst, Dolphin, Waybar: explicitly not themed yet.
- `navy_dim` is a documented derivative, not a canonical brand token; if
  design later defines an official unfocused-border color, replace it there.
- Contrast/accessibility of the gradient was not measured.

## Safe revert

The pre-deployment timestamped backup (path in task report) holds the
previous `hyprland.lua` + `modules/`. To revert: preserve the themed tree
aside, restore the backup over `~/.config/hypr/`, `diff -r` to confirm,
`hyprctl reload`, verify 48 binds and empty `configerrors` — per
`docs/RECOVERY-GUIDE.md`. To revert in-repo: `git revert` the theme commit
on a new branch; never rewrite published history.
