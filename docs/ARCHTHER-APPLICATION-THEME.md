# Archther Application Theme — Kitty + Wofi

Second Archther Dark integration (Hyprland borders were Task 006).
Dolphin, Dunst, Zen Browser, Waybar: explicitly not themed by this task.

## Canonical palette (reference, unchanged)

Navy `0B2A6F`, gold `E8A11C`, dark background `0B0F14`, cyan `38BDF8`
(`config/hypr/themes/archther.lua`, `context/ui-tokens.md`); muted navy
`071A46` remains a documented derivative. All application files reuse these
values; nothing is duplicated as an independent palette.

## Supporting colors (documented, not brand tokens)

- Text: `F8FAFC` primary, `CBD5E1` secondary (terminal normal-white / entry text).
- Surfaces: `111827`, `172033` (black ANSI, tabs, Wofi input field).
- Dividers: `334155` (bright-black ANSI, input border).
- Selection navy `163B85` (Kitty selection background).
- Gold-soft `F6BD49` (bright-yellow ANSI).
- Violet `A78BFA` / `C4B5FD` (magenta ANSI — no brand equivalent exists).

## Kitty — `config/kitty/kitty.conf`

Appearance-only (no font/shell/shortcut/behavior settings): background
`0B0F14`, foreground `F8FAFC`; gold cursor with navy cursor text; cyan URLs;
active window border gold, inactive `071A46` (matches Hyprland borders);
gold/navy active tab, dark inactive tabs; coherent 16-color ANSI set above.
Live path: `~/.config/kitty/kitty.conf` (directory previously existed empty —
no user settings were replaced). New Kitty instances load it automatically.

## Wofi — `config/wofi/style.css` (no config file)

Dark window (`0B0F14`, navy 2px border, 12px radius); dark input field with
light text; transparent list containers; entries light-secondary text;
selected entry navy background, light text, gold border. Only the widget
names documented in the installed `wofi(7)` WIDGET LAYOUT are used
(`#window`, `#outer-box`, `#input`, `#scroll`, `#inner-box`, `#entry`,
`#entry:selected`); entry text inherits color (no unverified selectors).
Live path: `~/.config/wofi/style.css` — the documented default stylesheet
location, layered highest priority, so `wofi --show drun` is unchanged and no
`config` file is required (geometry stays at Wofi defaults).

## Paths verified on this system

Kitty 0.49.2 (`/usr/bin/kitty`; every option name checked against installed
`kitty.conf(5)`); Wofi 1.5.3 on GTK3 (`/usr/bin/wofi`; modes/options from
installed `wofi(1)`/`wofi(5)`/`wofi(7)`). `SUPER+R` still targets the
existing Wofi command; brightness/volume/media binds untouched.

## Validation commands used

`luac` N/A (no Lua touched). Kitty: option-name audit vs installed man page
(all present), hex-format check, appearance-only scan. Wofi: balanced-brace
check, selector allowlist check, default-path confirmation from man page.
`git diff --check` clean; secret review clean (colors only).

## Runtime test results (honest)

- Deployed files byte-identical to repo; zero root-owned files in live dirs.
- Hyprland session healthy (48 binds, no errors) — Hyprland itself untouched.
- Kitty rendering and Wofi rendering **not** visually inspected from this
  shell (no display path; launching either would pop windows on the active
  session unprompted). New Kitty instances and the next `SUPER+R` pick the
  themes up automatically.

## Manual verification for the owner

1. `SUPER+Q` (or any new terminal): dark background, readable text, gold
   block cursor; run `ls` / colored output for ANSI sanity.
2. `SUPER+R`: dark launcher, navy+gold selected row, light input text; type
   `kitty`, Enter — terminal launches with the new theme.
3. If anything looks wrong, keep using the desktop (old behaviour is a
   strict superset visually) and report before editing.

## Backup and rollback

Pre-deployment backup holds the previous state (empty `kitty/` dir;
`wofi/` did not exist). Rollback: preserve the themed files aside, restore
the backup contents, `diff -r` to confirm, open a new Kitty / press
`SUPER+R` to confirm restoration. Revert in-repo via `git revert` on a new
branch; never rewrite published history.

## Deferred

Dunst, Dolphin, Zen Browser, Waybar/Quickshell theming; screenshot-flow
bindings; Wofi geometry tuning (only if the owner finds defaults wanting).
