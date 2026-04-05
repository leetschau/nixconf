#!/bin/sh

HDMI=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.name | startswith("HDMI")) | .name' | head -1)

if [ -n "$HDMI" ]; then
    hyprctl keyword monitor eDP-1,disable
    hyprctl keyword monitor "$HDMI",preferred,0x0,1
else
    hyprctl keyword monitor eDP-1,preferred,0x0,1
fi
