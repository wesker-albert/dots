#!/bin/bash

set -eu -o pipefail

ICON_PATH="/usr/share/sabnzbdplus/icons/logo-arrow.svg"
MSG_MAX_LENGTH=60
ELIPSES="…"

MSG=$(echo "$3" |
    awk -v len="$MSG_MAX_LENGTH" \
        '{ if (length($0) > len) print substr($0, 1, len) "'"$ELIPSES"'"; else print; }')

if [ "$1" == "failed" ] || [ "$1" == "error" ] || [ "$1" == "disk_full" ]; then
    dunstify \
        --urgency "critical" \
        --icon "$ICON_PATH" \
        "$2" "$MSG"
else
    dunstify \
        --icon "$ICON_PATH" \
        "$2" "$MSG"
fi
