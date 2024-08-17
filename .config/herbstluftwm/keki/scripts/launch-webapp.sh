#!/bin/bash

set -eu -o pipefail

PROFILE_DIR="$HOME/.local/share/ice/firefox"

librewolf \
    --class "WebApp-$1" \
    --name "WebApp-$1" \
    --profile "$PROFILE_DIR/$1" \
    --no-remote "$2"
