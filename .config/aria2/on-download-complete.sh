#!/bin/bash

dunstify \
    --icon='document-save' \
    'Download Completed' "$(basename "$3")"

rm "$3.aria2"
