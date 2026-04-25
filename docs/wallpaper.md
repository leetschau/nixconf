# Hyprland Wallpaper Setup

The wallpaper is set using [swww](https://github.com/LGFae/swww) with the daily Bing wallpaper.

## How it works

On startup, Hyprland runs two commands from `hyprland/programs.conf`:

1. `swww init` — initializes the swww daemon
2. `~/.config/hypr/bing-wallpaper.sh` — fetches and sets the Bing wallpaper

The script (`hyprland/bing-wallpaper.sh`):

1. Calls the Bing JSON API (`https://www.bing.com/HPImageArchive.aspx?format=js&n=1&mkt=en-US`) to get today's image URL
2. Downloads it with `curl`
3. Sets it as wallpaper via `swww img` with a 2-second fade transition

## Downloaded images

Images are saved to `~/.cache/hyprland-wallpaper/`. Since this is under `~/.cache`, they will be cleaned up by your system periodically.

## Manual usage

Refresh the wallpaper at any time:

```
~/.config/hypr/bing-wallpaper.sh
```
