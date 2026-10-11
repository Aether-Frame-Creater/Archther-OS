# Archther Navigation System

Implementation record for the keyboard-first navigation work. The user-facing
shortcut list lives in [`ARCHTHER-HOTKEYS.md`](ARCHTHER-HOTKEYS.md); this
document records how the system was built, what was verified, and what was
deliberately left out.

## What was built

Three focused commits on `feature/archther-navigation`, each verified before
being published:

| Commit | Contents |
|---|---|
| `7523f4c` | `scripts/archther-menu`, `scripts/archther-hotkeys` |
| `a5d8ec7` | `config/hypr/modules/navigation.lua`, `modules/workspaces.lua`, plus `variables.lua`, `keybindings.lua`, `hyprland.lua` |
| this branch | `docs/ARCHTHER-HOTKEYS.md`, `docs/ARCHTHER-NAVIGATION.md`, `scripts/archther-hotkey-check` |

New configuration modules:

- `config/hypr/modules/navigation.lua` — menu, direct application launchers,
  directional focus with cursor follow, window swap, float/pseudo/fullscreen,
  resize steps, window close, pinned windows, scratchpad alternates.
- `config/hypr/modules/workspaces.lua` — workspace sequencing, transfer without
  following, grouping, and dwindle/scrolling layout switching.

## How the dispatcher syntax was determined

Every dispatcher argument was taken from the **v0.56.2 upstream source**
(`src/config/lua/bindings/LuaBindingsDispatchers.cpp`,
`src/config/shared/actions/ConfigActions.cpp`,
`src/layout/supplementary/WorkspaceAlgoMatcher.cpp`) and then confirmed against
the running compositor with `hyprctl repl`. Nothing was copied from an older
hyprlang example, because the 0.55+ Lua API differs from it.

Three API behaviours would have produced broken shortcuts if assumed rather
than tested:

1. **`hl.window.resize` needs `relative = true`.** By default x/y are an
   *absolute* target size, so a resize binding without this flag returns
   `Invalid size` and silently does nothing. Every resize binding passes it.

2. **`hl.window.pin` refuses non-floating windows.** The guard is
   `!window->m_isFloating` in `Actions::pinWindow`. `SUPER + O` therefore floats
   the window first, then pins it. Pinning a tiled window fails outright.

3. **`hl.dsp.layout("scrolling")` does not select a layout.** It forwards the
   string to the *current* layout's message handler, which rejects it with
   `Unknown dwindle layoutmsg: scrolling`. Layout selection goes through
   `general:layout`.

Two further environment facts shaped the design:

- `os.execute` returns `nil` for both success and failure in the Lua build
  Hyprland 0.56.2 embeds, so it cannot test whether a command exists. The
  `SUPER + CTRL + T` gate walks `PATH` with `io.open` instead.
- `hl.get_config()` returns `nil` in this version, so the layout toggle reads
  the workspace's `tiled_layout` property instead.

## Scrolling layout

`SUPER + L` toggles between dwindle and scrolling.

Scrolling layout is **built into Hyprland 0.56.2**
(`src/layout/algorithm/tiled/scrolling/ScrollingAlgorithm.cpp`). No plugin,
patched compositor, or extra package is present or needed on this machine, so
no dependency blocker applies here.

**Per-workspace behaviour is an approximation, stated plainly.** 0.56.2 exposes
no runtime setter for one workspace's layout: `ws.tiled_layout` is read-only,
and `WorkspaceAlgoMatcher` reads either a workspace rule or the global
`general:layout`. The implementation therefore remembers the choice per
workspace id in a Lua table and reapplies it on the `workspace.active` event,
which gives each workspace its own effective layout. The table is rebuilt from
the configured default on reload, so **the selection does not survive a logout**.
Persisting it across restarts would need either a config-time workspace rule or
an unsupported runtime setter.

## Conflict resolution

Every pre-existing binding was inspected before anything changed. No working
shortcut was silently overwritten.

| Key | Before | After | Reason |
|---|---|---|---|
| `SUPER + Q` | Launch Kitty | Close window | Terminal moved to `SUPER + RETURN`, so no function was lost. `SUPER + Q` and `SUPER + C` were both requested as close; `SUPER + C` kept its original binding. |
| `SUPER + P` | Pseudo window | Pseudo window | Moved into `navigation.lua` with an explicit `toggle` action; behaviour unchanged. |
| `SUPER + arrows` | Focus | Focus + cursor follow | Moved into `navigation.lua`; keys and focus behaviour preserved, cursor follow added. |
| `SUPER + T` | unbound | Toggle float | New key. `SUPER + V` keeps its original float binding as an alias. |
| `SUPER + SPACE`, `K`, `L`, `O`, `G`, `W`, `TAB`, `RETURN`, `SHIFT+RETURN`, `SHIFT+F`, `ALT+F`, `CTRL+F` | unbound | new bindings | No prior binding used these. |

