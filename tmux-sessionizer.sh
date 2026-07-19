#!/usr/bin/env bash

# This piece of bash was most likely written by @ThePrimaGen and adapted to my liking
# I mostly understand it but it's really annoying to read and I'm too lazy to rewrite it. If it's not broken, why fix it?

sanity_check() {
    if ! command -v tmux &>/dev/null; then
        echo "tmux is not installed. Please install it first."
        exit 1
    fi

    if ! command -v fzf &>/dev/null; then
        echo "fzf is not installed. Please install it first."
        exit 1
    fi
}

switch_to() {
    if [[ -z $TMUX ]]; then
        tmux attach-session -t "$1"
    else
        tmux switch-client -t "$1"
    fi
}

has_session() {
    tmux list-sessions | grep -q "^$1:"
}

sanity_check

# if TS_SEARCH_PATHS is not set use default
[[ -n "$TS_SEARCH_PATHS" ]] || TS_SEARCH_PATHS=(~/ ~/dev ~/dev/env/.config)

# Add any extra search paths to the TS_SEARCH_PATHS array
# e.g : EXTRA_SEARCH_PATHS=("$HOME/extra1:4" "$HOME/extra2")
# note : Path can be suffixed with :number to limit or extend the depth of the search for the Path

TS_EXTRA_SEARCH_PATHS=(~/personal/programming/ ~/personal/univ/ ~/personal/univ/L1/ ~/personal/univ/L2/ ~/personal/univ/L3/ ~/personal/programming/probe/ ~/personal/programming/thirdparty/)
if [[ ${#TS_EXTRA_SEARCH_PATHS[@]} -gt 0 ]]; then
    TS_SEARCH_PATHS+=("${TS_EXTRA_SEARCH_PATHS[@]}")
fi

# utility function to find directories
find_dirs() {
    # list TMUX sessions
    if [[ -n "${TMUX}" ]]; then
        current_session=$(tmux display-message -p '#S')
        tmux list-sessions -F "[TMUX] #{session_name}" 2>/dev/null | grep -vFx "[TMUX] $current_session"
    else
        tmux list-sessions -F "[TMUX] #{session_name}" 2>/dev/null
    fi

    # note: TS_SEARCH_PATHS is an array of paths to search for directories
    # if the path ends with :number, it will search for directories with a max depth of number ;)
    # if there is no number, it will search for directories with a max depth defined by TS_MAX_DEPTH or 1 if not set
    for entry in "${TS_SEARCH_PATHS[@]}"; do
        # Check if entry as :number as suffix then adapt the maxdepth parameter
        if [[ "$entry" =~ ^([^:]+):([0-9]+)$ ]]; then
            path="${BASH_REMATCH[1]}"
            depth="${BASH_REMATCH[2]}"
        else
            path="$entry"
        fi

        [[ -d "$path" ]] && find "$path" -mindepth 1 -maxdepth "${depth:-${TS_MAX_DEPTH:-1}}" -path '*/.git' -prune -o -type d -print
    done
}

if [[ $# -eq 1 ]]; then
    selected="$1"
else
    selected=$(find_dirs | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

if [[ "$selected" =~ ^\[TMUX\]\ (.+)$ ]]; then
    selected="${BASH_REMATCH[1]}"
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

if ! has_session "$selected_name"; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

switch_to "$selected_name"
