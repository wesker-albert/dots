#!/bin/bash
# ----------
# Reload herbstluftwm

killall -q polybar &
killall -q compton &
herbstclient reload 
