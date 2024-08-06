export ZSH_DOTS_THEME=$HOME/.zsh/kohi

[[ ! -f $ZSH_DOTS_THEME/.zshrc ]] || source $ZSH_DOTS_THEME/.zshrc

yt-archive() {
    yt-dlp --embed-chapters \
        --concurrent-fragments 5 \
        --restrict-filenames \
        --write-description \
        --write-subs \
        --write-auto-subs \
        --sub-langs="en.*" \
        --paths="~/Archival/" \
        "$@"
}
