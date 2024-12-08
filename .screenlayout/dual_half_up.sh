#!/bin/sh

xrandr \
    --output eDP-1 --primary --mode 1920x1080 --pos 5131x1250 --rotate normal \
    --output HDMI-1 --off \
    --output DP-1 --off \
    --output HDMI-2 --off \
    --output DP-2 --off \
    --output HDMI-3 --off \
    --output DP-3 --off \
    --output DP-2-1 --mode 2560x2880 --pos 2571x0 --rotate normal \
    --output DP-2-2 --mode 2560x1440 --pos 0x1440 --rotate normal \
    --output DP-2-3 --off

xwallpaper \
    --output eDP-1 --stretch ~/Projects/dots/wallpaper/kohi-3840x2160.png \
    --output DP-2-1 --stretch ~/Projects/dots/wallpaper/kohi-2560x2880.png \
    --output DP-2-2 --stretch ~/Projects/dots/wallpaper/kohi-3840x2160.png
