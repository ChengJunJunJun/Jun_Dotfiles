# =============================================================================
# 环境变量和 PATH 配置
# =============================================================================

# 基础环境变量
export TERM="${TERM:-xterm-256color}"
export EDITOR='nvim'
export VISUAL='nvim'

# XDG 规范
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# macOS 颜色：BSD ls + zsh 补全（GNU 风格 LS_COLORS）
export CLICOLOR=1
export LSCOLORS='ExGxBxDxCxEgEdxbxgxcxd'
export LS_COLORS='di=1;34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43:or=31;1:mi=31;1'

# ---------------------------------------------------------------------------
# PATH 规范化与去重
# ---------------------------------------------------------------------------
normalize_path_entries() {
  local entry
  local -a normalized_path=()

  for entry in "${path[@]}"; do
    [[ -n "$entry" ]] || continue
    # 仅保留存在的目录，避免幽灵 PATH
    [[ -d "$entry" ]] || continue
    normalized_path+=("${entry:A}")
  done

  path=("${normalized_path[@]}")
  typeset -gU path PATH
  export PATH
  hash -r 2>/dev/null
}

# Homebrew 环境（PATH / MANPATH / HOMEBREW_*）
if (( ! ${+commands[brew]} )); then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  eval "$(brew shellenv)"
fi

# 按优先级前置自定义路径（目录存在才加入）
_path_prepend() {
  local dir
  for dir in "$@"; do
    [[ -d "$dir" ]] && path=("$dir" $path)
  done
}

_path_prepend \
  "$HOME/.grok/bin" \
  "$HOME/.local/bin" \
  /opt/homebrew/opt/rustup/bin \
  /usr/local/opt/rustup/bin \
  /Library/TeX/texbin

# Node：优先无版本 keg，再回退常见 major 版本
_node_bin=""
for _node_prefix in \
  /opt/homebrew/opt/node \
  /usr/local/opt/node \
  /opt/homebrew/opt/node@22 \
  /usr/local/opt/node@22 \
  /opt/homebrew/opt/node@20 \
  /usr/local/opt/node@20; do
  if [[ -d "${_node_prefix}/bin" ]]; then
    _node_bin="${_node_prefix}/bin"
    break
  fi
done
[[ -n "$_node_bin" ]] && path=("$_node_bin" $path)
unset _node_bin _node_prefix

normalize_path_entries
unfunction _path_prepend

# 开发工具 / Homebrew 行为
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1

# 语言环境
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 仓库根目录的本地密钥（已在 .gitignore）
if [[ -n "${DOTFILES_ROOT:-}" && -r "${DOTFILES_ROOT}/.env" ]]; then
  set -a
  source "${DOTFILES_ROOT}/.env"
  set +a
fi
