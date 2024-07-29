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

_get_connection_name() {
    nmcli connection show --active |
        grep "wireguard\|openvpn" |
        awk '{print $1;}'
}

get_active_connection() {
    NAME=$(_get_connection_name)

    if [ -z "$NAME" ]; then
        if [ -z "$LABEL_DISCONNECTED" ]; then
            echo "%{F$ICON_DISCONNECTED_FOREGROUND}$ICON_DISCONNECTED%{F-}"
        else
            echo "%{F$ICON_DISCONNECTED_FOREGROUND}$ICON_DISCONNECTED%{F-} %{T3}%{F$LABEL_DISCONNECTED_FOREGROUND}$LABEL_DISCONNECTED%{F-}%{T-}"
        fi
    else
        echo "%{F$ICON_CONNECTED_FOREGROUND}$ICON_CONNECTED%{F-} %{T3}$NAME%{T-}"
    fi
}

$1
