# Archther-OS
A personal Arch Linux–based desktop environment by Aether Frame Creater Your base installation is already working. The next objective is to turn the current Arch Linux + Hyprland installation into a polished, recognizable Archther desktop without sacrificing stability.

## Project Summary

Archther OS is an independently branded, keyboard-first Arch Linux desktop
experience built on Hyprland, inspired by Omarchy's integrated workflow.
The first deliverable is a reliable, version-controlled desktop configuration
and setup process for the existing installation; a bootable Archiso-based
installer is a later phase and is not yet implemented.

- Base: Arch Linux (rolling release)
- Compositor: Hyprland
- Login manager: SDDM
- Terminal: Kitty · Launcher: Wofi · Notifications: Dunst
- Screenshots: Grim + Slurp · File manager: Dolphin

## Current Status

Repository foundation is under construction on `feature/repo-foundation`
(see `docs/DEVELOPMENT.md` for the branch workflow).

Reported working baseline (owner-supplied, re-verification pending):
Arch Linux, Hyprland, SDDM, internet, Git, yay, Zen Browser, OpenCode,
LazyVim, Dolphin, and MTP phone-to-laptop transfer. Limine, LUKS, Btrfs,
Snapper, systemd-logind, PipeWire, Bluetooth, and Power Profiles Daemon are
listed as part of the setup. UFW is not configured.

No setup automation, theme integration, or ISO build exists yet. Do not treat
planned components as implemented.

## Setup Notes

There is currently no automated setup script. Configuration is applied
manually, one focused change at a time, with a backup of any replaced file
kept before modification. Recovery path: keep a known-good copy of
`~/.config/hypr/` and know how to reach a TTY if the session fails to start.

System-critical areas (disk layout, LUKS, Btrfs/Snapper, Limine boot entries,
firewall rules, system services) are never changed as part of desktop setup
without explicit review and approval.

## Contribution Workflow

- `main` is stable and release-ready; `dev` is the integration branch.
- Do scoped work on short-lived `feature/<name>` branches cut from `dev`.
- Inspect `git status`, the current branch, and remotes before changing
  repository state. Never force-push, rewrite history, or merge without
  explicit approval.
- Run `git diff --check` and review the full diff before committing.
- Keep each commit focused with a descriptive imperative message.
- Keep the local-only `context/` directory (AI working instructions) and any
  credentials out of Git. See `AGENTS.md` and `docs/DEVELOPMENT.md`.
