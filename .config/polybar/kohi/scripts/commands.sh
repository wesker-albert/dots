#!/bin/bash
# shellcheck disable=SC2086

set -eu -o pipefail

KITTY_BOOTSTRAP="--class kitty_float -o remember_window_size=n"

spawn_calcurse() {
    kitty $KITTY_BOOTSTRAP -o initial_window_width=100c -o initial_window_height=45c calcurse
}

spawn_alsamixer() {
    kitty $KITTY_BOOTSTRAP -o initial_window_width=200c -o initial_window_height=35c alsamixer
}

spawn_nmtui() {
    NEWT_COLORS="root=black,black;" \
        kitty $KITTY_BOOTSTRAP -o initial_window_width=82c -o initial_window_height=35c nmtui-connect
}

spawn_upgrade() {
    kitty --hold $KITTY_BOOTSTRAP -o initial_window_width=100c -o initial_window_height=35c sudo apt upgrade
}

$1
