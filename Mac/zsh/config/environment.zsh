# =============================================================================
# 环境变量和PATH配置
# =============================================================================

# 🎨 基础环境变量
export TERM=xterm-256color
export EDITOR='nvim'
export VISUAL='nvim'

# 🗂️ XDG 规范配置
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# 🧹 PATH 规范化与去重
normalize_path_entries() {
  local entry
  local -a normalized_path=()

  for entry in "${path[@]}"; do
    [[ -n "$entry" ]] || continue
    normalized_path+=("${entry:A}")
  done

  path=("${normalized_path[@]}")
  typeset -gU path PATH
  export PATH
  hash -r 2>/dev/null
}

# 🔄 PATH 配置
path=(
  "$HOME/.local/bin"                      # uv 等 Python 用户级工具
  "$HOME/.antigravity/antigravity/bin"
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /opt/homebrew/opt/node@22/bin
  /opt/homebrew/opt/rustup/bin
  /Library/TeX/texbin
  $path
)
normalize_path_entries

# # surge 配置（使终端生效）
# export https_proxy=http://127.0.0.1:6152
# export http_proxy=http://127.0.0.1:6152
# export all_proxy=socks5://127.0.0.1:6153

# 🔧 开发工具配置
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1

# 🌍 语言环境
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 🔐 仓库根目录的本地密钥（已在 .gitignore）
if [[ -r "${DOTFILES_ROOT}/.env" ]]; then
  set -a
  source "${DOTFILES_ROOT}/.env"
  set +a
fi
