#!/bin/bash

set -eu -o pipefail

rofi -show power-menu \
    -modi power-menu:'~/.config/rofi/kohi/rofi-power-menu.sh' \
    -theme-str 'window {children: [ listview ]; width: 300px;} listview {lines: 3;}'
