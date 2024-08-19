#!/bin/bash
# shellcheck disable=SC2086

kitty \
    --class kitty_float \
    -o remember_window_size=n \
    -o initial_window_width=$2 \
    -o initial_window_height=$3 \
    $1
