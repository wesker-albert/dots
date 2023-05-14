function spawn_mpv() {
    VIDEO_DIR="$HOME/Videos/"
    ALLOWED_FILE_TYPES=".*.(mp4|avi)"

    exec nohup mpv $(find $VIDEO_DIR -regextype posix-extended -regex $ALLOWED_FILE_TYPES -type f | sort | fzf --reverse --border --delimiter / --with-nth -1)
}

$1
