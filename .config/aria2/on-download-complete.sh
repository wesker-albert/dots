#!/bin/bash

set -eu -o pipefail

MSG_MAX_LENGTH=60
ELIPSES="…"

MSG=$(basename "$3" |
    awk -v len="$MSG_MAX_LENGTH" \
        '{ if (length($0) > len) print substr($0, 1, len) "'"$ELIPSES"'"; else print; }')

dunstify \
    --icon="document-save" \
    "Aria2: Download Complete" "$MSG"

mv "$3" "$HOME/Downloads"
rm "$3.aria2"
