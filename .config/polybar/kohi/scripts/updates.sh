#!/bin/bash

# Polybar script that displays the number of available package updates
# via apt.

# EXAMPLE CONFIG

# [module/updates]
# type                          = custom/script
# interval                      = 10

# exec                          = updates.sh get_update_count

# format                        = <label>
# format-fail                   = <label-fail>

# label                         = %{F#E78A4E}󰇻%{F-} %{T3}%output%%{T-}
# label-fail                    =

set -eu -o pipefail

_get_list_of_upgrades() {
    apt list --upgradable 2>/dev/null |
        grep -e "upgradable from" |
        awk -F/ '{print $1}'
}

get_update_count() {
    UPDATE_COUNT=$(_get_list_of_upgrades | wc -l)

    echo "$UPDATE_COUNT"
}

$1
