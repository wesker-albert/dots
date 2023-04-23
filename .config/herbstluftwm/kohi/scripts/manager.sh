#!/bin/bash

function reload() {
    killall -q polybar
    killall -q compton

    herbstclient reload 
}

function init() {
    compton-launch.sh

    polybar main
    polybar secondary
}

$1
