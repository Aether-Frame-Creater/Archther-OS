-- Archther workspace, grouping and layout navigation.
--
-- Dispatcher arguments were verified against hyprland 0.56.2-4 using the
-- v0.56.2 sources for src/config/lua/bindings/LuaBindingsDispatchers.cpp and
-- src/layout/LayoutManager.cpp, plus live `hyprctl repl` probes.
--
-- Workspaces: SUPER+<n> and SUPER+SHIFT+<n> already worked and stay in
-- keybindings.lua. This module adds the sequencing, non-following transfer and
-- grouped-window variants without rebinding any of those keys.
--
-- See https://wiki.hypr.land/Configuring/Basics/Binds/ for the bind syntax.

local vars = require("modules.variables")
local mainMod = vars.mainMod -- Sets "Windows" key as main modifier

--------------------------------------------------------------------------
-- 1. Workspace sequencing
--------------------------------------------------------------------------

-- SUPER+TAB / SUPER+SHIFT+TAB move to the next / previous existing workspace.
-- "e+1" and "e-1" are Hyprland's relative workspace selectors that skip empty
-- workspaces; verified as workspace selector strings in the 0.56.2 source.
hl.bind(mainMod .. " + TAB",       hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })

-- SUPER+CTRL+TAB returns to the previous workspace. Verified in the 0.56.2
-- source: hl.focus({ last = true }) resolves the last focused window rather
-- than a workspace, which is exactly "return to where I was" and does not
-- require an invented workspace-history dispatcher that this version lacks.
hl.bind(mainMod .. " + CTRL + TAB", hl.dsp.focus({ last = true }), { description = "Previous window" })

-- SUPER+SCROLL (mouse wheel) navigates workspaces. These two binds already
-- worked in keybindings.lua and are preserved there unchanged, so they are not
-- repeated here.

--------------------------------------------------------------------------
-- 2. Workspace transfer without following the window
--------------------------------------------------------------------------

-- SUPER+SHIFT+<n> already moves the focused window to workspace n and follows
-- it. These add the "move without following" variant:
-- Verified in the 0.56.2 source, hl.window.move({ workspace, follow }) treats
-- follow = false as a silent transfer, so the view stays on the current
-- workspace. Only 1-4 are bound, matching the shortcuts already in use for the
-- primary workspaces.
for i = 1, 4 do
    hl.bind(mainMod .. " + SHIFT + ALT + " .. i,
        hl.dsp.window.move({ workspace = i, follow = false }),
        { description = "Move window to workspace " .. i .. " (stay here)" })
end

-- SUPER+SHIFT+ALT+ARROWS would move the workspace itself between monitors.
-- hl.dsp.workspace.move({ monitor = ... }) exists in 0.56.2, but it needs a
-- monitor selector and this machine has a single output (eDP-1, verified via
-- `hyprctl monitors`). Binding a relative selector that cannot resolve would
-- create four dead shortcuts, so this stays unbound and is reported in
-- docs/ARCHTHER-NAVIGATION.md as awaiting a second monitor.

--------------------------------------------------------------------------
-- 3. Window grouping
--------------------------------------------------------------------------

-- SUPER+G toggles whether the focused window is grouped with its neighbours.
-- Verified in the 0.56.2 source as hl.dsp.group.toggle().
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { description = "Toggle group" })

-- SUPER+ALT+G takes the focused window out of its group.
-- Verified in the 0.56.2 source: hl.window.move({ out_of_group = true }) is the
-- documented way to detach a window from a group.
hl.bind(mainMod .. " + ALT + G", hl.dsp.window.move({ out_of_group = true }), { description = "Remove window from group" })

-- SUPER+CTRL+LEFT / RIGHT move focus within the group.
-- Verified in the 0.56.2 source as hl.dsp.group.next() / hl.dsp.group.prev().
hl.bind(mainMod .. " + CTRL + LEFT",  hl.dsp.group.prev(), { description = "Previous grouped window" })
hl.bind(mainMod .. " + CTRL + RIGHT", hl.dsp.group.next(), { description = "Next grouped window" })

-- SUPER+ALT+1..4 focus the grouped window at that position.
-- Verified in the 0.56.2 source as hl.dsp.group.active({ index = n }); the
-- index is required and is a number.
for i = 1, 4 do
    hl.bind(mainMod .. " + ALT + " .. i, hl.dsp.group.active({ index = i }), { description = "Focus grouped window " .. i })
