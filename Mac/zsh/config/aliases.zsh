# =============================================================================
# 别名配置
# =============================================================================

# ⚡ 基础系统别名
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# 🍺 Homebrew 别名
alias up="brew update && brew upgrade && brew cu -a -y && brew cleanup --prune=all && brew autoremove && brew doctor --quiet"
alias uninstall="brew uninstall --cask --force --zap"
alias update-ai="npm update -g @anthropic-ai/claude-code @openai/codex"

# 刷新 DNS 缓存
alias refresh="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# 🔄 系统管理别名
alias s.="source ~/.zshrc"
alias echopath="echo \$PATH | tr ':' '\n' | nl"

# 🖥️ SSH 连接别名
alias ssh4090="ssh -p 41380 chengjun@110os9214fc69.vicp.fun"
alias ssh3090="ssh -p 35515 chengjun@110os9214fc69.vicp.fun"

# 📝 编辑器别名
alias vim='nvim'
alias vi='nvim'

# 🔍 文件搜索别名
alias fdf='fd --type f --hidden --follow'
alias fdd='fd --type d --hidden --follow'
alias rga='rg --smart-case --hidden --follow --no-heading --line-number'

alias rust_up="rustup update stable"
alias lg="lazygit"

# tmux 别名
alias tmux_new="tmux new -s "
alias tmux_attach="tmux attach -t "
alias tmux_kill="tmux kill-session -t "
alias tmux_list="tmux ls"
alias tmux_rename="tmux rename-session -t "
alias tmux_rename_current="tmux rename-session -t "
alias tmux_rename_current="tmux rename-session -t "