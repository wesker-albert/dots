function spawn_mpv() {
    VIDEO_DIR="$HOME/Videos/"
    ALLOWED_FILE_TYPES='.*.(mp4|avi)'

    PROMPT="SELECT A VIDEO: "
    POINTER='->'
    COLORS='bg+:8,gutter:-1,border:8,pointer:2,prompt:1'

    FZF_EXEC=$(find $VIDEO_DIR \
        -regextype posix-extended \
        -regex $ALLOWED_FILE_TYPES \
        -type f \
        | sort \
        | fzf \
        --header ' ' \
        --prompt "$PROMPT" \
        --preview-window down \
        --preview 'rm -f /tmp/fzf-thumb.png && ffmpegthumbnailer -s 0 -i {} -o /tmp/fzf-thumb.png && tupimage --force-upload --less-diacritics --fzf /tmp/fzf-thumb.png' \
        --pointer $POINTER \
        --color $COLORS \
        --no-info \
        --layout reverse \
        --delimiter / \
        --with-nth -1) \
        || return

    exec nohup mpv $FZF_EXEC
}

$1
