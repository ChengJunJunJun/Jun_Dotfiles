# =============================================================================
# 环境变量（PATH / Homebrew 相关见 path.zsh）
# =============================================================================

export TERM="${TERM:-xterm-256color}"
export EDITOR='nvim' VISUAL='nvim'
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# macOS 颜色：BSD ls + zsh 补全（GNU 风格 LS_COLORS）
export CLICOLOR=1
export LSCOLORS='ExGxBxDxCxEgEdxbxgxcxd'
export LS_COLORS='di=1;34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43:or=31;1:mi=31;1'

export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ANALYTICS=1

# 仓库根目录的本地密钥（已在 .gitignore）
if [[ -r "${DOTFILES_ROOT:-}/.env" ]]; then
  set -a
  source "${DOTFILES_ROOT}/.env"
  set +a
fi
