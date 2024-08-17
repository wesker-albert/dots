#!/bin/bash

set -eu -o pipefail

TITLE="SABnzbd"
ICON_PATH="/usr/share/sabnzbdplus/icons"

if [ "$1" == "failed" ] || [ "$1" == "error" ] || [ "$1" == "disk_full" ]; then
    dunstify \
        --urgency "critical" \
        --icon "$ICON_PATH/logo-arrow.svg" \
        "$TITLE" "$3"
elif [ "$1" == "complete" ] || [ "$1" == "queue_done" ]; then
    dunstify \
        --icon "$ICON_PATH/logo-arrow_green.svg" \
        "$TITLE" "$3"
else
    dunstify \
        --icon "$ICON_PATH/logo-arrow.svg" \
        "$TITLE" "$3"
fi
