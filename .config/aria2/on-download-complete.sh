#!/bin/bash

notify-send --icon='filesave' 'Download Completed' "$(basename "$3")"

rm "$3.aria2"
