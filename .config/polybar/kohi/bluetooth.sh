#!/bin/bash

_get_alias() {
    bluetoothctl info $1 \
    | grep -e "Alias" \
    | cut -f2- -d" "
}

_get_battery_percent() {
    bluetoothctl info $1 \
    | grep -e "Battery Percentage" \
    | cut -d "(" -f2 \
    | cut -d ")" -f1
}

_get_icon() {
    ICON=$(bluetoothctl info $1 \
    | grep -e "Icon" \
    | cut -f2- -d" ")

    if [ "$ICON" = "audio-headphones" ]; then
        echo ""
    elif [ "$ICON" = "audio-headset" ]; then
        echo ""
    else
        echo ""
    fi
}

get_connected_devices() {
    UUIDS=$(bluetoothctl devices Connected | cut -f2 -d' ')

    if [ -z "$UUIDS" ]; then
        exit 1
    fi

    UUIDS=($UUIDS)
    INDEX=0
    OUTPUT=""

    for UUID in "${UUIDS[@]}"
    do
        ICON=$(_get_icon $UUID)
        ALIAS=$(_get_alias $UUID)
        BATTERY_PERCENT=$(_get_battery_percent $UUID)

        if [ -z "$BATTERY_PERCENT" ]; then
            exit 1
        fi

        if [ $INDEX -ne 0 ]; then
            OUTPUT+="%{O10}"
        fi

        OUTPUT+="%{F#8E7B6B}$ICON%{F-} %{T3}$ALIAS ($BATTERY_PERCENT%)%{T-}"

        ((INDEX=INDEX+1))
    done

    echo "$OUTPUT"
    
}

$1
