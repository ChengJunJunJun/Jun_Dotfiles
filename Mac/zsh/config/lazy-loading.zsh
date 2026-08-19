# =============================================================================
# 延迟加载与智能环境（zoxide / conda / uv）
# =============================================================================

# Zoxide：保留原生 cd，用 z / zi 智能跳转。
# 排进 zdefer 而非直接 eval——zoxide 的 compdef 需要 compinit 已跑完才生效。
if [[ -x "$HOMEBREW_PREFIX/bin/zoxide" ]] || (( ${+commands[zoxide]} )); then
  zdefer 'eval "$(zoxide init zsh)"'
else
  print -u2 "⚠️  Zoxide not found. Install with: brew install zoxide"
fi

# ---------------------------------------------------------------------------
# Conda：首次调用才初始化
# ---------------------------------------------------------------------------
conda() {
  unfunction conda
  local exe ret
  for exe in "${CONDA_EXE:-}" /opt/miniconda3/bin/conda "$HOME/miniconda3/bin/conda" \
             "$HOMEBREW_PREFIX/Caskroom/miniconda/base/bin/conda"; do
    [[ -n "$exe" && -x "$exe" ]] && break
    exe=""
  done
  if [[ -z "$exe" ]]; then
    print -u2 "⚠️  Conda not found. Install Miniconda or set CONDA_EXE."
    return 127
  fi

  eval "$("$exe" shell.zsh hook 2>/dev/null)" 2>/dev/null \
    || source "${exe:h:h}/etc/profile.d/conda.sh" 2>/dev/null \
    || path=("${exe:h}" $path)

  conda "$@"
  ret=$?   # 不能用 status：zsh 中它是只读特殊变量
  normalize_path_entries
  return $ret
}

# UV：首次调用才加载补全
uv() {
  unfunction uv
  eval "$(command uv generate-shell-completion zsh)" 2>/dev/null
  command uv "$@"
}

# ---------------------------------------------------------------------------
# 进入 uv 项目时自动激活本地 .venv，离开时自动退出
# ---------------------------------------------------------------------------
autoload -Uz add-zsh-hook

_auto_uv_deactivate() {
  [[ -n "${_AUTO_UV_VENV:-}" ]] || return 0
  if [[ "${VIRTUAL_ENV:-}" == "$_AUTO_UV_VENV" ]]; then
    (( ${+functions[deactivate]} )) && deactivate >/dev/null 2>&1
    unset VIRTUAL_ENV VIRTUAL_ENV_PROMPT PYTHONHOME
  fi
  path=(${path:#$_AUTO_UV_VENV/bin})
  unset _AUTO_UV_VENV
  normalize_path_entries
}

_auto_uv_activate() {
  local dir="$PWD"
  while [[ "$dir" != / ]]; do
    if [[ -f "$dir/pyproject.toml" && -f "$dir/.venv/bin/activate" ]] &&
       { [[ -f "$dir/uv.lock" ]] ||
         command grep -q '^\[tool\.uv' "$dir/pyproject.toml" 2>/dev/null }; then
      # 已经在这个 .venv 里（含手动激活）：接管它，离开目录时负责退出
      if [[ "${VIRTUAL_ENV:-}" == "$dir/.venv" ]]; then
        typeset -gx _AUTO_UV_VENV="$dir/.venv"
        return 0
      fi
      # 手动激活的其他 venv，不抢占
      [[ -n "${VIRTUAL_ENV:-}" && -z "${_AUTO_UV_VENV:-}" ]] && return 0
      _auto_uv_deactivate
      source "$dir/.venv/bin/activate"
      typeset -gx _AUTO_UV_VENV="$dir/.venv"
      return 0
    fi
    dir="${dir:h}"
  done
  _auto_uv_deactivate
}

add-zsh-hook chpwd _auto_uv_activate
_auto_uv_activate
