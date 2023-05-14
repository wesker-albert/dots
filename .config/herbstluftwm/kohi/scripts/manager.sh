#!/bin/bash

function autostart() {
    if ! pidof -x at-spi-bus-launcher; then
        /usr/libexec/at-spi-bus-launcher --launch-immediately &
    fi

    if ! pidof -x picom; then
        picom &
    fi

    if ! pidof -x blueman-applet; then
        blueman-start &
    fi

    if ! pidof -x fbxkb; then
        fbxkb-start &
    fi

    if ! pidof -x polkit-gnome-authentication-agent-1; then
        /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
    fi

    if ! pidof -x pulseaudio; then
        start-pulseaudio-x11 &
    fi

    if ! pidof -x xfce4-power-manager; then
        xfce4-power-manager &
    fi

    restore-software-brightness &

    if ! pidof -x light-locker; then
        light-locker &
    fi

    xdg-user-dirs-gtk-update &

    if ! pidof -x xfce4-notifyd; then
        xfce4-notifyd-start &
    fi

    if ! pidof -x xfsettingsd; then
        xfsettingsd &
    fi

    if ! pidof -x xfce-superkey; then
        xfce-superkey &
    fi

    if ! pidof -x gnome-keyring-daemon; then
        gnome-keyring-daemon --start --components=secrets &
    fi

    sleep 5s

    if ! pidof -x aria2c; then
        aria2c --conf-path=$HOME/.config/aria2/aria2.conf --rpc-secret=$(secret-tool lookup service aria2) &
        notify-send --icon='filesave' 'aria2' 'Session has started'
    fi

    if ! pidof -x volumeicon; then
        volumeicon &
    fi
}

function reload() {
    killall -w -q polybar

    herbstclient reload 
}

function init() {
    polybar main &
    polybar secondary &

    autostart
}

$1
