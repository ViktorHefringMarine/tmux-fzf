#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

current_session=$(tmux display-message -p | sed -e 's/^\[//' -e 's/\].*//')
#         # sessions=$(echo $sessions | sed -E 's/: .*$//g')
if [[ -z "$TMUX_FZF_SESSION_FORMAT" ]]; then
    sessions=$(tmux list-sessions | sed -E "s/$current_session/*$current_session/" | sed -E 's/: .*$//g')
else
    sessions=$(tmux list-sessions -F "#S: $TMUX_FZF_SESSION_FORMAT" | sed -E "s/$current_session/*$current_session/"  | sed -E 's/: *$//g')
fi
# sessions=$(echo $sessions | sed -E 's/\: *$//g')

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select an action.'"
if [[ -z "$1" ]]; then
    action=$(printf "attach\ndetach\nrename\nkill\n" | eval "$TMUX_FZF_BIN $SESSION_FZF_OPTIONS")
else
    action="$1"
fi

[[ "$action" == "[cancel]" || -z "$action" ]] && exit
if [[ "$action" != "detach" ]]; then
    if [[ "$action" == "kill" ]]; then
        FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target session(s). Press TAB to mark multiple items.'"
    else
        FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='---SESSION---'"
    fi
    if [[ "$action" == "attach" ]]; then
        target_origin=$(printf "%s\n" "$sessions" | eval "$TMUX_FZF_BIN $SESSION_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS $SESSION_FZF_PREVIEW_FRAME")
    else
        target_origin=$(printf "[current]\n%s\n" "$sessions" | eval "$TMUX_FZF_BIN $SESSION_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS $SESSION_FZF_PREVIEW_FRAME")
        # target_origin=$(echo "$target_origin" | sed -E "s/\[current\]/$current_session:/")
    fi
else
    tmux_attached_sessions=$(tmux list-sessions | grep 'attached' | grep -o '^[[:alpha:][:digit:]_-]*:' | sed 's/.$//g')
    sessions=$(echo "$sessions" | grep "^$tmux_attached_sessions")
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target session(s). Press TAB to mark multiple items.'"
    target_origin=$(printf "[current]\n%s\n" "$sessions" | eval "$TMUX_FZF_BIN $SESSION_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS $SESSION_FZF_PREVIEW_FRAME")
    target_origin=$(echo "$target_origin" | sed -E "s/\[current\]/$current_session:/")
fi

[[ "$target_origin" == "[cancel]" || -z "$target_origin" ]] && exit

target=$(echo "$target_origin")
if [[ "$action" == "attach" ]]; then
    target=$(echo "$target" | sed -E 's/^\*//')
    echo "$target" | xargs tmux switch-client -t
elif [[ "$action" == "detach" ]]; then
    target=$(echo "$target" | sed -E 's/^\*//')
    echo "$target" | xargs -I{} tmux detach -s {}
elif [[ "$action" == "kill" ]]; then
    target=$(echo "$target" | sed -E 's/^\*//')
    echo "$target" | sort -r | xargs -I{} tmux kill-session -t {}
elif [[ "$action" == "rename" ]]; then
    target=$(echo "$target" | sed -E 's/^\*//')
    tmux command-prompt -I "rename-session -t $target "
fi

# CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# source "$CURRENT_DIR/.envs"
#
# current_session=$(tmux display-message -p | sed -e 's/^\[//' -e 's/\].*//')
# sessions=$(tmux list-sessions -F "#S $TMUX_FZF_SESSION_FORMAT" | sed -E "s/$current_session/*$current_session/")
#
# FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='---SESSIONS---'"
#
# if [[ -z "$1" ]]; then
#     action=$(printf "attach\ndetach\nrename\nkill\n[cancel]" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS")
# else
#     action="$1"
# fi
#
# [[ "$action" == "[cancel]" || -z "$action" ]] && exit
# if [[ "$action" != "detach" ]]; then
#     if [[ "$action" == "kill" ]]; then
#         FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target session(s). Press TAB to mark multiple items.'"
#     else
#         FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"
#     fi
#     if [[ "$action" == "attach" ]]; then
#         # sessions=$(echo $sessions | sed -E 's/: .*$//g')
#         target_origin=$(printf "$sessions" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS")
#     else
#         target_origin=$(printf "[current]\n%s\n[cancel]" "$sessions" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS")
#         target_origin=$(echo "$target_origin" | sed -E "s/\[current\]/$current_session:/")
#     fi
# else
#     tmux_attached_sessions=$(tmux list-sessions | grep 'attached' | grep -o '^[[:alpha:][:digit:]_-]*:' | sed 's/.$//g')
#     sessions=$(echo "$sessions" | grep "^$tmux_attached_sessions")
#     FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target session(s). Press TAB to mark multiple items.'"
#     target_origin=$(printf "[current]\n%s\n[cancel]" "$sessions" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS")
#     target_origin=$(echo "$target_origin" | sed -E "s/\[current\]/$current_session:/")
# fi
# [[ "$target_origin" == "[cancel]" || -z "$target_origin" ]] && exit
# target=$(echo "$target_origin" | grep -o '^[[:alpha:][:digit:]_-]*:' | sed 's/.$//g')
# if [[ "$action" == "attach" ]]; then
#     target=$(echo "$target" | sed -E 's/^\*//')
#     echo "$target" | xargs tmux switch-client -t
# elif [[ "$action" == "detach" ]]; then
#     target=$(echo "$target" | sed -E 's/^\*//')
#     echo "$target" | xargs -I{} tmux detach -s {}
# elif [[ "$action" == "kill" ]]; then
#     target=$(echo "$target" | sed -E 's/^\*//')
#     echo "$target" | sort -r | xargs -I{} tmux kill-session -t {}
# elif [[ "$action" == "rename" ]]; then
#     target=$(echo "$target" | sed -E 's/^\*//')
#     tmux command-prompt -I "rename-session -t $target "
# fi
