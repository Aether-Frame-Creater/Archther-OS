-- Keyboard shortcuts, migrated verbatim from the stock configuration with
-- one authorized fix: SUPER+R now launches Wofi instead of the missing
-- "hyprlauncher" executable (see modules/variables.lua).
-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
--
-- The Archther navigation shortcuts (SUPER+arrows with cursor following,
-- SUPER+SHIFT+arrows swap, SUPER+T/P/F, resizing, the menu, the direct
-- application launchers) live in modules/navigation.lua, which this file does
-- not require: the entry point loads it. The few bindings removed here were
-- moved there, not deleted, so there is exactly one definition per key:
--
--   SUPER+arrows  moved to navigation.lua (focus + cursor follow)
--   SUPER+P       moved to navigation.lua (pseudo, explicit toggle action)
--   SUPER+Q       reassigned from "launch kitty" to "close window"; the
--                 terminal shortcut is preserved as SUPER+RETURN
--
-- SUPER+J (split orientation) and SUPER+V (toggle float) stay here because they
-- predate the navigation work; navigation.lua deliberately does not rebind
-- them, so the working originals are untouched.

local vars = require("modules.variables")
local mainMod = vars.mainMod -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(vars.fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(vars.menu))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

-- Close the active window. SUPER+C previously did this; both are kept because
-- both were requested and neither displaces another working binding.
-- SUPER+W is bound in navigation.lua.
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + C", hl.dsp.window.close())

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Screenshots via Archther helpers (installed to ~/.local/bin at deploy).
-- SUPER+SHIFT+S was considered but is already the scratchpad move binding,
-- so bare Print / SHIFT+Print follow the GNOME convention instead.
-- $HOME expansion relies on the shell Hyprland uses for exec commands.
hl.bind("Print",         hl.dsp.exec_cmd("$HOME/.local/bin/archther-screenshot-full"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("$HOME/.local/bin/archther-screenshot-region"))
