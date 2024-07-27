#!/bin/bash

set -eu -o pipefail

_get_battery() {
    upower -i "/org/freedesktop/UPower/devices/battery_$1"
}

_get_battery_percentage() {
    echo "$1" |
        grep -e "percentage" |
        awk '{print $2;}' |
        sed "s/%//"
}

_get_combined_percentage() {
    BAT0_PERCENT=$(_get_battery_percentage "$1")
    BAT1_PERCENT=$(_get_battery_percentage "$2")

    bc -l <<<"($BAT0_PERCENT+$BAT1_PERCENT)/200*100" |
        awk -F. '{print $1}'
}

_get_battery_state() {
    echo "$1" |
        grep -e "state" |
        awk '{print $2;}'
}

_get_combined_state() {
    BAT0_STATE=$(_get_battery_state "$1")
    BAT1_STATE=$(_get_battery_state "$2")

    if [ "$BAT0_STATE" = "charging" ] || [ "$BAT1_STATE" = "charging" ]; then
        echo "charging"
    elif [ "$BAT0_STATE" = "fully-charged" ] && [ "$BAT1_STATE" = "fully-charged" ]; then
        echo "fully-charged"
    else
        echo "discharging"
    fi
}

_get_icon() {
    STATE="$1"
    PERCENTAGE="$2"

    if [ "$STATE" = "charging" ]; then
        if [ "$PERCENTAGE" -gt 90 ]; then
            ICON="󰂅"
        elif [ "$PERCENTAGE" -gt 80 ]; then
            ICON="󰂋"
        elif [ "$PERCENTAGE" -gt 70 ]; then
            ICON="󰂊"
        elif [ "$PERCENTAGE" -gt 60 ]; then
            ICON="󰢞"
        elif [ "$PERCENTAGE" -gt 50 ]; then
            ICON="󰂉"
        elif [ "$PERCENTAGE" -gt 40 ]; then
            ICON="󰢝"
        elif [ "$PERCENTAGE" -gt 30 ]; then
            ICON="󰂈"
        elif [ "$PERCENTAGE" -gt 20 ]; then
            ICON="󰂇"
        elif [ "$PERCENTAGE" -gt 10 ]; then
            ICON="󰂆"
        else
            ICON="󰢜"
        fi
    else
        if [ "$PERCENTAGE" -gt 90 ]; then
            ICON="󰁹"
        elif [ "$PERCENTAGE" -gt 80 ]; then
            ICON="󰂂"
        elif [ "$PERCENTAGE" -gt 70 ]; then
            ICON="󰂁"
        elif [ "$PERCENTAGE" -gt 60 ]; then
            ICON="󰂀"
        elif [ "$PERCENTAGE" -gt 50 ]; then
            ICON="󰁿"
        elif [ "$PERCENTAGE" -gt 40 ]; then
            ICON="󰁾"
        elif [ "$PERCENTAGE" -gt 30 ]; then
            ICON="󰁽"
        elif [ "$PERCENTAGE" -gt 20 ]; then
            ICON="󰁼"
        elif [ "$PERCENTAGE" -gt 10 ]; then
            ICON="󰁻"
        else
            ICON="󰁺"
        fi
    fi

    if [ "$STATE" = "discharging" ] && [ "$PERCENTAGE" -lt 25 ]; then
        echo "%{F#A54242}$ICON%{F-}"
    else
        echo "%{F#8E7B6B}$ICON%{F-}"
    fi
}

get_batteries_status() {
    BAT0=$(_get_battery BAT0)
    BAT1=$(_get_battery BAT1)

    STATE=$(_get_combined_state "$BAT0" "$BAT1")
    PERCENTAGE=$(_get_combined_percentage "$BAT0" "$BAT1")
    ICON=$(_get_icon "$STATE" "$PERCENTAGE")

    if [ "$STATE" = "fully-charged" ]; then
        echo "%{F#8E7B6B}%{F-}"
    else
        echo "$ICON %{T3}$PERCENTAGE%%{T-}"
    fi
}

"$@"
