#!/bin/bash

# Polybar script that displays connected bluetooth devices and their battery
# percentage, if available. It also is capable of showing dynamic icons
# depending on the type of device(s) connected.

# EXAMPLE CONFIG

# [module/bluetooth]
# type                          = custom/script
# interval                      = 2

# exec                          = bluetooth.sh get_connected_devices

# env-SEPARATOR                 = %{O10}
# env-ICON_FOREGROUND           = #8E7B6B
# env-ICON_AUDIO_CARD           = 󰢮
# env-ICON_AUDIO_HEADPHONES     = 󰥰
# env-ICON_AUDIO_HEADSET        = 
# env-ICON_CAMERA_PHOTO         = 
# env-ICON_CAMERA_VIDEO         = 󰞡
# env-ICON_COMPUTER             = 󰌢
# env-ICON_INPUT_GAMING         = 
# env-ICON_INPUT_KEYBOARD       = 
# env-ICON_INPUT_MOUSE          = 󰦋
# env-ICON_INPUT_TABLET         = 
# env-ICON_MODEM                = 󰩩
# env-ICON_MULTIMEDIA_PLAYER    = 󰗾
# env-ICON_NETWORK_WIRELESS     = 󰀂
# env-ICON_PHONE                = 󰏳
# env-ICON_PRINTER              = 朗
# env-ICON_SCANNER              = 󰚫
# env-ICON_VIDEO_DISPLAY        = 󰍹
# env-ICON_DEFAULT              = 󰂱
# env-LABEL_ELIPSES             = …
# env-LABEL_MAX_LENGTH          = 10

# format                        = <label>
# format-fail                   = <label-fail>

# label                         = %output%
# label-fail                    =

# click-right                   = blueman-manager

set -eu -o pipefail

TMP_FOLDER="/tmp/polybar"
TMP_FILEPATH="$TMP_FOLDER/bluetooth"

if [ ! -f "$TMP_FILEPATH" ]; then
    mkdir -p "$TMP_FOLDER"
    touch "$TMP_FILEPATH"
fi

_get_alias() {
    echo "$1" |
        grep -e "Alias" |
        cut -f2- -d" " |
        awk -v len="$LABEL_MAX_LENGTH" \
            '{ if (length($0) > len) print substr($0, 1, len) "'"$LABEL_ELIPSES"'"; else print; }'
}

_get_battery_percent() {
    BATTERY_PERCENT=$(echo "$1" |
        grep -e "Battery Percentage" |
        cut -d "(" -f2 |
        cut -d ")" -f1)

    if [ -n "$BATTERY_PERCENT" ]; then
        echo " ($BATTERY_PERCENT%)"
    fi
}

_get_icon() {
    ICON=$(echo "$1" |
        grep -e "Icon" |
        cut -f2- -d" ")

    case $ICON in
    audio-headphones)
        echo "$ICON_AUDIO_HEADPHONES"
        ;;
    audio-headset)
        echo "$ICON_AUDIO_HEADSET"
        ;;
    input-gaming)
        echo "$ICON_INPUT_GAMING"
        ;;
    input-keyboard)
        echo "$ICON_INPUT_KEYBOARD"
        ;;
    input-mouse)
        echo "$ICON_INPUT_MOUSE"
        ;;
    input-tablet)
        echo "$ICON_INPUT_TABLET"
        ;;
    phone)
        echo "$ICON_PHONE"
        ;;
    computer)
        echo "$ICON_COMPUTER"
        ;;
    printer)
        echo "$ICON_PRINTER"
        ;;
    scanner)
        echo "$ICON_SCANNER"
        ;;
    camera-photo)
        echo "$ICON_CAMERA_PHOTO"
        ;;
    camera-video)
        echo "$ICON_CAMERA_VIDEO"
        ;;
    video-display)
        echo "$ICON_VIDEO_DISPLAY"
        ;;
    network-wireless)
        echo "$ICON_NETWORK_WIRELESS"
        ;;
    modem)
        echo "$ICON_MODEM"
        ;;
    audio-card)
        echo "$ICON_AUDIO_CARD"
        ;;
    multimedia-player)
        echo "$ICON_MULTIMEDIA_PLAYER"
        ;;
    unknown | *)
        echo "$ICON_DEFAULT"
        ;;
    esac
}

get_connected_devices() {
    UUIDS=$(bluetoothctl devices Connected | cut -f2 -d' ')
    INDEX=0
    OUTPUT=""

    if [ "$UUIDS" ]; then
        mapfile -t UUIDS <<<"$UUIDS"

        for UUID in "${UUIDS[@]}"; do
            DEVICE=$(bluetoothctl info "$UUID")

            ICON=$(_get_icon "$DEVICE")
            ALIAS=$(_get_alias "$DEVICE")
            BATTERY_PERCENT=$(_get_battery_percent "$DEVICE")

            if [ $INDEX -ne 0 ]; then
                OUTPUT+="$SEPARATOR"
            fi

            OUTPUT+="%{F$ICON_FOREGROUND}$ICON%{F-} %{T3}$ALIAS$BATTERY_PERCENT%{T-}"

            ((INDEX = INDEX + 1))
        done

    fi

    echo "$INDEX" >$TMP_FILEPATH

    echo "$OUTPUT"
}

"$@"
