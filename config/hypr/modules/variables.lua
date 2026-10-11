-- Shared constants for the Archther Hyprland configuration.
--
-- Pure-data module: returns a table, performs no hl.* calls, so it is safe
-- for every consumer to require it (Lua caches the table after first load).
-- Change an application command here once instead of in every binding.

local M = {}

M.mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Set programs that you use
M.terminal    = "kitty"
M.fileManager = "nautilus"

-- Zen Browser (zen-browser-bin AUR package). Verified: the executable on this
-- machine is /usr/bin/zen-browser, which execs /opt/zen-browser-bin/zen-bin.
-- The package also ships a /usr/bin/zen-browser wrapper; there is no `zen`
-- binary on PATH, so binding "zen" would silently fail.
M.browser = "zen-browser"

-- System monitor. Present in the official `extra` repository but NOT installed
-- on this machine (verified: `command -v btop` fails, `pacman -Qs btop` empty).
-- Declared here so the binding is registered only once the package exists,
-- instead of binding a shortcut to a command that cannot run.
M.systemMonitor = "btop"

-- Application launcher. Stock config used "hyprlauncher", which is not
-- installed; Wofi is the Archther launcher (verified: /usr/bin/wofi v1.5.3,
-- drun mode launches .desktop entries).
M.menu = "/usr/bin/wofi --show drun"

-- Archther helpers deployed to ~/.local/bin (see docs/HYPRLAND-IMPLEMENTATION.md).
-- $HOME is expanded by the shell Hyprland uses for exec commands, so these stay
-- correct outside the Git working tree. Existence is checked before binding.
M.binDir    = "$HOME/.local/bin"
M.navMenu   = M.binDir .. "/archther-menu"
M.hotkeyRef = M.binDir .. "/archther-hotkeys"

return M
