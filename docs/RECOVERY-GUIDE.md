# Recovery Guide — Broken Hyprland Configuration

Goal: recover a working Hyprland session **without reinstalling Arch Linux**,
without touching boot, disk, encryption, or snapshots.

This guide was written against the audited baseline (`docs/BASELINE-AUDIT.md`):
user `afc`, graphical session on **tty1**, SDDM active and enabled, Hyprland
config at `/home/afc/.config/hypr/hyprland.lua`, known-good backup at
`/home/afc/Archther-Backups/hypr/20261010-190357/`. If your machine differs,
substitute your actual username, TTY, and backup path.

> Rule: preserve before you restore. Never delete the broken config — move it
> aside so it can be inspected later.

## 1. Switch to a text console

Press **`Ctrl+Alt+F3`**. This is a commonly available virtual-console key
combination; any of F3–F6 normally gives a text login prompt. The graphical
session stays untouched on its own TTY while you work here.

## 2. Log in and inspect (read-only first)

Log in as your normal user (`afc`), then look before touching anything:

```bash
loginctl list-sessions          # is your graphical session still listed?
loginctl show-session <id> -p State -p Type
systemctl is-active sddm         # read-only status check, changes nothing
journalctl --user -b --no-pager | tail -50   # recent session errors
```

These commands change nothing. They tell you whether the session died, the
display manager is healthy, and what Hyprland complained about.

## 3. Locate the documented backup

```bash
ls -la ~/Archther-Backups/hypr/
```

Pick the timestamped directory matching the backup record (baseline backup:
`20261010-190357/`). Confirm it contains `hyprland.lua`:

```bash
ls -la ~/Archther-Backups/hypr/20261010-190357/
```

If the directory is missing or empty, **stop** — do not improvise; the
Snapper timeline snapshots (see §8) are the fallback topic, not a step to
take blindly.

## 4. Preserve the broken configuration (changes files — labelled)

Move the current config aside with a timestamp, so nothing is lost:

```bash
STAMP="$(date +%Y%m%d-%H%M%S)"
cp -a ~/.config/hypr ~/.config/hypr.broken-"$STAMP"
chmod -R go-rwx ~/.config/hypr.broken-"$STAMP"
ls -la ~/.config/ | grep hypr
```

## 5. Restore the known-good backup (changes files — labelled)

Copy the backup **contents** back into place and verify byte-for-byte:

```bash
cp -a ~/Archther-Backups/hypr/20261010-190357/. ~/.config/hypr/
diff -r ~/Archther-Backups/hypr/20261010-190357/ ~/.config/hypr/ && echo RESTORED-CLEAN
```

`diff -r` printing nothing (plus `RESTORED-CLEAN`) means the restore matches
the backup exactly. Use your actual verified backup path, not this example,
if a newer backup exists.

## 6. Validate before relaunching

No standalone Hyprland config validator was confirmed on this machine, so
validation here means: confirm the restored file is the known-good copy
(`diff -r` above, and it previously ran a working session). Do not edit the
file from the TTY unless you know the exact offending lines — re-editing
blind risks a second broken state with no new backup.

## 7. Relaunch the graphical session

Return to the graphical TTY with **`Ctrl+Alt+F1`** (the audited session ran
on tty1; if F1 shows nothing usable, try `Ctrl+Alt+F2`). Then:

- If SDDM or your Hyprland session is there, log in / continue normally.
- If the session starts but misbehaves, switch back to the TTY (F3) and
  re-check `journalctl --user -b` for the new errors.

Do **not** run `systemctl restart sddm` as a routine step: restarting the
display manager terminates **all** graphical sessions immediately. Only
consider it if the display manager itself is hung, no session is reachable,
and you accept losing every open graphical program — and say so explicitly
before doing it. Rebooting is likewise not the default step; it is slower
than a TTY restore and teaches nothing about the failure.

## 8. If recovery fails

1. Switch back to the TTY (`Ctrl+Alt+F3`) — you still have the preserved
   `~/.config/hypr.broken-<stamp>/` copy for diagnosis.
2. Re-read the session errors: `journalctl --user -b --no-pager | grep -i -E "hypr|error|fail" | tail -30`.
3. Confirm what actually changed: `diff -r ~/Archther-Backups/hypr/20261010-190357/ ~/.config/hypr.broken-<stamp>/`.
4. Read-only snapshot check (changes nothing): `snapper -c root list` and
   `snapper -c home list`. Rolling back to a snapshot is a privileged,
   destructive operation — treat it as a separate decision requiring explicit
   approval, never as the next line in this guide.

## What this guide never does

No Limine/boot-entry edits, no kernel parameters, no LUKS/Btrfs/partition
changes, no Snapper reconfiguration, no package or service changes, no
firewall changes. Recovery stays within one user config directory plus
read-only inspection.
