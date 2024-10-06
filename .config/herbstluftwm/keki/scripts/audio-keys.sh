#!/bin/bash

set -eu -o pipefail

VOLUME_STEP=2

_get_current_volume() {
    amixer sget Master |
        awk -F"[][]" '/Left:/ { print $2 }' |
        sed "s/%//"
}

_get_current_mute_state() {
    amixer sget Master |
        awk -F"[][]" '/Left:/ { print $4 }'
}

_get_volume_icon() {
    CURRENT_VOLUME=$(_get_current_volume)

    if [ "$CURRENT_VOLUME" -gt 65 ]; then
        echo "audio-volume-high"
    elif [ "$CURRENT_VOLUME" -gt 35 ]; then
        echo "audio-volume-medium"
    else
        echo "audio-volume-low"
    fi
}

_send_notification() {
    MUTE_STATE=$(_get_current_mute_state)

    if [ "$MUTE_STATE" == "off" ]; then
        dunstify \
            -h string:x-dunst-stack-tag:audio-keys \
            --icon audio-volume-muted \
            "Volume muted"
    else
        dunstify \
            -h string:x-dunst-stack-tag:audio-keys \
            --icon "$(_get_volume_icon)" \
            "Volume $(_get_current_volume)%"
    fi
}

raise_volume() {
    CURRENT_VOLUME=$(_get_current_volume)

    if [ "$CURRENT_VOLUME" -lt 100 ]; then
        sh -c "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume @DEFAULT_SINK@ +$VOLUME_STEP%"

        _send_notification
    fi
}

lower_volume() {
    sh -c "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume @DEFAULT_SINK@ -$VOLUME_STEP%"

    _send_notification
}

toggle_mute() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle

    _send_notification
}

$1
