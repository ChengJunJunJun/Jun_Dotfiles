# =============================================================================
# 别名配置
# =============================================================================

# 基础系统别名
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Ubuntu 系统管理别名
alias up='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean'
alias update-ai='npm update -g @anthropic-ai/claude-code @openai/codex'

refresh() {
  if command -v resolvectl >/dev/null 2>&1; then
    sudo resolvectl flush-caches
  else
    echo "resolvectl not found; DNS cache flush is unavailable on this system."
    return 127
  fi
}

alias s.="exec zsh"
alias echopath="echo \$PATH | tr ':' '\n' | nl"

# SSH 连接别名
alias ssh4090="ssh -p 41380 chengjun@110os9214fc69.vicp.fun"
alias ssh3090="ssh -p 35515 chengjun@110os9214fc69.vicp.fun"

# 编辑器别名
alias vim='nvim'
alias vi='nvim'

# 文件搜索别名
if command -v fd >/dev/null 2>&1; then
  alias fdf='fd --type f --hidden --follow'
  alias fdd='fd --type d --hidden --follow'
elif command -v fdfind >/dev/null 2>&1; then
  alias fdf='fdfind --type f --hidden --follow'
  alias fdd='fdfind --type d --hidden --follow'
fi
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

# codex 自定义api
alias codex-proxy='OPENAI_API_KEY=$MY_PROXY_KEY CODEX_HOME=$HOME/.codex-proxy codex'
