#!/bin/bash

set -eu -o pipefail

# we only use firefox and firefox based browsers in this house
PROFILE_DIR="$HOME/.local/share/ice/firefox"

PID=$(ps aux | pgrep -f "[librewolf\|firefox] \-\-class WebApp-$2" || true)

if [ -z "$PID" ]; then
    librewolf \
        --class "WebApp-$2" \
        --name "WebApp-$2" \
        --profile "$PROFILE_DIR/$2" \
        --no-remote "$3"
else
    WINID=$(wmctrl -lp |
        grep "$PID" |
        grep -v grep |
        awk '{print $1}')

    wmctrl -ia "$WINID"

    dunstify \
        --appname "launch-webapp" \
        --icon "emblem-important" \
        "WebApp Manager" "$1 is already running..."
fi
