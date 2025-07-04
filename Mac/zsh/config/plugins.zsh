# =============================================================================
# 插件管理配置
# =============================================================================

# 🚀 Zinit 初始化
source /opt/homebrew/opt/zinit/zinit.zsh

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