#!/bin/bash

# set -eu -o pipefail

_get_connection_name() {
    nmcli connection show --active |
        grep "wireguard\|openvpn" |
        awk '{print $1;}'
}

get_active_connection() {
    CONNECTION_NAME=$(_get_connection_name)

    if [ -z "$CONNECTION_NAME" ]; then
        echo "%{F#A54242}󱦚%{F-} %{T3}%{F#DAABB1}off%{F-}%{T-}"
    else
        echo "%{F#8E7B6B}󰦝%{F-} %{T3}$CONNECTION_NAME%{T-}"
    fi
}

toggle_connection() {
    CONNECTION_NAME=$(_get_connection_name)

    if [ -z "$CONNECTION_NAME" ]; then
        nmcli connection up "$NAME"
        notify-send --icon="changes-prevent" "VPN" "Connected to $NAME"
    else
        nmcli connection down "$NAME"
        notify-send --icon="changes-allow" "VPN" "Disconnected from $NAME"
    fi
}

$1
