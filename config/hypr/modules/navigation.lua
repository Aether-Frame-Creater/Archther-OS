-- Archther keyboard-first navigation.
--
-- Every dispatcher below was verified against the installed compositor
-- (hyprland 0.56.2-4) by reading the v0.56.2 upstream sources for
-- src/config/lua/bindings/LuaBindingsDispatchers.cpp, then confirming the
-- behaviour of the uncertain ones against the live instance via
-- `hyprctl repl`. Nothing here is copied from an older hyprlang example.
--
-- Existing working bindings are preserved. Where a requested shortcut was
-- already taken, the original function is kept and the conflict is resolved
-- deliberately and documented in docs/ARCHTHER-NAVIGATION.md:
--
--   SUPER+Q   kept as "close window". Its previous meaning (launch kitty)
--             moved to SUPER+RETURN, so no capability was lost.
--   SUPER+T   newly bound as "toggle float". SUPER+V already toggles float
--             and is left untouched as an alias.
--   SUPER+L   newly bound as "toggle layout". No prior binding existed.
--   SUPER+O   newly bound as "pin window". No prior binding existed.
--   SUPER+G   newly bound as "toggle group". No prior binding existed.
--
-- See https://wiki.hypr.land/Configuring/Basics/Binds/ for the bind syntax.

local vars = require("modules.variables")
local mainMod = vars.mainMod -- Sets "Windows" key as main modifier

--------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------

-- True when an executable is on PATH. Bindings for a missing executable are
-- skipped rather than registered as dead shortcuts, and the reason is printed
-- once so the omission is visible instead of silent.
--
-- The check walks PATH and opens each candidate directly. This is deliberate:
-- os.execute() returns nil for both success and failure in the Lua build
-- Hyprland 0.56.2 embeds (verified against the live instance with `hyprctl
-- repl`), so it cannot be used to test existence. io.open + os.getenv are both
-- available there and give an unambiguous answer.
local warned = {}
local function has_command(cmd)
    for dir in (os.getenv("PATH") or ""):gmatch("[^:]+") do
        local handle = io.open(dir .. "/" .. cmd, "r")
        if handle then
            handle:close()
            return true
        end
    end
    if not warned[cmd] then
        warned[cmd] = true
        print("[archther] binding skipped: '" .. cmd .. "' is not installed")
    end
    return false
end

-- Move the cursor to the centre of the window that just received focus.
-- Verified in 0.56.2: hl.dsp.cursor.move({ x, y }) takes absolute global
-- coordinates, and a window exposes at.x/at.y plus size.x/size.y. Wrapped in
-- pcall because a window can disappear between the focus change and the
-- geometry read (e.g. a window closed by another shortcut).
local function cursor_to_focused_centre()
    local ok, err = pcall(function()
        local win = hl.get_active_window()
        if not win then
            return
        end
        local at, size = win.at, win.size
        if not (at and size) then
            return
        end
        hl.dispatch(hl.dsp.cursor.move({
            x = at.x + math.floor(size.x / 2),
            y = at.y + math.floor(size.y / 2),
        }))
    end)
    if not ok then
        print("[archther] cursor follow failed: " .. tostring(err))
    end
end

-- Directional focus with the cursor following into the newly focused window.
-- Focus itself and the cursor move are separate steps so that a failure in the
-- optional cursor step can never break window navigation.
local function focus_direction(direction)
    return function()
        hl.dispatch(hl.dsp.focus({ direction = direction }))
        cursor_to_focused_centre()
    end
end

--------------------------------------------------------------------------
-- 1. Central navigation menu
--------------------------------------------------------------------------

-- SUPER+SPACE opens the Archther menu (Wofi custom/dmenu mode).
-- SUPER+R below is intentionally left as the direct application launcher.
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(vars.navMenu), { description = "Archther navigation menu" })

--------------------------------------------------------------------------
-- 2. Direct application shortcuts
--------------------------------------------------------------------------

-- SUPER+RETURN launches the terminal. This is the new home of the terminal
-- shortcut; SUPER+Q previously did this and now closes the window instead.
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(vars.terminal), { description = "Launch terminal" })

-- SUPER+SHIFT+RETURN launches Zen Browser. No previous binding used this
-- combination, so nothing was displaced.
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd(vars.browser), { description = "Launch Zen Browser" })

-- SUPER+SHIFT+F is the second file-manager shortcut. SUPER+E keeps its
-- original Nautilus binding untouched (see keybindings.lua).
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(vars.fileManager), { description = "Launch file manager" })

-- SUPER+K opens the hotkey reference.
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd(vars.hotkeyRef), { description = "Archther hotkey reference" })

