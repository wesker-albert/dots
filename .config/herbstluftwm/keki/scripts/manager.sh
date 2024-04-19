#!/bin/bash

function autostart() {
    [[ -z $(pidof -x at-spi-bus-launcher) ]] && /usr/libexec/at-spi-bus-launcher --launch-immediately &
    [[ -z $(pidof -x picom) ]] && picom &
    [[ -z $(pidof -x blueman-applet) ]] && blueman-start &
    [[ -z $(pidof -x fbxkb) ]] && fbxkb-start &
    [[ -z $(pidof -x polkit-gnome-authentication-agent-1) ]] && /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
    [[ -z $(pidof -x pulseaudio) ]] && start-pulseaudio-x11 &
    [[ -z $(pidof -x xfce4-power-manager) ]] && xfce4-power-manager &

    restore-software-brightness &

    [[ -z $(pidof -x light-locker) ]] && light-locker &

    xdg-user-dirs-gtk-update &

    [[ -z $(pidof -x xfce4-notifyd) ]] && xfce4-notifyd-start &
    [[ -z $(pidof -x xfsettingsd) ]] && xfsettingsd &
    [[ -z $(pidof -x xfce-superkey) ]] && xfce-superkey &
    [[ -z $(pidof -x gnome-keyring-daemon) ]] && gnome-keyring-daemon --start --components=secrets &

    nitrogen --restore &

    sleep 5s

    if [[ -z $(pidof -x aria2c) ]]; then
        aria2c --conf-path=$HOME/.config/aria2/aria2.conf --rpc-secret=$(secret-tool lookup service aria2) &
        busybox httpd -p 127.0.0.1:8090 -h /home/wesker/.ariang/ &
        ARIA2_VERSION=$(aria2c --version | head -n 1 | awk '{print $3;}')
        notify-send --icon='filesave' 'aria2' "aria2 $ARIA2_VERSION started"
    fi

    [[ -z $(pidof -x sabnzbdplus) ]] && sabnzbdplus &

    [[ -z $(pidof -x volumeicon) ]] && volumeicon &
}

function reload() {
    killall -w -q polybar

    herbstclient reload 
}

function init() {
    polybar main &
    polybar secondary &
    polybar tertiary &

    autostart
}

$1
