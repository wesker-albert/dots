#!/bin/bash

set -eu -o pipefail

VOLUME_STEP=2
MUSIC_DIR="$HOME/Music"

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

_get_mpd_state() {
    mpc status %state%
}

_get_mpd_current_album_dir() {
    mpc current -f %file% | sed 's/[^/]*$//'
}

_get_mpd_current_album_art() {
    ALBUM_DIR="$MUSIC_DIR/$(_get_mpd_current_album_dir)"
    echo "$ALBUM_DIR"cover.jpg
}

_get_mpd_current_info() {
    ALBUM_YEAR=$(mpc current -f "%date%" | cut -c 1-4)
    TRACK_INFO=$(mpc current -f "<b>Artist:</b> %albumartist%\n<b>Album:</b>  %album% ($ALBUM_YEAR)\n<b>Track:</b>  %title%")
    PLAYTIME_INFO=$(mpc status "\[%currenttime%/%totaltime%\]")

    printf "%s\n\n%s" "$TRACK_INFO" "$PLAYTIME_INFO"
}

_send_volume_notification() {
    MUTE_STATE=$(_get_current_mute_state)

    if [ "$MUTE_STATE" == "off" ]; then
        dunstify \
            -h string:x-dunst-stack-tag:audio-keys-volume \
            --appname "audio-keys-volume" \
            --icon audio-volume-muted \
            "Volume muted"
    else
        dunstify \
            -h string:x-dunst-stack-tag:audio-keys-volume \
            --appname "audio-keys-volume" \
            -h int:value:"$(_get_current_volume)" \
            --icon "$(_get_volume_icon)" \
            "Volume $(_get_current_volume)%"
    fi
}

_send_mpd_notification() {
    PLAY_STATE=$(_get_mpd_state)

    if [ "$PLAY_STATE" == "paused" ]; then
        dunstify \
            -h string:x-dunst-stack-tag:audio-keys-mpd \
            --appname "audio-keys-mpd" \
            --icon "$(_get_mpd_current_album_art)" \
            "Paused" \
            "$(_get_mpd_current_info)"
    else
        dunstify \
            -h string:x-dunst-stack-tag:audio-keys-mpd \
            --appname "audio-keys-mpd" \
            --icon "$(_get_mpd_current_album_art)" \
            "Now Playing" \
            "$(_get_mpd_current_info)"
    fi
}

raise_volume() {
    CURRENT_VOLUME=$(_get_current_volume)

    if [ "$CURRENT_VOLUME" -lt 100 ]; then
        sh -c "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume @DEFAULT_SINK@ +$VOLUME_STEP%"

        _send_volume_notification
    fi
}

lower_volume() {
    sh -c "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume @DEFAULT_SINK@ -$VOLUME_STEP%"

    _send_volume_notification
}

toggle_mute() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle

    _send_volume_notification
}

prev_track() {
    mpc prev

    _send_mpd_notification
}

toggle_play() {
    mpc toggle

    _send_mpd_notification
}

next_track() {
    mpc next

    _send_mpd_notification
}

$1
