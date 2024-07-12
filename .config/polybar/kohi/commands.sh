#!/bin/sh

KITTY_BOOTSTRAP="--class kitty_float -o remember_window_size=n"

function spawn_calcurse() {
    kitty $(echo $KITTY_BOOTSTRAP) -o initial_window_width=100c -o initial_window_height=45c calcurse
}

function spawn_alsamixer() {
    kitty $(echo $KITTY_BOOTSTRAP) -o initial_window_width=200c -o initial_window_height=35c alsamixer
}

function spawn_nmtui() {
    kitty $(echo $KITTY_BOOTSTRAP) -o initial_window_width=82c -o initial_window_height=35c nmtui
}

function spawn_upgrade() {
    kitty --hold $(echo $KITTY_BOOTSTRAP) -o initial_window_width=100c -o initial_window_height=35c sudo apt upgrade
}

$1