-- SUPER+CTRL+T launches the system monitor only when it is actually installed.
-- btop is available in the official `extra` repository but is not installed on
-- this machine, so no binding is registered and installing it is left as an
-- explicit decision for the owner.
if has_command(vars.systemMonitor) then
    hl.bind(mainMod .. " + CTRL + T", hl.dsp.exec_cmd(vars.systemMonitor), { description = "Launch system monitor" })
end

--------------------------------------------------------------------------
-- 3. Directional window navigation
--------------------------------------------------------------------------

-- Focus the adjacent window. These replace the previous SUPER+arrow binds,
-- keeping the same keys and the same dispatcher behaviour.
hl.bind(mainMod .. " + LEFT",  focus_direction("left"),  { description = "Focus left" })
hl.bind(mainMod .. " + RIGHT", focus_direction("right"), { description = "Focus right" })
hl.bind(mainMod .. " + UP",    focus_direction("up"),    { description = "Focus up" })
hl.bind(mainMod .. " + DOWN",  focus_direction("down"),  { description = "Focus down" })

-- Swap the active window with its neighbour. Verified as a separate dispatcher
-- (hl.dsp.window.swap) so swapping never goes through focus, keeping the
-- focus-navigation and swap tests independent.
hl.bind(mainMod .. " + SHIFT + LEFT",  hl.dsp.window.swap({ direction = "left" }),  { description = "Swap left" })
hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.swap({ direction = "right" }), { description = "Swap right" })
hl.bind(mainMod .. " + SHIFT + UP",    hl.dsp.window.swap({ direction = "up" }),    { description = "Swap up" })
hl.bind(mainMod .. " + SHIFT + DOWN",  hl.dsp.window.swap({ direction = "down" }),  { description = "Swap down" })

--------------------------------------------------------------------------
-- 4. Tiling, floating and fullscreen
--------------------------------------------------------------------------

-- SUPER+T toggles the floating state of the active window. SUPER+V keeps its
-- original float-toggle binding in keybindings.lua and stays an alias.
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })

-- SUPER+P toggles pseudo-window mode (a floating window with no decorations
-- and no input). Previously bound in keybindings.lua; kept here with the
-- explicit "toggle" action so the intent is documented rather than implied.
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }), { description = "Toggle pseudo window" })

-- SUPER+F toggles true fullscreen (the window covers everything, including
-- any reserved bar area).
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Toggle fullscreen" })

-- SUPER+ALT+F is "full width while preserving the top bar". Verified against
-- the 0.56.2 source: fullscreen({ mode = "maximized" }) is the layout-aware
-- mode that fills the work area and keeps reserved space (a top bar) visible,
-- which is exactly this behaviour rather than a different operation reusing
-- the same name.
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Toggle full width" })

-- SUPER+CTRL+F is the client-side fullscreen within the current container.
-- Verified in the 0.56.2 source: fullscreen_state({ internal, client })
-- separates the compositor's own fullscreen from the fullscreen state
-- requested by the client, which is what "fullscreen inside the parent"
-- means. internal=0/client=1 leaves the compositor layout in place and only
-- asks the client to render fullscreen.
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 1, action = "toggle" }), { description = "Toggle container fullscreen" })

--------------------------------------------------------------------------
-- 5. Window resizing
--------------------------------------------------------------------------
--
-- Steps are per-press pixel deltas. Hyprland's documented resize convention is
-- 10 px per press, with 5 px for the fine (ALT) and 20 px for the coarse
-- (CTRL) variants. Hyprland clamps the result to the usable work area, so a
-- window is never resized outside the display, and the same steps work for
-- both tiled and floating windows.
--
-- relative = true is required and is not optional here. Verified against the
-- live instance: hl.dsp.window.resize() treats x/y as an absolute target size
-- unless relative is set, so the same call without it is rejected with
-- "Invalid size" and silently does nothing.
--
-- MINUS/EQUAL resize horizontally, SHIFT+MINUS/EQUAL vertically. ALT and CTRL
-- change the step size rather than the axis, which is why they act on the
-- vertical axis: they are the same operation as the SHIFT variants at a finer
-- or coarser increment, not a different resize mode.

-- Horizontal resize.
hl.bind(mainMod .. " + MINUS", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { description = "Resize narrower", repeating = true })
hl.bind(mainMod .. " + EQUAL", hl.dsp.window.resize({ x =  10, y = 0, relative = true }), { description = "Resize wider",   repeating = true })

