#!/bin/bash

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
