#!/bin/bash
# shellcheck disable=SC2016

set -eu -o pipefail

all_monitors() {
    scrot ~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png -e 'gthumb $f' -q 100
}

current_monitor() {
    CURRENT_MONITOR=$(herbstclient list_monitors | grep 'FOCUS' | cut -c1-1)
    scrot ~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png -e 'gthumb $f' -q 100 -M "$CURRENT_MONITOR"
}

current_window() {
    scrot ~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png -e 'gthumb $f' -q 100 -u -b
}

$1
