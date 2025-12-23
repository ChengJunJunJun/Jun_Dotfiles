#!/bin/bash

input="$1"

if [[ -z "$input" ]]; then
  exit 0
fi

# Check if input is a number (index) or a name
if [[ "$input" =~ ^[0-9]+$ ]]; then
  # Input is a number - treat as index
  target=$(tmux list-sessions -F '#{session_id}' 2>/dev/null | sed -n "${input}p")
else
  # Input is a name - search by session name
  target=$(tmux list-sessions -F '#{session_id} #{session_name}' 2>/dev/null | awk -v name="$input" '$2 == name {print $1; exit}')
fi

if [[ -n "$target" ]]; then
  tmux switch-client -t "$target"
  tmux refresh-client -S
fi