Untouched and verified still bound: `SUPER + R` (Wofi launcher), `SUPER + E`
(Nautilus), `SUPER + J` (split), `SUPER + V` (float), `SUPER + S` and
`SUPER + SHIFT + S` (scratchpad), `SUPER + 0..9` and `SUPER + SHIFT + 0..9`
(workspaces), `SUPER + scroll`, `SUPER + LEFT/RIGHT MOUSE`, `Print`,
`SHIFT + Print`, all ten volume/microphone/brightness/media keys, and
`SUPER + M` (exit).

## Deferred, and why

| Item | Status |
|---|---|
| `SUPER + CTRL + T` (system monitor) | Deferred. `btop` is in the official `extra` repository but is not installed. No binding is registered and the reason is printed at load time. Installing `btop` enables it on the next reload — no config edit needed. |
| `CTRL + ALT + DELETE` (close all windows) | Not bound. It discards unsaved work and a single keystroke cannot confirm it safely. Needs an explicit confirmation flow before it is worth binding. |
| `SUPER + ALT + HOME` / `SUPER + HOME` (save/restore window width) | Not available. Hyprland 0.56.2 has no dispatcher that stores a window dimension. Binding these would have meant shipping a script that silently does nothing useful. |
| `SUPER + SHIFT + ALT + arrows` (move workspace between monitors) | Not bound. `hl.dsp.workspace.move` exists but requires a monitor selector, and this machine has a single output (`eDP-1`). Binding it would create four dead shortcuts. |

## Keeping the hotkey reference honest

`docs/ARCHTHER-HOTKEYS.md` is a second listing of the same bindings, which is
exactly the kind of duplicate that goes stale. `scripts/archther-hotkey-check`
prevents that by comparing the document against `hyprctl binds`:

- every binding the compositor has must appear in the document;
- every shortcut the document claims must exist in the compositor;
- the compositor must have no duplicate `(modmask, key)` pairs;
- the total stated in the document must match the real total.

It expands the document's shorthand (`SUPER + 1..0` is the wrapped Hyprland
form covering workspaces 1-10; `SUPER + ALT + MINUS/EQUAL` is two shortcuts) and
ignores the deferred-items table, which by design lists unbound keys.

```sh
hyprctl binds >/dev/null   # must be run inside the graphical session
python3 scripts/archther-hotkey-check docs/ARCHTHER-HOTKEYS.md
```

Verified to fail on a removed binding, an invented binding, a wrong total, and
an incomplete key group, and to pass on the unmodified document.

## Deployment and recovery

Backup taken before any change and verified with `diff -r` plus matching
`sha256sum`:

```
/home/afc/Archther-Backups/task-011/20261011-081345/
├── hypr/          full copy of ~/.config/hypr (9 files)
├── local-bin/     copy of ~/.local/bin
└── docs-ABSENT.txt  (marker: no docs directory existed yet)
```

The backup lives outside the repository, is owned by `afc`, and is `go-rwx`.
It is retained until restoration is confirmed.

Deployment was done as user `afc` with `install` (never as root, never a
symlink to the Git tree, no broad recursive ownership change). The entry point
was swapped last, via a same-filesystem temporary file and an atomic rename.
Helper scripts were deployed to `~/.local/bin` **before** any binding that
depends on them was enabled.

Rollback: copy `hypr/` from the backup over `~/.config/hypr/`, remove
`~/.local/bin/archther-menu` and `~/.local/bin/archther-hotkeys` (both new in
this task), and reload. `docs/RECOVERY-GUIDE.md` covers the TTY route if the
session itself fails.

## Verification performed

Static: `luac -p` on all 11 Lua files; `bash -n` on all shell scripts; a
duplicate scan across literal and loop-generated binds; `git diff --check`; a
secret scan of staged changes. `shellcheck` and `shfmt` are **not installed** on
this machine, so those checks were not run.

Runtime, against the live session via the compositor's own dispatcher API:

- 96 bindings registered, zero duplicates, zero config errors, stable across
  three consecutive reloads; monitor `eDP-1` unchanged.
- Directional focus moves between real tiled neighbours.
- Swap was verified **separately** from focus by observing two windows exchange
  positions while focus stayed on the same window.
- `togglesplit` flips a live split between horizontal and vertical and back.
- Resize moves a window by exactly 10 px and clamps at the work area.
- `fullscreen` reports mode 2, `maximized` reports mode 1, and
  `fullscreen_state{internal=0}` leaves the compositor layout untouched.
- Grouping: merge produced a size-2 group, `group.next`/`prev` and
  `group.active{1,2}` moved between members, `out_of_group` reduced it to size
  1, and `group.toggle` disassembled it.
- Scratchpad: `special:magic` opens and closes, a window moved there hides, and
  moving it back to workspace 2 restores it.
- A pinned window stayed visible on a different workspace that had its own
  window.
- The navigation menu rendered in the real Wayland session with the expected
  flags and launched nothing.

Test windows were closed afterwards; the two pre-existing user windows and all
three workspaces are unchanged.

**Not tested:** physical keypresses. Every shortcut was exercised through
`hyprctl`, not by pressing keys, so the physical feel of each combination, the
cursor follow during rapid arrow navigation, the menu's appearance, and audible
volume/media feedback still need a manual pass at the keyboard.
