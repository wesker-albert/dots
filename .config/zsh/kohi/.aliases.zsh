# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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
