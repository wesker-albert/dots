#!/bin/bash

set -eu -o pipefail

ICON_PATH="/usr/share/icons/hicolor/scalable/apps/org.nicotine_plus.Nicotine.svg"
MSG_MAX_LENGTH=60
ELIPSES="…"

MSG=$(echo "$1" |
    sed "s:.*/::" |
    awk -v len="$MSG_MAX_LENGTH" \
        '{ if (length($0) > len) print substr($0, 1, len) "'"$ELIPSES"'"; else print; }')


dunstify \
    --icon "$ICON_PATH" \
    "Folder Downloaded" "$MSG"
