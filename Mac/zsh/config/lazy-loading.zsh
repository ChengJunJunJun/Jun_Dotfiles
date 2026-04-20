# =============================================================================
# 延迟加载配置
# =============================================================================

# 🔍 Zoxide 初始化
if command -v zoxide > /dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
else
  echo "⚠️  Zoxide not found. Install with: brew install zoxide"
fi

# 🐍 Conda 延迟初始化
_init_conda() {
  local conda_exe conda_prefix __conda_setup candidate

  for candidate in \
    "${CONDA_EXE:-}" \
    /opt/miniconda3/bin/conda \
    "$HOME/miniconda3/bin/conda" \
    /opt/homebrew/Caskroom/miniconda/base/bin/conda \
    /usr/local/Caskroom/miniconda/base/bin/conda; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      conda_exe="$candidate"
      break
    fi
  done

  [[ -n "$conda_exe" ]] || {
    echo "⚠️  Conda not found. Install Miniconda or set CONDA_EXE."
    return 127
  }
  conda_prefix="${conda_exe:h:h}"

  __conda_setup="$("$conda_exe" shell.zsh hook 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "${conda_prefix}/etc/profile.d/conda.sh" ]; then
      . "${conda_prefix}/etc/profile.d/conda.sh"
    else
      export PATH="${conda_prefix}/bin:$PATH"
    fi
  fi
}

# 只在使用 conda 命令时才初始化
conda() {
  unfunction conda
  _init_conda
  conda "$@"
  local status=$?
  (( ${+functions[normalize_path_entries]} )) && normalize_path_entries
  return $status
}

# 📦 UV 补全延迟加载
uv() {
  unfunction uv
  eval "$(command uv generate-shell-completion zsh)"
  command uv "$@"
}

# 🐍 进入 uv 项目时自动激活本地 .venv，离开时自动退出
autoload -Uz add-zsh-hook

_find_uv_project_root() {
  local dir="$PWD"

  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/pyproject.toml" && -d "$dir/.venv" && -f "$dir/.venv/bin/activate" ]]; then
      if [[ -f "$dir/uv.lock" ]] || command grep -q '^\[tool\.uv' "$dir/pyproject.toml" 2>/dev/null; then
        print -r -- "$dir"
        return 0
      fi
    fi
    dir="${dir:h}"
  done

  return 1
}

_deactivate_auto_uv_env() {
  local auto_venv_bin

  if [[ -z "${_AUTO_UV_VIRTUAL_ENV:-}" && -n "${VIRTUAL_ENV:-}" && "${VIRTUAL_ENV:t}" == ".venv" ]]; then
    _AUTO_UV_VIRTUAL_ENV="${VIRTUAL_ENV}"
    export _AUTO_UV_VIRTUAL_ENV
  fi

  [[ -n "${_AUTO_UV_VIRTUAL_ENV:-}" ]] || return 0
  auto_venv_bin="${_AUTO_UV_VIRTUAL_ENV}/bin"

  if [[ "${VIRTUAL_ENV:-}" == "${_AUTO_UV_VIRTUAL_ENV}" ]] && (( ${+functions[deactivate]} )); then
    deactivate >/dev/null 2>&1
  fi

  path=(${path:#$auto_venv_bin})
  export PATH

  [[ "${VIRTUAL_ENV:-}" == "${_AUTO_UV_VIRTUAL_ENV}" ]] && unset VIRTUAL_ENV VIRTUAL_ENV_PROMPT PYTHONHOME
  (( ${+functions[normalize_path_entries]} )) && normalize_path_entries
  hash -r 2>/dev/null

  unset _AUTO_UV_VIRTUAL_ENV _AUTO_UV_PROJECT_ROOT
}

_auto_activate_uv_env() {
  local project_root venv_path

  project_root="$(_find_uv_project_root)" || {
    _deactivate_auto_uv_env
    return 0
  }

  venv_path="${project_root}/.venv"

  if [[ "${VIRTUAL_ENV:-}" == "$venv_path" ]]; then
    _AUTO_UV_VIRTUAL_ENV="$venv_path"
    _AUTO_UV_PROJECT_ROOT="$project_root"
    export _AUTO_UV_VIRTUAL_ENV _AUTO_UV_PROJECT_ROOT
    return 0
  fi

  if [[ -n "${_AUTO_UV_VIRTUAL_ENV:-}" && "${VIRTUAL_ENV:-}" == "${_AUTO_UV_VIRTUAL_ENV}" ]]; then
    _deactivate_auto_uv_env
  elif [[ -n "${VIRTUAL_ENV:-}" ]]; then
    return 0
  fi

  source "${venv_path}/bin/activate"
  _AUTO_UV_VIRTUAL_ENV="$venv_path"
  _AUTO_UV_PROJECT_ROOT="$project_root"
  export _AUTO_UV_VIRTUAL_ENV _AUTO_UV_PROJECT_ROOT
}

add-zsh-hook chpwd _auto_activate_uv_env
_auto_activate_uv_env
