#!/bin/bash

CURRENT_MONITOR=$(herbstclient list_monitors | grep 'FOCUS' | cut -c1-1)

function all_monitors() {
    scrot ~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png -e 'gthumb $f' -q 100
}

function current_monitor() {
    scrot ~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png -e 'gthumb $f' -q 100 -M $CURRENT_MONITOR
}

function current_window() {
    scrot ~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png -e 'gthumb $f' -q 100 -u -b
}

$1
