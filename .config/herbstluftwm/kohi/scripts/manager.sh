#!/bin/bash

function reload() {
    killall -q compton &
    killall -w -q polybar &

    herbstclient reload 
}

function init() {
    compton-launch.sh &

    sleep 2s
    
    polybar main &
    polybar secondary
}

$1
