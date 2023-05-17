#!/bin/bash

function _get_local_file_info() {
    echo 'printf "$(tput setaf 6)%s$(tput sgr0)\n" $(ffprobe -v error -select_streams v:0 -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 {})'
    echo 'printf "$(tput setaf 4)Duration   $(tput setaf 3)%s$(tput sgr0)\n" $(ffprobe -v error -select_streams v:0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal {} | sed "s/\..*//")'
    echo 'printf "$(tput setaf 4)Resolution $(tput setaf 5)%s$(tput sgr0)\n" $(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 {})'
    echo 'printf "$(tput setaf 4)Bit rate   $(tput setaf 2)%s kb/s$(tput sgr0)\n" $(ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 {} | xargs -I{} expr {} / 1000)'
    echo 'printf "$(tput setaf 4)Audio      $(tput setaf 6)%s (%s), %sHz, %s$(tput sgr0)\n" $(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,codec_tag_string,sample_rate,channel_layout -of default=noprint_wrappers=1:nokey=1 {})'
}

function _get_local_file_thumbnail() {
    echo 'ffmpegthumbnailer -s 0 -i {} -o /tmp/fzf-thumb.png && tupimage --force-upload --less-diacritics --fzf /tmp/fzf-thumb.png'
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
        --preview "$(_get_local_file_info) && $(_get_local_file_thumbnail)" \
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

$1
