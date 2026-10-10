-- Archther Dark theme tokens for Hyprland (Hyprland 0.56 Lua API).
--
-- Pure-data module: returns a table, performs no hl.* calls, registers no
-- bindings, launches nothing. Canonical hex values live here once; the
-- `hypr` subtable maps them to the exact representations the installed
-- Hyprland API accepts (verified: gradient = { colors = {...}, angle },
-- 0.56 Variables documentation). Future applications (Kitty, Wofi, Dunst,
-- Waybar) consume the canonical tokens, never copies.

local T = {}

-- Canonical Archther palette (see context/ui-tokens.md).
T.navy       = "0B2A6F" -- Archther navy brand color
T.gold       = "E8A11C" -- Archther gold brand accent
T.background = "0B0F14" -- main dark background
T.cyan       = "38BDF8" -- focus/highlight accent, used sparingly

-- Derived token: navy darkened (~60%) for unfocused window chrome.
-- Documented here because the task requires a muted navy tone and the
-- canonical palette defines no unfocused-border value.
T.navy_dim = "071A46"

-- Hyprland-ready mappings. Alpha "ee" keeps borders near-opaque, matching
-- the stock configuration's opacity behaviour; angle 45 preserves the
-- stock gradient direction.
T.hypr = {
    active_border = {
        colors = { "rgba(" .. T.navy .. "ee)", "rgba(" .. T.gold .. "ee)" },
        angle  = 45,
    },
    inactive_border = "rgba(" .. T.navy_dim .. "ff)",
}

return T
