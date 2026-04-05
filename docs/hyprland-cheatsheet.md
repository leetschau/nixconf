# Hyprland Cheatsheet

## Mod Key
**SUPER** = Windows key

## Essential Keybindings

| Action | Keybind |
|---|---|
| Open terminal (konsole) | SUPER + Return |
| Close window | SUPER + Q |
| Quit Hyprland | SUPER + M |
| App launcher (wofi) | SUPER + Space |
| Toggle floating | SUPER + V |
| Toggle fullscreen | SUPER + F |
| Pseudotile | SUPER + P |
| Toggle split | SUPER + J |
| Lock screen | SUPER + L |
| Screenshot (area to clipboard) | SUPER + S |
| Re-detect monitors | SUPER + Escape |

## Window Management

| Action | Keybind |
|---|---|
| Move focus | SUPER + Arrow keys |
| Move window | SUPER + Shift + Arrow keys |
| Cycle windows | SUPER + Tab / SUPER + Shift + Tab |
| Move window (mouse) | SUPER + Left-click drag |
| Resize window (mouse) | SUPER + Right-click drag |

## Workspaces

| Action | Keybind |
|---|---|
| Switch to workspace N | SUPER + 1-0 (0 = workspace 10) |
| Move window to workspace N | SUPER + Shift + 1-0 |
| Scroll through workspaces | SUPER + scroll wheel |

## Screenshots

```bash
# Area select to clipboard (bound to SUPER + S)
grim -g "$(slurp)" - | wl-copy

# Full screen to file
grim ~/screenshot.png

# Area select to file
grim -g "$(slurp)" ~/screenshot.png
```

## Useful CLI Tools for Wayland/Hyprland

| Tool | Purpose |
|---|---|
| `wofi` | App launcher |
| `grim` + `slurp` | Screenshots |
| `wl-clipboard` | Clipboard (wl-copy/wl-paste) |
| `brightnessctl` | Brightness control |
| `pavucontrol` | Volume control GUI |
| `nm-applet` | Network tray icon |

## Config Location
`~/.config/hypr/hyprland.conf`

## Useful Commands
```bash
hyprctl version
hyprctl clients
hyprctl workspaces
hyprctl monitors
hyprctl dispatch exec [cmd]
hyprctl keyword [key] [val]
```

## Tips
- Hyprland is **Wayland only** - X11 apps run via XWayland automatically
- Use `exec-once` in hyprland.conf for autostart
- Config changes auto-reload on save (no restart needed)
- ESC and CapsLock are swapped
- 3-finger horizontal swipe switches workspaces
