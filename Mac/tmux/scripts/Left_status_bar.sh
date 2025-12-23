#!/bin/bash
# Catppuccin Mocha colors
thm_bg="#1e1e2e"
thm_fg="#cdd6f4"
thm_green="#a6e3a1"
thm_gray="#313244"
thm_blue="#89b4fa"
thm_magenta="#cba6f7"

current_session=$(tmux display-message -p '#S')

# Get all sessions and format them
sessions=$(tmux list-sessions -F '#S' 2>/dev/null)

output=""
index=1
for session in $sessions; do
    if [ "$session" = "$current_session" ]; then
        # Active session - highlighted with green background
        output+="#[fg=$thm_bg,bg=$thm_magenta,bold] $index:$session #[fg=$thm_magenta,bg=$thm_bg]"
    else
        # Inactive session - dimmed with blue background
        output+="#[fg=$thm_bg,bg=$thm_gray] $index:$session #[fg=$thm_gray,bg=$thm_bg]"
    fi
    ((index++))
done

echo "$output"