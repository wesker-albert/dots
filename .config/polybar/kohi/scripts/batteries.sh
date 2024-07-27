#!/bin/bash

# Polybar script specifically for laptops that utilize two batteries.
# Displays a singular, cumulative charge percentage. Also includes
# dynamic, ramping icons, and a low battery threshold setting.

# EXAMPLE CONFIG

# [module/batteries]
# type                            = custom/script
# interval                        = 5

# exec                            = batteries.sh get_batteries_status

# env-RAMP_0                      = 󰁺
# env-RAMP_1                      = 󰁻
# env-RAMP_2                      = 󰁼
# env-RAMP_3                      = 󰁽
# env-RAMP_4                      = 󰁾
# env-RAMP_5                      = 󰁿
# env-RAMP_6                      = 󰂀
# env-RAMP_7                      = 󰂁
# env-RAMP_8                      = 󰂂
# env-RAMP_9                      = 󰁹
# env-RAMP_CHARGING_0             = 󰢜
# env-RAMP_CHARGING_1             = 󰂆
# env-RAMP_CHARGING_2             = 󰂇
# env-RAMP_CHARGING_3             = 󰂈
# env-RAMP_CHARGING_4             = 󰢝
# env-RAMP_CHARGING_5             = 󰂉
# env-RAMP_CHARGING_6             = 󰢞
# env-RAMP_CHARGING_7             = 󰂊
# env-RAMP_CHARGING_8             = 󰂋
# env-RAMP_CHARGING_9             = 󰂅
# env-ICON_AC                     = 
# env-ICON_FOREGROUND             = #8E7B6B
# env-LOW_BATTERY_THRESHOLD       = 25
# env-ICON_LOW_BATTERY_FOREGROUND = #A54242

# format                          = <label>
# label                           = %output%

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
            ICON="$RAMP_CHARGING_9"
        elif [ "$PERCENTAGE" -gt 80 ]; then
            ICON="$RAMP_CHARGING_8"
        elif [ "$PERCENTAGE" -gt 70 ]; then
            ICON="$RAMP_CHARGING_7"
        elif [ "$PERCENTAGE" -gt 60 ]; then
            ICON="$RAMP_CHARGING_6"
        elif [ "$PERCENTAGE" -gt 50 ]; then
            ICON="$RAMP_CHARGING_5"
        elif [ "$PERCENTAGE" -gt 40 ]; then
            ICON="$RAMP_CHARGING_4"
        elif [ "$PERCENTAGE" -gt 30 ]; then
            ICON="$RAMP_CHARGING_3"
        elif [ "$PERCENTAGE" -gt 20 ]; then
            ICON="$RAMP_CHARGING_2"
        elif [ "$PERCENTAGE" -gt 10 ]; then
            ICON="$RAMP_CHARGING_1"
        else
            ICON="$RAMP_CHARGING_0"
        fi
    else
        if [ "$PERCENTAGE" -gt 90 ]; then
            ICON="$RAMP_9"
        elif [ "$PERCENTAGE" -gt 80 ]; then
            ICON="$RAMP_8"
        elif [ "$PERCENTAGE" -gt 70 ]; then
            ICON="$RAMP_7"
        elif [ "$PERCENTAGE" -gt 60 ]; then
            ICON="$RAMP_6"
        elif [ "$PERCENTAGE" -gt 50 ]; then
            ICON="$RAMP_5"
        elif [ "$PERCENTAGE" -gt 40 ]; then
            ICON="$RAMP_4"
        elif [ "$PERCENTAGE" -gt 30 ]; then
            ICON="$RAMP_3"
        elif [ "$PERCENTAGE" -gt 20 ]; then
            ICON="$RAMP_2"
        elif [ "$PERCENTAGE" -gt 10 ]; then
            ICON="$RAMP_1"
        else
            ICON="$RAMP_0"
        fi
    fi

    if [ "$STATE" = "discharging" ] && [ "$PERCENTAGE" -lt "$LOW_BATTERY_THRESHOLD" ]; then
        echo "%{F$ICON_LOW_FOREGROUND}$ICON%{F-}"
    else
        echo "%{F$ICON_FOREGROUND}$ICON%{F-}"
    fi
}

get_batteries_status() {
    BAT0=$(_get_battery BAT0)
    BAT1=$(_get_battery BAT1)

    STATE=$(_get_combined_state "$BAT0" "$BAT1")
    PERCENTAGE=$(_get_combined_percentage "$BAT0" "$BAT1")
    ICON=$(_get_icon "$STATE" "$PERCENTAGE")

    if [ "$STATE" = "fully-charged" ]; then
        echo "%{F$ICON_FOREGROUND}$ICON_AC%{F-}"
    else
        echo "$ICON %{T3}$PERCENTAGE%%{T-}"
    fi
}

"$@"
