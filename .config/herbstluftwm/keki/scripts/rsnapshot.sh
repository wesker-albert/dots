#!/bin/bash

# set -eu -o pipefail

DEVICE_PATH="/dev/sda"
BACKUP_DIR="/media/backup"

preexec() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir "$BACKUP_DIR"
    fi

    IS_MOUNTED=$(veracrypt --text -l 2>/dev/null | grep "$DEVICE_PATH" || true)

    if [ -z "$IS_MOUNTED" ]; then
        veracrypt --text --mount "$DEVICE_PATH" "$BACKUP_DIR" \
            --password "$(secret-tool lookup service backup_drive)" \
            --pim 0 \
            --keyfiles "" \
            --protect-hidden no \
            --slot 1
    fi
}

postexec() {
    veracrypt --text --dismount --slot 1

    rm -rf "$BACKUP_DIR"
}

$1
