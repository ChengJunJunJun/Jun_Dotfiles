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

# GNU 工具与 zsh 补全共用的颜色配置
export LS_COLORS="${LS_COLORS:-di=1;34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43:or=31;1:mi=31;1}"

# PATH 规范化与去重
normalize_path_entries() {
  local entry
  local -a normalized_path=()

  for entry in "${path[@]}"; do
    [[ -n "$entry" && -d "$entry" ]] || continue
    # 从旧配置继承的 Zinit fd/rg 路径不再参与命令解析。
    [[ "$entry" == "$HOME/.local/share/zinit/plugins/sharkdp---fd"* ]] && continue
    [[ "$entry" == "$HOME/.local/share/zinit/plugins/BurntSushi---ripgrep"* ]] && continue
    normalized_path+=("${entry:A}")
  done

  path=("${normalized_path[@]}")
  typeset -gU path PATH
  export PATH
  hash -r 2>/dev/null
}

# 按参数顺序前置存在的用户级与 Linux 工具目录
_path_prepend() {
  local dir
  local -a existing_dirs=()

  for dir in "$@"; do
    [[ -d "$dir" ]] && existing_dirs+=("$dir")
  done
  path=("${existing_dirs[@]}" $path)
}

_path_prepend \
  "$HOME/.grok/bin" \
  "$HOME/.local/bin" \
  "$HOME/bin" \
  /opt/nvim-linux-arm64/bin \
  /opt/nvim-linux-x86_64/bin

normalize_path_entries
unfunction _path_prepend

# 语言环境：Ubuntu/Debian 不保证已经生成 en_US.UTF-8
if locale -a 2>/dev/null | command grep -Eqi '^en_US\.(UTF-8|utf8)$'; then
  export LANG=en_US.UTF-8
else
  export LANG=C.UTF-8
fi
unset LC_ALL

# 仓库根目录的本地密钥（已在 .gitignore）
if [[ -n "${DOTFILES_ROOT:-}" && -r "${DOTFILES_ROOT}/.env" ]]; then
  set -a
  source "${DOTFILES_ROOT}/.env"
  set +a
fi
