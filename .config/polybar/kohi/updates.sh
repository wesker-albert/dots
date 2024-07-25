#!/bin/bash

_get_list_of_upgrades() {
    LC_ALL=en_US apt-get -o 'Debug::NoLocking=true' --trivial-only -V dist-upgrade 2>/dev/null |
        sed -n '/upgraded:/,$p' |
        grep ^'  ' |
        awk '{ print $1 }' |
        sort
}

get_update_count() {
    UPDATE_COUNT=0

    if [ -s /var/lib/synaptic/preferences ]; then
        UPDATE_COUNT=$(_get_list_of_upgrades |
            grep -vx $(grep 'Package:' /var/lib/synaptic/preferences 2>/dev/null | awk {'print "-e " $2'}) |
            wc -l)
    else
        UPDATE_COUNT=$(_get_list_of_upgrades |
            wc -l)
    fi

    if [ "$UPDATE_COUNT" -eq "0" ]; then
        exit 1
    fi

    echo "$UPDATE_COUNT"
}

$1
