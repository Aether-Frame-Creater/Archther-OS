# AGENTS.md — Archther OS

## Required Context

Before implementation, read all nine files in `context/`:

1. `project-overview.md`
2. `architecture.md`
3. `build-plan.md`
4. `code-standards.md`
5. `library-docs.md`
6. `progress-tracker.md`
7. `ui-registry.md`
8. `ui-rules.md`
9. `ui-tokens.md`

Use these documents as the project source of truth. If requirements conflict, report the conflict and do not silently invent a decision. Inspect the actual repository, Git state, installed programs, and component versions before assuming anything exists.

## Project Goal

Build Archther OS as an independently branded Arch Linux desktop experience inspired by Omarchy's integrated workflow. First stabilize and modularize the existing Hyprland configuration; then develop the theme, menu, CLI, setup engine, and eventually an Archiso-based distribution after clean-environment testing.

## Hard Safety Rules

- Do not make disk, partition, LUKS, Btrfs layout, Limine, or boot-entry changes as part of ordinary desktop setup.
- Do not silently run privileged commands or change firewall rules, system services, package removals, or network access.
- Do not overwrite existing configurations without reviewing them and creating a recoverable backup.
- Never force-push, rewrite Git history, discard user work, merge branches, or push changes without explicit approval.
- Never commit API keys, passwords, sudo credentials, OpenCode authentication, browser profiles, cookies, SSH/private keys, tokens, or personal configuration data.
- Never store a sudo password or any other secret in `AGENTS.md`, `context/`, scripts, environment examples, shell history, or Git. If privilege is needed, request it interactively through `sudo`; never automate password entry.
- Keep the nine local context documents in `context/` untracked and excluded from GitHub commits. The user may provide them locally to OpenCode, but they must not be staged or published.
- Do not claim any feature or test passed unless it was actually run and verified.

## Workflow

1. Inspect the Git working tree, branch, remotes, relevant files, and installed versions.
2. State a concise plan and the files likely to change.
3. Implement only the current task; do not start unrelated future phases.
4. Use current official documentation for version-specific syntax.
5. Back up configuration before modifying; preserve a way to recover from a broken session.
6. Run relevant checks and report exact results, including checks not run.
7. Update `context/progress-tracker.md` and `context/ui-registry.md` only when supported by verification.
8. Do not install optional components merely because they are listed as future candidates.

## Technical Baseline

- Base: Arch Linux.
- Desktop compositor: Hyprland.
- Login manager: SDDM.
- Current applications include Kitty, Wofi, Dunst, Grim, Slurp, Dolphin, and other tools documented in `context/project-overview.md`.
- Use pacman for official repository packages and yay for AUR packages when justified.
- Confirm the installed Hyprland syntax before generating config.
- Initial brand colors: navy `#0B2A6F`, gold `#E8A11C`, dark background `#0B0F14`, and restrained cyan `#38BDF8`.

## Completion Report

After every focused, verified change, create a descriptive commit (unless the user explicitly asks to defer committing). At the end of a task report: what changed, files changed, commands/checks run, observed results, what was not tested, risks/recovery steps, and the next planned task. Never present a proposed CLI command or planned UI component as implemented until it exists and has been verified.