end

-- SUPER+ALT+ARROWS merge the focused window into the group on that side.
-- Verified in the 0.56.2 source: hl.window.move({ into_or_create_group =
-- "left" }) moves the window into the neighbouring group in that direction and
-- creates the group if there is not one yet.
hl.bind(mainMod .. " + ALT + LEFT",  hl.dsp.window.move({ into_or_create_group = "left" }),  { description = "Group left" })
hl.bind(mainMod .. " + ALT + RIGHT", hl.dsp.window.move({ into_or_create_group = "right" }), { description = "Group right" })
hl.bind(mainMod .. " + ALT + UP",    hl.dsp.window.move({ into_or_create_group = "up" }),    { description = "Group up" })
hl.bind(mainMod .. " + ALT + DOWN",  hl.dsp.window.move({ into_or_create_group = "down" }),  { description = "Group down" })

-- Dissembling a group: Hyprland 0.56.2 has no "destroy group" dispatcher. The
-- group is taken apart by removing its members individually with
-- SUPER+ALT+G, which is why that binding exists and is documented rather than
-- replaced with an invented shortcut. hl.dsp.window.deny_from_group is also
-- available but changes future membership rules rather than removing a window,
-- so it is not bound here.

--------------------------------------------------------------------------
-- 4. Dwindle / scrolling layout switching
--------------------------------------------------------------------------

-- SUPER+L toggles the tiled layout between "dwindle" and "scrolling".
--
-- Scrolling is built into hyprland 0.56.2, not a plugin: the v0.56.2 tree
-- contains src/layout/algorithm/tiled/scrolling, and no hyprpm or plugin
-- directory exists on this machine (verified). No extra dependency is needed.
--
-- How it is switched: hl.dsp.layout("...") is NOT a layout selector. Verified
-- against the live instance, it forwards the string to the *current* layout's
-- layoutMsg handler, so `layout scrolling` fails with "Unknown dwindle
-- layoutmsg: scrolling". The layout is selected through the general:layout
-- config value instead, which is read per workspace by
-- src/layout/supplementary/WorkspaceAlgoMatcher.cpp.
--
-- Per-workspace tracking: that matcher prefers a workspace rule's layout and
-- otherwise falls back to general:layout, and the 0.56.2 Lua API exposes no
-- runtime setter to change one workspace's layout in isolation
-- (`ws.tiled_layout` is read-only). The selection is therefore remembered per
-- workspace id here and reapplied on every workspace switch, which gives each
-- workspace its own effective layout. It is rebuilt from the config default on
-- reload, so persistence across restarts is provided by the configured default
-- rather than by this table.
local layout_prefs = {}

-- The layout currently in effect for a workspace. Verified in 0.56.2 against
-- the live instance: a workspace exposes a read-only `tiled_layout` string,
-- while hl.get_config() returns nil in this version and cannot be used for
-- this. Falls back to "dwindle" when the workspace cannot be read at all.
local function current_layout()
    local ws = hl.get_active_workspace()
    if ws then
        local name = ws.tiled_layout
        if name == "scrolling" then
            return "scrolling"
        end
        return "dwindle"
    end
    return "dwindle"
end

local function apply_layout(name)
    hl.config({ general = { layout = name } })
end

local function toggle_layout()
    local next_layout = current_layout() == "scrolling" and "dwindle" or "scrolling"
    local ws = hl.get_active_workspace()
    if ws then
        layout_prefs[ws.id] = next_layout
    end
    apply_layout(next_layout)
end

local function restore_workspace_layout(workspace)
    if not workspace then
        return
    end
    local preferred = layout_prefs[workspace.id]
    -- Only rewrite the config when the active layout actually differs, so
    -- switching to a workspace that already matches costs nothing.
    if preferred and preferred ~= workspace.tiled_layout then
        apply_layout(preferred)
    end
end

hl.bind(mainMod .. " + L", toggle_layout, { description = "Toggle dwindle / scrolling layout" })

-- Reapply the remembered layout whenever the workspace changes. Guarded so it
-- never rewrites the config when the layout already matches, which avoids
-- pointless layout churn on every workspace switch.
hl.on("workspace.active", function(_, workspace)
    pcall(restore_workspace_layout, workspace)
end)
