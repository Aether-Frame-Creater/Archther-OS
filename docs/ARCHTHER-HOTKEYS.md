# Archther Hotkeys

Authoritative shortcut reference for Archther OS.

This document lists the shortcuts that are **actually registered in the live
Hyprland configuration** on this machine. It was generated from
`hyprctl binds` (96 bindings, zero duplicate `(modmask, key)` pairs) after the
navigation work was deployed, so it reflects the running desktop rather than an
intended design.

Press **`SUPER + K`** to open this document in a terminal window.

- Compositor: Hyprland 0.56.2-4 (Lua configuration API)
- Main modifier: `SUPER` (the Windows key)
- Source of truth: `config/hypr/modules/*.lua`

Anything not listed here is not bound. Deliberately unbound items are listed
under [Deferred and unavailable](#deferred-and-unavailable).

---

## Navigation menu and launching

| Shortcut | Action |
|---|---|
| `SUPER + SPACE` | Archther navigation menu |
| `SUPER + R` | Wofi application launcher (`.desktop` entries) |
| `SUPER + RETURN` | Launch Kitty terminal |
| `SUPER + SHIFT + RETURN` | Launch Zen Browser |
| `SUPER + E` | Launch Nautilus (file manager) |
| `SUPER + SHIFT + F` | Launch Nautilus (second shortcut) |
| `SUPER + K` | Open this hotkey reference |
| `SUPER + M` | Exit the session |

The navigation menu offers Applications, Terminal, Browser, File Manager,
Region Screenshot, Full Screenshot, Hotkey Reference, and Exit. It maps each
entry to one fixed action; Escape or an empty selection does nothing.
`SUPER + R` remains the direct launcher and is not replaced by the menu.

`SUPER + CTRL + T` (system monitor) is **not bound**: `btop` is available in the
official `extra` repository but is not installed on this machine, so no dead
shortcut is registered. Installing `btop` enables it automatically on the next
reload.

## Window focus and movement

| Shortcut | Action |
|---|---|
| `SUPER + LEFT/RIGHT/UP/DOWN` | Focus the adjacent window |
| `SUPER + SHIFT + LEFT/RIGHT/UP/DOWN` | Swap the active window with its neighbour |
| `SUPER + LEFT MOUSE` | Drag the window under the cursor |
| `SUPER + RIGHT MOUSE` | Resize the window under the cursor |

Directional focus also moves the cursor to the centre of the window that
receives focus. Swapping is a separate operation from focusing: the windows
exchange positions and focus stays where it was.

## Tiling, floating and fullscreen

| Shortcut | Action |
|---|---|
| `SUPER + T` | Toggle the floating state of the window |
| `SUPER + V` | Toggle floating (original binding, kept as an alias of `SUPER + T`) |
| `SUPER + J` | Switch the active split between horizontal and vertical |
| `SUPER + P` | Toggle pseudo-window mode |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + ALT + F` | Toggle full width (keeps the top bar visible) |
| `SUPER + CTRL + F` | Toggle fullscreen within the current container |

`SUPER + ALT + F` is Hyprland's `maximized` mode: the window fills the work
area and any reserved bar space stays visible. `SUPER + CTRL + F` sets the
client-side fullscreen state only, leaving the compositor layout untouched.

## Window resizing

| Shortcut | Action |
|---|---|
| `SUPER + MINUS` / `SUPER + EQUAL` | Resize horizontally (10 px per press) |
| `SUPER + SHIFT + MINUS` / `SUPER + SHIFT + EQUAL` | Resize vertically (10 px) |
| `SUPER + ALT + MINUS` / `SUPER + ALT + EQUAL` | Smaller vertical step (5 px) |
| `SUPER + CTRL + MINUS` / `SUPER + CTRL + EQUAL` | Larger vertical step (20 px) |

Resize keys repeat while held. Hyprland clamps the result to the usable work
area, so a window is never resized outside the display. The same steps apply to
tiled and floating windows.

## Workspaces

| Shortcut | Action |
|---|---|
| `SUPER + 1..0` | Switch to workspace 1-10 |
| `SUPER + SHIFT + 1..0` | Move the active window to that workspace and follow it |
| `SUPER + TAB` | Go to the next workspace with windows |
| `SUPER + SHIFT + TAB` | Go to the previous workspace with windows |
| `SUPER + CTRL + TAB` | Return to the previously focused window |
| `SUPER + SHIFT + ALT + 1..4` | Move the active window to that workspace and stay here |
| `SUPER + SCROLL DOWN` / `SUPER + SCROLL UP` | Cycle through workspaces with the mouse wheel |

`SUPER + CTRL + TAB` returns to the last focused window, which is what makes it
useful when you have moved a window to another workspace and want to come back.

## Layout switching

| Shortcut | Action |
|---|---|
| `SUPER + L` | Switch between the dwindle and scrolling tiled layouts |

Scrolling layout ships with Hyprland 0.56.2; no plugin is installed or needed.

The layout choice is remembered per workspace and reapplied when you switch to
that workspace. The preference is rebuilt from the configured default on
reload, so it does not survive a logout.

## Window grouping

| Shortcut | Action |
|---|---|
| `SUPER + G` | Toggle grouping on the focused window |
| `SUPER + ALT + G` | Take the focused window out of its group |
| `SUPER + CTRL + LEFT/RIGHT` | Focus the previous/next window in the group |
| `SUPER + ALT + 1..4` | Focus the grouped window at that position |
| `SUPER + ALT + LEFT/RIGHT/UP/DOWN` | Merge the window into the group on that side |

Grouping requires a neighbouring window in the chosen direction. A group is
taken apart by removing its members with `SUPER + ALT + G`, or by toggling
grouping off on a member.

## Pinned windows

| Shortcut | Action |
|---|---|
| `SUPER + O` | Pin the active window |

The window is floated and pinned, so it stays visible while you switch
workspaces. Pressing the key again unpins it.

## Scratchpad

| Shortcut | Action |
|---|---|
| `SUPER + S` | Toggle the scratchpad |
| `SUPER + GRAVE` | Toggle the scratchpad (alternate) |
| `SUPER + SHIFT + S` | Move the active window to the scratchpad |
| `SUPER + SHIFT + GRAVE` | Move the active window to the scratchpad (alternate) |
| `SUPER + ALT + S` | Move the active window to the scratchpad (alternate) |

All of these act on the same special workspace, so there is only ever one
scratchpad. A window in the scratchpad is hidden until you toggle it open, and
it returns to a normal workspace with `SUPER + SHIFT + 1..0`.

## Closing windows

| Shortcut | Action |
|---|---|
| `SUPER + W` | Close the active window |
| `SUPER + Q` | Close the active window |
| `SUPER + C` | Close the active window |

## Screenshots

| Shortcut | Action |
|---|---|
| `Print` | Capture the full screen |
| `SHIFT + Print` | Capture a selected region |

Images are saved to `~/Pictures/Screenshots`. Cancelling the region selection
with Escape exits without creating a file. Screenshots are announced with a
notification.

## Volume, microphone and brightness

These use the laptop's multimedia keys and work while the screen is locked.

| Key | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume up 5% |
| `XF86AudioLowerVolume` | Volume down 5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86MonBrightnessUp` | Brightness up 5% |
| `XF86MonBrightnessDown` | Brightness down 5% |
| `XF86AudioNext` | Next track |
| `XF86AudioPlay` | Play |
| `XF86AudioPause` | Pause |
| `XF86AudioPrev` | Previous track |

Volume and brightness run through `wpctl` and `brightnessctl`; media keys run
through `playerctl`. All three helpers are installed.

## Gestures

| Gesture | Action |
|---|---|
| Three-finger swipe left/right | Move between workspaces |

---

## Deferred and unavailable

These are **not bound**. They are listed so the absence is a decision on record
rather than a gap.

| Requested | Status |
|---|---|
| `SUPER + CTRL + T` — system monitor | Deferred. `btop` is in `extra` but not installed. Installing it enables the binding on reload. |
| `CTRL + ALT + DELETE` — close all windows | Not bound on purpose. It would discard unsaved work and a keystroke cannot confirm it safely. |
| `SUPER + ALT + HOME` / `SUPER + HOME` — save and restore window width | Not available. Hyprland 0.56.2 has no dispatcher that stores a window dimension. |
| `SUPER + SHIFT + ALT + arrows` — move workspaces between monitors | Not bound. Needs a monitor selector and this machine has a single output (`eDP-1`). |

### Not runtime-tested

The shortcuts above were verified through the compositor's own dispatcher API
(`hyprctl repl`) rather than by physically pressing each key. Behaviour that was
confirmed live:

- the full set of 96 bindings is registered with no duplicates;
- focus, swap, split orientation, resize steps, float/pseudo/fullscreen modes,
  grouping, pinning, scratchpad, and layout switching all produce the expected
  compositor state changes;
- the navigation menu renders in the real Wayland session.

Still awaiting a manual pass at the keyboard: the physical key feel of each
combination, cursor follow during rapid arrow navigation, the visual appearance
of the menu, and audible confirmation of the volume and media keys.
