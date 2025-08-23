# =============================================================================
# 延迟加载配置
# =============================================================================

# 🔍 Zoxide 初始化
if command -v zoxide > /dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"  # 使用 cd 作为别名
else
  echo "⚠️  Zoxide not found. Install with: brew install zoxide"
fi

# 🐍 Conda 延迟初始化
_init_conda() {
  __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "/opt/miniconda/base/etc/profile.d/conda.sh" ]; then
      . "/opt/miniconda/base/etc/profile.d/conda.sh"
    else
      export PATH="/opt/miniconda/base/bin:$PATH"
    fi
  fi
  unset __conda_setup
}

# 只在使用 conda 命令时才初始化
conda() {
  unfunction conda
  _init_conda
  conda "$@"
}

# 📦 UV 补全延迟加载
uv() {
  unfunction uv
  eval "$(command uv generate-shell-completion zsh)"
  command uv "$@"
}

# 🏃‍♂️ 重置 conda 环境
if [ "${CONDA_SHLVL:-0}" -gt 1 ]; then
    for i in $(seq 1 $CONDA_SHLVL); do
        conda deactivate 2>/dev/null
    done
fi 