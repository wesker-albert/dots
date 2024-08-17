#!/bin/bash

set -eu -o pipefail

rofi -show power-menu \
    -modi power-menu:"$HOME/.config/rofi/kohi/rofi-power-menu.sh" \
    -theme-str "window {children: [ wrapper-window ]; width: 300px;} wrapper-window {children: [ listview ];} listview {lines: 3;}"
