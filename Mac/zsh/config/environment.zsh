# =============================================================================
# 环境变量和PATH配置
# =============================================================================

# 🎨 基础环境变量
export TERM=xterm-256color
export EDITOR='nvim'
export VISUAL='nvim'

# 🔄 PATH 配置
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
export PATH="/Library/TeX/texbin:$PATH"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '!a[$1]++' | sed 's/:$//')
export PATH="/Users/cj/.local/share/../bin:$PATH"                              # 支持 uv 

# surge 配置（使终端生效）
export https_proxy=http://127.0.0.1:6152
export http_proxy=http://127.0.0.1:6152
export all_proxy=socks5://127.0.0.1:6153

# 🗂️ XDG 规范配置
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# 🔧 开发工具配置
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1

# 🌍 语言环境
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8 