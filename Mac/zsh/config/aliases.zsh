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

# Homebrew：完整升级（brew cu 可选，避免未装 tap 时整条失败）
up() {
  brew update && brew upgrade || return $?
  if brew cu --help &>/dev/null; then
    brew cu -a -y || true
  fi
  brew cleanup --prune=all
  brew autoremove
  brew doctor --quiet
}

# 卸载 cask 并 zap 残留（故意不用通用名 uninstall）
alias brew-zap='brew uninstall --cask --force --zap'
alias update-ai='npm update -g @anthropic-ai/claude-code @openai/codex'

# 刷新 DNS 缓存
alias refresh='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# 系统管理
alias s.='exec zsh'
alias echopath='echo $PATH | tr ":" "\n" | nl'

# SSH：主机/端口/用户写在 ~/.ssh/config（Host 4090 / 3090）
alias ssh4090='ssh 4090'
alias ssh3090='ssh 3090'

# 编辑器
alias vim='nvim'
alias vi='nvim'

# 文件搜索
alias fdf='fd --type f --hidden --follow'
alias fdd='fd --type d --hidden --follow'
alias rga='rg --smart-case --hidden --follow --no-heading --line-number'

alias rust_up='rustup update stable'
alias lg='lazygit'

# tmux
alias tmux_new='tmux new -s'
alias tmux_attach='tmux attach -t'
alias tmux_kill='tmux kill-session -t'
alias tmux_list='tmux ls'
alias tmux_rename='tmux rename-session -t'
alias tmux_rename_current='tmux rename-session'

# codex 自定义 api
alias codex-proxy='OPENAI_API_KEY=$MY_PROXY_KEY CODEX_HOME=$HOME/.codex-proxy codex'
