#!/bin/bash

set -eu -o pipefail

# we only use firefox and firefox based browsers in this house
PROFILE_DIR="$HOME/.local/share/ice/firefox"

PID=$(ps aux |
    pgrep -f "[librewolf\|firefox] \-\-class WebApp-$1" ||
    true)

if [ -z "$PID" ]; then
    librewolf \
        --class "WebApp-$1" \
        --name "WebApp-$1" \
        --profile "$PROFILE_DIR/$1" \
        --no-remote "$2"
else
    WINID=$(wmctrl -lp |
        grep "$PID" |
        grep -v grep |
        awk '{print $1}')

    wmctrl -ia "$WINID"
fi