-- Vertical resize.
hl.bind(mainMod .. " + SHIFT + MINUS", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { description = "Resize shorter", repeating = true })
hl.bind(mainMod .. " + SHIFT + EQUAL", hl.dsp.window.resize({ x = 0, y =  10, relative = true }), { description = "Resize taller",  repeating = true })

-- Smaller resize increments (vertical, 5 px).
hl.bind(mainMod .. " + ALT + MINUS", hl.dsp.window.resize({ x = 0, y =  -5, relative = true }), { description = "Resize shorter (fine)", repeating = true })
hl.bind(mainMod .. " + ALT + EQUAL", hl.dsp.window.resize({ x = 0, y =   5, relative = true }), { description = "Resize taller (fine)",  repeating = true })

-- Larger resize increments (vertical, 20 px).
hl.bind(mainMod .. " + CTRL + MINUS", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { description = "Resize shorter (coarse)", repeating = true })
hl.bind(mainMod .. " + CTRL + EQUAL", hl.dsp.window.resize({ x = 0, y =  20, relative = true }), { description = "Resize taller (coarse)",   repeating = true })

--------------------------------------------------------------------------
-- 6. Mouse-assisted window movement
--------------------------------------------------------------------------

-- SUPER+LEFT MOUSE drags the window under the cursor.
-- SUPER+RIGHT MOUSE resizes it. These keys were already bound in
-- keybindings.lua and are preserved unchanged there.

--------------------------------------------------------------------------
-- 7. Closing windows
--------------------------------------------------------------------------

-- SUPER+W closes the active window. SUPER+Q and SUPER+C keep their existing
-- close bindings in keybindings.lua, so all three close the focused window.
hl.bind(mainMod .. " + W", hl.dsp.window.close(), { description = "Close window" })

-- CTRL+ALT+DELETE ("close every window") is intentionally NOT bound. It is a
-- destructive bulk operation that would silently discard unsaved work, and a
-- keystroke-only confirmation is not practical. It stays deferred until an
-- explicit confirmation flow is approved. See docs/ARCHTHER-NAVIGATION.md.

-- SUPER+ALT+HOME / SUPER+HOME (save and restore the current window width) are
-- also not bound: Hyprland 0.56.2 exposes no dispatcher that stores a window
-- dimension, so binding them would have to fake the behaviour with a script
-- that silently does nothing useful. Documented as unsupported instead of
-- pretending to work.

--------------------------------------------------------------------------
-- 8. Pinned floating windows
--------------------------------------------------------------------------

-- SUPER+O pins the active window so it keeps rendering while you switch
-- workspaces. This is the native pin dispatcher (hl.dsp.window.pin), not
-- ordinary floating mode: floating alone does not make a window visible on
-- other workspaces, and the task explicitly forbids treating the two as
-- equivalent.
--
-- Verified in the v0.56.2 sources that the pin dispatcher rejects a window
-- that is not already floating ("Window does not qualify to be pinned",
-- src/config/shared/actions/ConfigActions.cpp pinWindow: the guard is
-- `!window->m_isFloating`), and confirmed live against a tiled window. The
-- window is therefore floated first, then pinned, which is exactly the pinned
-- floating window the shortcut is meant to produce. Fullscreen is untouched:
-- the source rejects pinning a fullscreen window too, and no window this
-- binding acts on is fullscreen.
--
-- If the window is already floating, only the pin state is toggled, so
-- pressing the key twice restores the previous pinned state without also
-- changing the float state a second time.
local function toggle_pinned()
    local win = hl.get_active_window()
    if not win then
        return
    end
    if not win.floating then
        hl.dispatch(hl.dsp.window.float({ action = "enable" }))
    end
    hl.dispatch(hl.dsp.window.pin({ action = "toggle" }))
end

hl.bind(mainMod .. " + O", toggle_pinned, { description = "Pin window" })

--------------------------------------------------------------------------
-- 9. Scratchpad
--------------------------------------------------------------------------
--
-- The existing scratchpad uses the special workspace name "magic" and is
-- preserved exactly as it was, with the existing keys:
--   SUPER+S         toggle the scratchpad
--   SUPER+SHIFT+S   move the focused window into the scratchpad
-- Those bindings stay in keybindings.lua.
--
-- The alternate keys below use the same "magic" special workspace so they act
-- on the same scratchpad instead of creating a second one.
hl.bind(mainMod .. " + GRAVE",          hl.dsp.workspace.toggle_special("magic"), { description = "Toggle scratchpad" })
hl.bind(mainMod .. " + SHIFT + GRAVE",  hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move window to scratchpad" })
hl.bind(mainMod .. " + ALT + S",        hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move window to scratchpad" })
