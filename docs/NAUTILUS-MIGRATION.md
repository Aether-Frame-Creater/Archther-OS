# Nautilus Migration — Archther OS

Explicit user request: Nautilus is the permanent default file manager;
Dolphin is uninstalled. Historical task reports still mention Dolphin —
they are history and were not rewritten.

## Why

Single consistent GTK file-manager workflow next to the libadwaita-adjacent
desktop; removes the KDE file-manager dependency while the MTP capability
stays covered by the independent `kio-extras`/`libmtp` stack.

## Verified components

- Nautilus `51.0.1-2`, `/usr/bin/nautilus`, desktop entry
  `org.gnome.Nautilus.desktop` (`Exec=nautilus --new-window %U`).
- Launch-tested as the desktop user (stayed running, cleaned up after).
  Benign warnings only (Tracker notice, Mutter/portal notices expected on
  non-GNOME Wayland — file browsing unaffected).
- Notes: libadwaita apps may render light without the GNOME settings
  portal; no color-scheme override was made here (follow-up decision).

## Default-handler change

- Before: system default `inode/directory=kitty-open.desktop`
  (a NoDisplay terminal URL handler), Dolphin second. No user
  `mimeapps.list` existed.
- After: user-level `inode/directory=org.gnome.Nautilus.desktop`,
  verified by re-query. No other associations existed, so none were
  touched. Rollback: delete that line (or the file, if still single-entry).

## Binding change

`SUPER+E` preserved; only its target changed:
`M.fileManager = "dolphin"` → `"nautilus"` in
`config/hypr/modules/variables.lua` (deployed + reloaded, 50 binds,
no errors). Manifest: `dolphin` → `nautilus` in
`packages/essential-workflow.txt`.

## Dolphin removal

Pre-checks passed (Nautilus launches, MIME resolves, binding deployed,
`Required By: None`, nothing else references the binary), then targeted
`pacman -R dolphin` only — no `-n/-s/-dd`, no orphan cleanup, no manual
`/usr` deletions. Verified absent afterwards. Kept deliberately:
`kio-extras`, `libmtp` (MTP stack, untouched), `~/.config/dolphinrc` and
Dolphin data dirs (personal config, deletion never authorized).

## KDE color-scheme status

`config/kde/Archther.colors` is **kept and still active**: it is a
KDE-wide scheme, not Dolphin-specific, and other Qt/KDE applications
(file dialogs, agents) still follow it. Disabling it is a separate
decision with its own visual consequences — not done here.

## Tests performed / pending

Performed: version/entry/ownership checks, bounded launch test, MIME
query before+after, `luac`, bind count + error check post-reload,
post-removal state audit (nautilus present, dolphin absent, MIME intact,
user configs preserved, 50 binds).
Pending (owner): press `SUPER+E` → Nautilus window; open a folder from
another app → Nautilus handles it; phone MTP transfer still works;
re-confirm Wofi→Kitty, brightness, volume, media, screenshots unchanged.

## Rollback

Reinstall Dolphin (`pacman -S dolphin`), restore the MIME line, revert the
two one-line repo edits (new commits; never rewrite history), redeploy
`variables.lua`, reload, verify 50 binds. Backups hold the prior Hyprland
tree. No reboot/SDDM actions involved.
