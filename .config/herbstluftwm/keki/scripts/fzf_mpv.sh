#!/bin/bash

VIDEOS_DIR="$HOME/Videos"
PLAYLISTS_DIR="$VIDEOS_DIR/playlists"
THUMBNAILS_DIR="$VIDEOS_DIR/thumbnails"

CURRENT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

_get_json_val() {
    VAL=$(echo "$1" |
        jq "$2" |
        sed "s/\"//g")

    if [ "$VAL" != "null" ]; then
        echo "$VAL"
    fi
}

_round_up() {
    printf "%.*f" \
        "$2" \
        "$(echo "$1" | bc -l)"
}

_get_video_watch_percentage() {
    FILE_HASH=$(echo -n "$1" |
        md5sum |
        tr '[:lower:]' '[:upper:]' |
        sed "s/  -.*//")

    WATCH_LATER_FILE="$HOME/.config/mpv/watch_later/$FILE_HASH"

    if [ ! -f "$WATCH_LATER_FILE" ]; then
        return
    fi

    LAST_POSITION=$(grep -oP '(?<=start=).*' "$WATCH_LATER_FILE" |
        sed "s/\..*//")

    printf "%s%%" \
        "$(_round_up "$LAST_POSITION / $2 * 100" 1)"
}

_get_video_info() {
    VIDEO_STREAM=$(ffprobe \
        -v quiet \
        -select_streams v:0 \
        -show_entries format_tags=title \
        -show_entries format=duration \
        -show_entries stream=width,height,bit_rate \
        -of json "$@")

    AUDIO_STREAM=$(ffprobe \
        -v quiet \
        -select_streams a:0 \
        -show_entries stream=codec_name,sample_rate,channel_layout \
        -of json "$@")

    DURATION=$(_round_up "$(_get_json_val "$VIDEO_STREAM" '.format.duration')" 0)
    WATCH_PERCENTAGE=$(_get_video_watch_percentage "$@" "$DURATION")

    if [ -n "$WATCH_PERCENTAGE" ]; then
        WATCHED=" ($WATCH_PERCENTAGE watched)"
    fi

    WIDTH=$(_get_json_val "$VIDEO_STREAM" '.streams[0].width')
    HEIGHT=$(_get_json_val "$VIDEO_STREAM" '.streams[0].height')
    AUDIO_CODEC=$(_get_json_val "$AUDIO_STREAM" '.streams[0].codec_name')
    AUDIO_RATE=$(_get_json_val "$AUDIO_STREAM" '.streams[0].sample_rate')
    AUDIO_CHANNELS=$(_get_json_val "$AUDIO_STREAM" '.streams[0].channel_layout')

    if [ -n "$DURATION" ]; then
        printf "$(tput setaf 3)Duration    $(tput sgr0)%s%s\n" \
            "$(date -u -d @"${DURATION}" +"%T")" \
            "$WATCHED"
    fi

    if [ -n "$WIDTH" ] && [ -n "$HEIGHT" ]; then
        printf "$(tput setaf 3)Resolution  $(tput sgr0)%sx%s\n" \
            "$WIDTH" \
            "$HEIGHT"
    fi

    if [ -n "$AUDIO_CODEC" ] && [ -n "$AUDIO_RATE" ] && [ -n "$AUDIO_CHANNELS" ]; then
        printf "$(tput setaf 3)Audio       $(tput sgr0)%s %sHz, %s\n" \
            "$AUDIO_CODEC" \
            "$AUDIO_RATE" \
            "$AUDIO_CHANNELS"
    fi
}

# shellcheck disable=SC2261,SC2210,SC2094
_get_local_file_thumbnail() {
    FILENAME=$(basename "$1")
    THUMBNAIL="$THUMBNAILS_DIR/$FILENAME.jpg"

    VALIDATE_IMAGE=$(identify "$THUMBNAIL" 2 &>1 1>/dev/null)

    if [ ! -f "$THUMBNAIL" ] || [ -z "$VALIDATE_IMAGE" ]; then
        ffmpegthumbnailer \
            -t 25% \
            -s 386 \
            -i "$1" \
            -o "$THUMBNAIL" \
            2 &>1 1>/dev/null
    fi

    tupimage \
        --force-upload \
        --less-diacritics \
        --fzf "$THUMBNAIL"
}

search_videos() {
    ALLOWED_FILE_TYPES=".*.(mp4|avi|mkv)"

    FZF_EXEC=$(find "$VIDEOS_DIR" \
        -regextype posix-extended \
        -regex "$ALLOWED_FILE_TYPES" \
        -type f |
        sort |
        fzf \
            --border-label " SELECT A VIDEO " \
            --preview-window right,40,border-sharp \
            --preview "bash $CURRENT_DIR/fzf_mpv.sh _get_video_info {} &&
                bash $CURRENT_DIR/fzf_mpv.sh _get_local_file_thumbnail {}") ||
        return

    exec nohup mpv "$FZF_EXEC"
}

search_playlists() {
    ALLOWED_FILE_TYPES=".*.m3u"

    FZF_EXEC=$(find "$PLAYLISTS_DIR" \
        -regextype posix-extended \
        -regex "$ALLOWED_FILE_TYPES" \
        -type f |
        sort |
        fzf \
            --border-label " SELECT A PLAYLIST " \
            --preview-window bottom,10,border-sharp \
            --preview "pygmentize -l shell {}") ||
        return

    dunstify --icon mpv "Opening $(basename "$FZF_EXEC")..."

    exec nohup mpv "$FZF_EXEC"
}

if [ ! -f "$THUMBNAILS_DIR" ]; then
    mkdir -p "$THUMBNAILS_DIR"
fi

if [ ! -f "$PLAYLISTS_DIR" ]; then
    mkdir -p "$PLAYLISTS_DIR"
fi

export FZF_DEFAULT_OPTS="--border sharp
    --prompt '> '
    --info inline
    --pointer ''
    --color 'fg+:10,bg+:-1,gutter:-1,border:8,pointer:10,prompt:8,header:1'
    --layout reverse
    --delimiter /
    --with-nth -1"

"$@"
