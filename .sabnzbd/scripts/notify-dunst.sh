#!/bin/bash

set -eu -o pipefail

ICON_PATH="/usr/share/sabnzbdplus/icons"
MSG_MAX_LENGTH=64
ELIPSES="…"

MSG=$(echo "$3" |
    awk -v len="$MSG_MAX_LENGTH" \
        '{ if (length($0) > len) print substr($0, 1, len) "'"$ELIPSES"'"; else print; }')

if [ "$1" == "failed" ] || [ "$1" == "error" ] || [ "$1" == "disk_full" ]; then
    dunstify \
        --urgency "critical" \
        --icon "$ICON_PATH/logo-arrow.svg" \
        "$2" "$MSG"
elif [ "$1" == "complete" ] || [ "$1" == "queue_done" ]; then
    dunstify \
        --icon "$ICON_PATH/logo-arrow_green.svg" \
        "$2" "$MSG"
else
    dunstify \
        --icon "$ICON_PATH/logo-arrow.svg" \
        "$2" "$MSG"
fi
