# =============================================================================
# 环境变量和 PATH 配置
# =============================================================================

# 基础环境变量
export TERM="${TERM:-xterm-256color}"
export EDITOR='nvim'
export VISUAL='nvim'

# XDG 规范配置
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# PATH 规范化与去重
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

# PATH 配置
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  /opt/nvim-linux-arm64/bin
  /opt/nvim-linux-x86_64/bin
  /usr/local/bin
  /usr/local/sbin
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  $path
)
normalize_path_entries

# 语言环境
if locale -a 2>/dev/null | command grep -qi '^en_US\.utf8\|^en_US\.UTF-8$'; then
  export LANG=en_US.UTF-8
else
  export LANG=C.UTF-8
fi
unset LC_ALL

# 仓库根目录的本地密钥（已在 .gitignore）
if [[ -r "${DOTFILES_ROOT}/.env" ]]; then
  set -a
  source "${DOTFILES_ROOT}/.env"
  set +a
fi
