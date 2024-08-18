#!/bin/bash

# Polybar script that displays the number of available package updates
# via apt.

# EXAMPLE CONFIG

# [module/updates]
# type                          = custom/script
# interval                      = 10

# exec                          = updates.sh get_update_count

# format                        = <label>
# format-fail                   = <label-fail>

# label                         = %{F#E78A4E}󰇻%{F-} %{T3}%output%%{T-}
# label-fail                    =

set -eu -o pipefail

DUNST_TITLE="Package Management"
TMP_FOLDER="/tmp/polybar"
TMP_FILEPATH="$TMP_FOLDER/updates"

if [ ! -f "$TMP_FILEPATH" ]; then
    mkdir -p "$TMP_FOLDER"
    touch "$TMP_FILEPATH"
fi

_openAction() {
    bash "$HOME"/.config/polybar/kohi/scripts/commands.sh spawn_upgrade
}

_get_list_of_upgrades() {
    apt list --upgradable 2>/dev/null |
        grep -e "upgradable from" |
        awk -F/ '{print $1}'
}

get_update_count() {
    UPDATE_COUNT=$(_get_list_of_upgrades | wc -l)
    PREV_UPDATE_COUNT=$(cat "$TMP_FILEPATH")

    echo "$UPDATE_COUNT"
    echo "$UPDATE_COUNT" >$TMP_FILEPATH

    if [ "$PREV_UPDATE_COUNT" != "$UPDATE_COUNT" ]; then
        ACTION=$(dunstify \
            --appname "polybar-updates" \
            --icon "software-update-available" \
            --action="default,Open" \
            "$DUNST_TITLE" "$UPDATE_COUNT new updates available")

        if [ "$ACTION" == "default" ]; then
            _openAction
        fi
    fi
}

$1 &
