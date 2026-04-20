# =============================================================================
# 插件管理配置
# =============================================================================

# 🚀 Zinit 初始化
typeset -ga _zinit_candidates=(
  /opt/homebrew/opt/zinit/zinit.zsh
  /usr/local/opt/zinit/zinit.zsh
  "$HOME/.local/share/zinit/zinit.zsh"
)

for _zinit_path in "${_zinit_candidates[@]}"; do
  if [[ -r "$_zinit_path" ]]; then
    source "$_zinit_path"
    break
  fi
done

if (( ${+functions[zinit]} )); then
  # 🔥 高性能插件配置

  # 1. 快速语法高亮
  zinit load "zdharma-continuum/fast-syntax-highlighting"

  # 2. 智能自动建议
  zinit load "zsh-users/zsh-autosuggestions"

  # 3. 历史子字符串搜索
  zinit load "zsh-users/zsh-history-substring-search"

  # 4. Git 插件
  zinit snippet "OMZ::plugins/git/git.plugin.zsh"

  # 5. 智能补全增强
  zinit load "zsh-users/zsh-completions"

  # 6. Starship 主题 (更现代、更快)
  zinit ice as"command" from"gh-r" \
        atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
        atpull"%atclone" src"init.zsh"
  zinit load starship/starship

  # 快捷键优化 (在插件加载后设置)
  zinit wait lucid atload'
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
    bindkey "^U" backward-kill-line
  ' for zdharma-continuum/null
elif command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
  echo "⚠️  Zinit not found. Loaded only Starship prompt."
else
  echo "⚠️  Zinit not found. Install with: brew install zinit"
fi

unset _zinit_candidates _zinit_path
