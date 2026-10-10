# Archther Zen + Dolphin Theme

Third Archther Dark integration (Hyprland borders, Kitty/Wofi, Dunst
already done). Zen profiles, KDE defaults, and all prior themes untouched.

## Canonical palette (unchanged)

Navy `0B2A6F`, gold `E8A11C`, background `0B0F14`, cyan `38BDF8`
(`config/hypr/themes/archther.lua`); muted navy `071A46` stays a documented
derivative. Supporting text/surface/semantic colors are documented per file,
never presented as brand tokens.

## Zen Browser (`config/zen/userChrome.css`)

- Verified: native package `zen-browser-bin 1.23.2b-1` (`/usr/bin/zen`),
  XDG profile dir `~/.config/zen`; **active profile**
  `ys7dd6s7.Default (release)` proven by its `lock → PID` symlink (browser
  running — profile files were only read, never written, except the CSS
  install below). A second near-empty profile exists and was left alone.
- Existing `chrome/zen-themes.css` is ZenMods-managed ("DO NOT EDIT") and
  was preserved byte-identical; the theme is a separate `userChrome.css`.
- CSS is color/background/border rules only on stable Firefox chrome
  selectors (toolbox, tabs, urlbar, menus, separators, focus). Zen-specific
  internals (vertical-tab strip, workspaces) deliberately untargeted.
- **Activation pending (user action):** the pref
  `toolkit.legacyUserProfileCustomizations.stylesheets` is absent (= false).
  Enable via `about:config` → set true → restart Zen. `prefs.js` was not
  touched (unsafe while running). CSS installed at
  `<profile>/chrome/userChrome.css`, inert until then.

## Dolphin (`config/kde/Archther.colors`)

- Verified: Dolphin 26.08.2 (KF6), `kwriteconfig6` present, no prior
  `kdeglobals`, no user schemes, no system `.colors` reference files — the
  scheme was written from the stable KColorScheme section/key format.
- Complete sections (Window/View/Button/Selection/Tooltip/Complementary)
  with valid `R,G,B` triplets; normal-text contrast 11–18.4 everywhere.
- Installed to `~/.local/share/color-schemes/Archther.colors`
  (byte-identical) and **activated** via
  `kwriteconfig6 --file kdeglobals --group General --key ColorScheme Archther`
  (new file, single key, read back verified).
- Scope warning: the active scheme affects all Qt/KDE apps following it
  (Dolphin, KDE file dialogs, etc.) — user-level, reversible, no system
  paths touched. The running Dolphin keeps its old look until restarted;
  new launches use Archther.

## Validation performed

CSS brace balance; chrome-only scan (no page selectors, no Zen internals);
`.colors` INI parse, required-section check, value-range check, contrast
check; `git diff --check`; secret/private-data review (theme values only —
no profile data, cookies, or history near Git).

## Runtime results (honest)

- Files in place, ownership clean, scheme setting read back.
- **No visual inspection possible from this shell** (no display path;
  launching/restarting the user's apps unprompted would be intrusive).
  Zen rendering additionally waits on the pending pref + restart;
  Dolphin rendering waits on a restart/new window.

## Manual verification for the owner

1. Zen: `about:config` → enable stylesheets pref → restart → toolbox and
   selected tab navy+gold, urlbar dark, menus dark. Confirm vertical tabs,
   workspaces, and controls behave exactly as before.
2. Dolphin: restart (or new window) → dark background, readable names,
   navy selected rows, gold focus, working search/buttons/menus.
3. If anything regresses, keep the files and report before editing.

## Backup and rollback

Pre-deploy backup holds the prior `chrome/` (zen-themes.css only);
`kdeglobals` and user schemes did not exist. Rollback: preserve themed
files aside; delete the added `userChrome.css`, `Archther.colors`, and the
`ColorScheme` key (or the created `kdeglobals` if still single-key);
restart the apps; `diff -r` against backup to confirm. Revert in-repo via
`git revert` on a new branch.

## Deferred

Zen vertical-tab/workspace-specific selectors (only if visuals show gaps),
Dunst action flows, screenshot sharing, remaining app theming.
