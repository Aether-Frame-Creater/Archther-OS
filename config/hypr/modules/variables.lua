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

-- Application launcher. Stock config used "hyprlauncher", which is not
-- installed; Wofi is the Archther launcher (verified: /usr/bin/wofi v1.5.3,
-- drun mode launches .desktop entries).
M.menu = "/usr/bin/wofi --show drun"

return M
