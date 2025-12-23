#!/bin/bash

# Get current session info
current_session=$(tmux display-message -p '#{session_name}')
total_sessions=$(tmux list-sessions | wc -l | tr -d ' ')

# If this is the only session, just kill it (will exit tmux)
if [ "$total_sessions" -eq 1 ]; then
    tmux kill-session -t "$current_session"
    exit 0
fi

# Find another session to switch to (prefer next, fallback to previous)
next_session=$(tmux list-sessions -F '#{session_name}' | grep -A1 "^${current_session}$" | tail -n1)

# If current session is the last one, get the first session
if [ "$next_session" = "$current_session" ] || [ -z "$next_session" ]; then
    next_session=$(tmux list-sessions -F '#{session_name}' | head -n1)
fi

# Switch to the next session first
tmux switch-client -t "$next_session"

# Then kill the original session
tmux kill-session -t "$current_session"