#!/bin/bash

CURRENT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

function _get_json_val() {
    VAL=$(echo "$1" | jq $2 | sed "s/\"//g")
    [ "$VAL" != "null" ] && echo $VAL
}

function _round_up() {
    printf "%.*f" $2 "$(echo "$1" | bc -l)"
}

function _get_video_watch_percentage() {
    FILE_HASH=$(echo -n $1 | md5sum | tr '[:lower:]' '[:upper:]' | sed "s/  -.*//")
    WATCH_LATER_FILE="$HOME/.config/mpv/watch_later/$FILE_HASH"

    [ ! -f "$WATCH_LATER_FILE" ] && return

    LAST_POSITION=$(grep -oP '(?<=start=).*' "$WATCH_LATER_FILE" | sed "s/\..*//")

    printf "%s%%" $(_round_up "$LAST_POSITION / $2 * 100" 1)
}

function get_video_info() {
    VIDEO_STREAM=$(ffprobe -v error -select_streams v:0 -show_entries format_tags=title -show_entries format=duration -show_entries stream=width,height,bit_rate -of json $1)
    AUDIO_STREAM=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,sample_rate,channel_layout -of json $1)

    DURATION=$(_round_up $(_get_json_val "$VIDEO_STREAM" '.format.duration') 0)
    WATCH_PERCENTAGE=$(_get_video_watch_percentage $1 $DURATION)
    [ -n "$WATCH_PERCENTAGE" ] && WATCHED=" ($WATCH_PERCENTAGE watched)"

    TITLE=$(_get_json_val "$VIDEO_STREAM" '.format.tags.title')
    WIDTH=$(_get_json_val "$VIDEO_STREAM" '.streams[0].width')
    HEIGHT=$(_get_json_val "$VIDEO_STREAM" '.streams[0].height')
    BIT_RATE=$(_get_json_val "$VIDEO_STREAM" '.streams[0].bit_rate')
    AUDIO_CODEC=$(_get_json_val "$AUDIO_STREAM" '.streams[0].codec_name')
    AUDIO_RATE=$(_get_json_val "$AUDIO_STREAM" '.streams[0].sample_rate')
    AUDIO_CHANNELS=$(_get_json_val "$AUDIO_STREAM" '.streams[0].channel_layout')

    [ -n "$TITLE" ] && printf "$(tput setaf 6)%s$(tput sgr0)\n" "$TITLE"
    [ -n "$DURATION" ] && printf "$(tput setaf 4)Duration    $(tput setaf 3)%s%s$(tput sgr0)\n" "$(date -u -d @${DURATION} +"%T")" "$WATCHED"
    if [ -n "$WIDTH" ] && [ -n "$HEIGHT" ]; then
        printf "$(tput setaf 4)Resolution  $(tput setaf 5)%sx%s$(tput sgr0)\n" "$WIDTH" "$HEIGHT"
    fi
    [ -n "$BIT_RATE" ] && printf "$(tput setaf 4)Bit rate    $(tput setaf 2)%s kb/s$(tput sgr0)\n" "$(expr $BIT_RATE / 1000)"
    if [ -n "$AUDIO_CODEC" ] && [ -n "$AUDIO_RATE" ] && [ -n "$AUDIO_CHANNELS" ]; then
        printf "$(tput setaf 4)Audio       $(tput setaf 6)%s %sHz, %s$(tput sgr0)\n" "$AUDIO_CODEC" "$AUDIO_RATE" "$AUDIO_CHANNELS"
    fi
}

function get_local_file_thumbnail() {
    echo 'ffmpegthumbnailer -t 25% -s 0 -i {} -o /tmp/fzf-thumb.png && tupimage --force-upload --less-diacritics --fzf /tmp/fzf-thumb.png'
}

function search_local() {
    VIDEO_DIR="$HOME/Videos/"
    ALLOWED_FILE_TYPES='.*.(mp4|avi|mkv)'

    FZF_EXEC=$(find $VIDEO_DIR \
        -regextype posix-extended \
        -regex $ALLOWED_FILE_TYPES \
        -type f \
        | sort \
        | fzf \
        --preview-window right \
        --preview "bash $CURRENT_DIR/fzf_mpv.sh get_video_info {} && $(get_local_file_thumbnail)" \
        --layout reverse \
        --delimiter / \
        --with-nth -1) \
        || return

    exec nohup mpv $FZF_EXEC
}

function search_youtube() {
    YTFZF_EXEC=$(ytfzf \
        -t \
        -T tupimage \
        --sort-name=alpha \
        --preview-side=right \
        --thumbnail-quality=maxresdefault \
        --ii=https://invidious.snopyta.org \
        -I L) \
        || return

    exec nohup mpv --ytdl=no $YTFZF_EXEC
}

export FZF_DEFAULT_OPTS="--prompt 'SELECT A VIDEO: ' --header ' ' --pointer '->' --color 'bg+:8,gutter:-1,border:8,pointer:2,prompt:1'"

$@
