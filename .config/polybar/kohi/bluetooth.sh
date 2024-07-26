#!/bin/bash

set -eu -o pipefail

_get_alias() {
    echo "$@" |
        grep -e "Alias" |
        cut -f2- -d" "
}

_get_battery_percent() {
    echo "$@" |
        grep -e "Battery Percentage" |
        cut -d "(" -f2 |
        cut -d ")" -f1
}

_get_icon() {
    ICON=$(echo "$@" |
        grep -e "Icon" |
        cut -f2- -d" ")

    case $ICON in
    audio-headphones)
        echo ""
        ;;
    audio-headset)
        echo ""
        ;;
    input-gaming)
        echo ""
        ;;
    input-keyboard)
        echo ""
        ;;
    input-mouse)
        echo ""
        ;;
    input-tablet)
        echo ""
        ;;
    phone)
        echo ""
        ;;
    computer)
        echo ""
        ;;
    printer)
        echo "朗"
        ;;
    scanner)
        echo "󰿁"
        ;;
    camera-photo)
        echo ""
        ;;
    camera-video)
        echo ""
        ;;
    video-display)
        echo "󰟴"
        ;;
    network-wireless)
        echo ""
        ;;
    modem)
        echo "󰩩"
        ;;
    audio-card)
        echo ""
        ;;
    multimedia-player)
        echo "󰽴"
        ;;
    unknown | *)
        echo ""
        ;;
    esac
}

get_connected_devices() {
    UUIDS=$(bluetoothctl devices Connected | cut -f2 -d' ')

    if [ -z "$UUIDS" ]; then
        exit 1
    fi

    mapfile -t UUIDS <<<"$UUIDS"

    INDEX=0
    OUTPUT=""

    for UUID in "${UUIDS[@]}"; do
        DEVICE=$(bluetoothctl info "$UUID")

        ICON=$(_get_icon "$DEVICE")
        ALIAS=$(_get_alias "$DEVICE")
        BATTERY_PERCENT=$(_get_battery_percent "$DEVICE")

        if [ -z "$BATTERY_PERCENT" ]; then
            exit 1
        fi

        if [ $INDEX -ne 0 ]; then
            OUTPUT+="%{O10}"
        fi

        OUTPUT+="%{F#8E7B6B}$ICON%{F-} %{T3}$ALIAS ($BATTERY_PERCENT%)%{T-}"

        ((INDEX = INDEX + 1))
    done

    echo "$OUTPUT"
}

"$@"
