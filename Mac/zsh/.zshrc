# =============================================================================
# 模块化 Zsh 配置 - 主入口文件
# =============================================================================

# 基于当前文件位置推导配置路径，避免硬编码仓库目录
ZSHRC_PATH="${${(%):-%N}:A}"
ZSH_BASE_DIR="${ZSHRC_PATH:h}"
DOTFILES_ROOT="${ZSH_BASE_DIR:h:h}"
ZSH_CONFIG_DIR="${ZSH_BASE_DIR}/config"
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump"

# 模块加载函数
load_config() {
  local config_file="$1"
  local config_path="${ZSH_CONFIG_DIR}/${config_file}"

  if [[ -f "$config_path" ]]; then
    source "$config_path"
  else
    echo "⚠️  Config file not found: $config_path"
  fi
}

# 重新加载配置前，清理当前 shell 中已激活的 Conda 环境
reset_active_conda_env() {
  local level prefix max_level

  (( ${CONDA_SHLVL:-0} > 0 )) || return 0

  if [[ -n "${CONDA_PREFIX:-}" ]]; then
    path=("${(@)path:#${CONDA_PREFIX}/bin}")
  fi

  max_level=${CONDA_SHLVL:-0}
  for (( level = 1; level <= max_level; level++ )); do
    prefix="${(P)${:-CONDA_PREFIX_${level}}}"
    [[ -n "$prefix" ]] && path=("${(@)path:#${prefix}/bin}")
    unset "CONDA_PREFIX_${level}"
  done

  export PATH
  hash -r 2>/dev/null

  unset CONDA_PREFIX CONDA_DEFAULT_ENV CONDA_PROMPT_MODIFIER CONDA_SHLVL
  unset CONDA_EXE CONDA_PYTHON_EXE _CE_CONDA _CE_M
}

reset_active_conda_env

# 加载顺序说明：
# 1. performance  - fpath / 历史 / setopt（不含 compinit）
# 2. environment  - 环境变量与 PATH
# 3. completion   - zstyle；提供 _zsh_run_compinit
# 4. plugins      - zinit turbo + zicompinit（或 fallback compinit）
# 5. keybindings  - 快捷键
# 6. aliases      - 别名
# 7. fzf          - 模糊搜索（会覆盖 ^R 等）
# 8. lazy-loading - conda / uv / zoxide 等
load_config "performance.zsh"
load_config "environment.zsh"
load_config "completion.zsh"
load_config "plugins.zsh"
load_config "keybindings.zsh"
load_config "aliases.zsh"
load_config "fzf.zsh"
load_config "lazy-loading.zsh"

# 清理临时函数与路径变量
unfunction load_config
unfunction reset_active_conda_env
unset ZSHRC_PATH ZSH_BASE_DIR
