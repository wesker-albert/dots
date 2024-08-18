#!/bin/bash

set -eu -o pipefail

_get_win_id() {
    wmctrl -l |
        grep "$@" |
        grep -v grep |
        awk '{print $1}' ||
        true
}

_spawn_kitty() {
    kitty \
        --class kitty_float \
        -o remember_window_size=n \
        -o initial_window_width="$2" \
        -o initial_window_height="$3" \
        "$1"

}

spawn_calcurse() {
    WINID=$(_get_win_id "calcurse")

    if [ -z "$WINID" ]; then
        _spawn_kitty calcurse 100c 45c
    else
        wmctrl -ia "$WINID"
    fi
}

spawn_alsamixer() {
    WINID=$(_get_win_id "Volume Control")

    if [ -z "$WINID" ]; then
        _spawn_kitty alsamixer 200c 35c
    else
        wmctrl -ia "$WINID"
    fi
}

spawn_nmtui() {
    WINID=$(_get_win_id "nmtui-connect")

    if [ -z "$WINID" ]; then
        NEWT_COLORS="root=black,black;" \
            _spawn_kitty nmtui-connect 82c 35c
    else
        wmctrl -ia "$WINID"
    fi
}

spawn_upgrade() {
    WINID=$(_get_win_id "sudo apt upgrade")

    if [ -z "$WINID" ]; then
        _spawn_kitty "sudo apt upgrade" 100c 35c
    else
        wmctrl -ia "$WINID"
    fi
}

$1
