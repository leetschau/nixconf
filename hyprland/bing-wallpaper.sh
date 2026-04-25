#!/bin/sh

if ! swww query > /dev/null 2>&1; then
    swww-daemon &
    until swww query > /dev/null 2>&1; do
        sleep 0.2
    done
fi

WALLPAPER_DIR="$HOME/.cache/hyprland-wallpaper"
mkdir -p "$WALLPAPER_DIR"

IMG_URL=$(curl -s "https://www.bing.com/HPImageArchive.aspx?format=js&n=1&mkt=en-US" | jq -r '.images[0].url')

if [ -z "$IMG_URL" ] || [ "$IMG_URL" = "null" ]; then
    exit 1
fi

# Strip query params for a clean filename
FILENAME=$(basename "$IMG_URL" | cut -d'&' -f1)
OUTFILE="$WALLPAPER_DIR/$FILENAME"

curl -s -L -o "$OUTFILE" "https://www.bing.com${IMG_URL}"

if [ -f "$OUTFILE" ]; then
    swww img "$OUTFILE" --transition-type fade --transition-duration 2
fi
