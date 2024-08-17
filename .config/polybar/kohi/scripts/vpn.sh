#!/bin/bash

# Polybar script that displays the currently connected VPN profile.
# It is compatible with Wireguard and OpenVPN type connections, and
# allows custom status icons.

# EXAMPLE CONFIG

# [module/vpn]
# type                                = custom/script
# interval                            = 2

# exec                                = vpn.sh get_active_connection

# env-ICON_CONNECTED                  = 󰦝
# env-ICON_CONNECTED_FOREGROUND       = #8E7B6B
# env-ICON_DISCONNECTED               = 󱦚
# env-ICON_DISCONNECTED_FOREGROUND    = #A54242
# env-LABEL_DISCONNECTED              = off
# env-LABEL_DISCONNECTED_FOREGROUND   = #DAABB1

# format                              = <label>

# label                               = %output%

set -eu -o pipefail

DUNST_TITLE="Network VPN"
TMP_FOLDER="/tmp/polybar"
TMP_FILEPATH="$TMP_FOLDER/vpn"

if [ ! -f "$TMP_FILEPATH" ]; then
    mkdir -p "$TMP_FOLDER"
    touch "$TMP_FILEPATH"
fi

_openAction() {
    bash "$HOME"/.config/polybar/kohi/scripts/commands.sh spawn_nmtui
}

_get_connection_name() {
    nmcli connection show --active |
        grep "wireguard\|openvpn" |
        awk '{print $1;}' || true
}

get_active_connection() {
    NAME=$(_get_connection_name)
    PREV_NAME=$(cat "$TMP_FILEPATH")

    if [ -z "$NAME" ]; then
        NAME="null"

        if [ -z ${LABEL_DISCONNECTED+x} ]; then
            echo "%{F$ICON_DISCONNECTED_FOREGROUND}$ICON_DISCONNECTED%{F-}"
        else
            echo "%{F$ICON_DISCONNECTED_FOREGROUND}$ICON_DISCONNECTED%{F-} %{T3}%{F$LABEL_DISCONNECTED_FOREGROUND}$LABEL_DISCONNECTED%{F-}%{T-}"
        fi

        echo "$NAME" >$TMP_FILEPATH

        if [ "$PREV_NAME" != "$NAME" ]; then
            ACTION=$(dunstify \
                --urgency "critical" \
                --icon "changes-allow" \
                --action="default,Open" \
                "$DUNST_TITLE" "You are not currently protected!")

            if [ "$ACTION" == "default" ]; then
                _openAction
            fi
        fi
    else
        echo "%{F$ICON_CONNECTED_FOREGROUND}$ICON_CONNECTED%{F-} %{T3}$NAME%{T-}"

        echo "$NAME" >$TMP_FILEPATH

        if [ "$PREV_NAME" != "$NAME" ]; then
            dunstify \
                --icon "changes-prevent" \
                "$DUNST_TITLE" "Connected to profile: $NAME"
        fi
    fi
}

$1 &
