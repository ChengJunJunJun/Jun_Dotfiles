# =============================================================================
# 模块化 Zsh 配置 - 主入口文件
# =============================================================================

# 基于当前文件位置推导配置路径，避免硬编码仓库目录
ZSH_BASE_DIR="${${(%):-%N}:A:h}"
DOTFILES_ROOT="${ZSH_BASE_DIR:h:h}"
ZSH_CONFIG_DIR="${ZSH_BASE_DIR}/config"
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump"

# 重新加载（exec zsh）前，清理当前 shell 中已激活的 Conda 环境
if (( ${CONDA_SHLVL:-0} > 0 )); then
  for _cv in CONDA_PREFIX CONDA_PREFIX_{1..${CONDA_SHLVL}}; do
    [[ -n "${(P)_cv}" ]] && path=("${(@)path:#${(P)_cv}/bin}")
  done
  unset _cv CONDA_PREFIX CONDA_PREFIX_{1..${CONDA_SHLVL}} CONDA_DEFAULT_ENV \
        CONDA_PROMPT_MODIFIER CONDA_SHLVL CONDA_EXE CONDA_PYTHON_EXE _CE_CONDA _CE_M
  export PATH
  hash -r 2>/dev/null
fi

# 延迟队列：模块把「不必阻塞首个提示符」的初始化排进来，
# 由 plugins.zsh 的 zle -F 回调在提示符画出、ZLE 空闲后统一执行
typeset -ga _zsh_defer_cmds
zdefer() { _zsh_defer_cmds+=("$1") }

# 加载顺序：
#   path        - XDG / Homebrew / PATH（提供 normalize_path_entries）
#   environment - 环境变量（LS_COLORS 需早于 performance 的 zstyle）
#   performance - fpath / 历史 / setopt / 补全样式（提供 _zsh_run_compinit）
#   keybindings - 快捷键
#   aliases     - 别名
#   fzf / lazy-loading - 只导出变量，重活排进 zdefer
#   plugins     - 最后：starship + zle -F 延迟执行器（需收齐 zdefer 队列）
for _mod in path environment performance keybindings aliases fzf lazy-loading plugins; do
  if [[ -r "${ZSH_CONFIG_DIR}/${_mod}.zsh" ]]; then
    source "${ZSH_CONFIG_DIR}/${_mod}.zsh"
  else
    print -u2 "⚠️  Config file not found: ${ZSH_CONFIG_DIR}/${_mod}.zsh"
  fi
done
unset _mod ZSH_BASE_DIR
