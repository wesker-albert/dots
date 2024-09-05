#!/bin/bash

set -eu -o pipefail

PID=$(ps aux |
    pgrep -f "WebApp-$1" ||
    true)

if [ -z "$PID" ]; then
    gtk-launch "WebApp-$1.desktop"
else
    WINID=$(wmctrl -lp |
        grep "$PID" |
        grep -v grep |
        awk '{print $1}')

    wmctrl -ia "$WINID"
fi
