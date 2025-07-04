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
alias rust_up="rustup update stable"
alias uninstall="brew uninstall --cask --force --zap"

# 🔄 系统管理别名
alias s.="source ~/.zshrc"
alias echopath="echo \$PATH | tr ':' '\n' | nl"

# 🖥️ SSH 连接别名
alias ssh4090="ssh -p 49919 chengjun@i38944o710.goho.co"
alias ssh3090="ssh -p 29050 chengjun@i38944o710.goho.co"

# 📝 编辑器别名
alias vim='nvim'
alias vi='nvim'

# 🔍 文件搜索别名
alias fdf='fd --type f --hidden --follow'
alias fdd='fd --type d --hidden --follow'
alias rga='rg --smart-case --hidden --follow --no-heading --line-number'