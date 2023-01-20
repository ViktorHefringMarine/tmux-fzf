#!/usr/bin/env bash

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='---TMUXINATOR---'"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

current_session=$(tmux display-message -p | sed -e 's/^\[//' -e 's/\].*//')


target=$(ls ~/.config/tmuxinator | sed -E 's/\..*$/\t\t\t\t\t\t\t\t\t\t\t/' | sed -E 's/s*//' | sed -E "s/$current_session/*$current_session/" | eval "$TMUX_FZF_BIN $TMUXINATOR_FZF_OPTIONS")

[[ "$target" == "[cancel]" || -z "$target" ]] && exit
if [[ -n $(echo "$target" | grep -o "copy-mode") && -z $(echo "$target" | grep -o "prefix") ]]; then
    target=$(echo "$target" | sed -E 's/^\*//')
    echo "$target" | xargs tmuxinator start
else
    target=$(echo "$target" | sed -e 's/^\*//')
    echo "$target" | xargs tmuxinator start
fi

