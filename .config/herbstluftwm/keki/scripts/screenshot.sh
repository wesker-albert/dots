#!/bin/bash

set -eu -o pipefail

DIR="$HOME/Pictures/screenshots"
FILENAME="%Y-%m-%d_%H-%M-%S.png"
QUALITY=100

# shellcheck disable=SC2016
EXEC='echo $n'

_openAction() {
    gthumb "$1"
}

all_monitors() {
    _DUNST_TITLE="Captured all monitors:"
    SCREENSHOT=$(scrot \
        "$DIR/$FILENAME" \
        --exec "$EXEC" \
        --quality $QUALITY)
}

focused_monitor() {
    _DUNST_TITLE="Captured focused monitor:"
    CURRENT_MONITOR=$(herbstclient list_monitors |
        grep "FOCUS" |
        cut -c1-1)
    SCREENSHOT=$(scrot \
        "$DIR/$FILENAME" \
        --exec "$EXEC" \
        --quality $QUALITY \
        --monitor "$CURRENT_MONITOR")
}

focused_window() {
    _DUNST_TITLE="Captured focused window:"
    SCREENSHOT=$(scrot \
        "$DIR/$FILENAME" \
        --exec "$EXEC" \
        --quality $QUALITY \
        --focused \
        --border)
}

$1

ACTION=$(dunstify \
    --appname "scrot" \
    --icon "$DIR/$SCREENSHOT" \
    --action="default,Open" \
    "$_DUNST_TITLE" "$SCREENSHOT")

if [ "$ACTION" == "default" ]; then
    _openAction "$DIR/$SCREENSHOT"
fi
