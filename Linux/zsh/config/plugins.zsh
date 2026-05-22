# =============================================================================
# 插件管理配置
# =============================================================================

# Zinit 初始化
_zinit_path="$HOME/.local/share/zinit/zinit.git/zinit.zsh"

if [[ -r "$_zinit_path" ]]; then
  source "$_zinit_path"
fi

if (( ${+functions[zinit]} )); then
  # 高性能插件配置
  zinit light "zdharma-continuum/fast-syntax-highlighting"
  zinit light "zsh-users/zsh-autosuggestions"
  zinit light "zsh-users/zsh-history-substring-search"
  zinit snippet "OMZ::plugins/git/git.plugin.zsh"
  zinit light "zsh-users/zsh-completions"

  # 命令行工具由 zinit binary snippets 管理
  zinit ice as"program" from"gh-r"
  zinit light "junegunn/fzf"

  zinit ice as"program" from"gh-r" pick"zoxide"
  zinit light "ajeetdsouza/zoxide"

  zinit ice as"program" from"gh-r" mv"fd* -> fd" pick"fd/fd"
  zinit light "@sharkdp/fd"

  zinit ice as"program" from"gh-r" mv"ripgrep* -> ripgrep" pick"ripgrep/rg"
  zinit light "BurntSushi/ripgrep"

  # Starship 主题
  if [[ -o interactive && "${TERM:-}" != "dumb" ]]; then
    zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
    zinit light "starship/starship"
  fi

  # 快捷键优化 (在插件加载后设置)
  zinit wait lucid atload'
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
    bindkey "^U" backward-kill-line
  ' for zdharma-continuum/null
elif [[ -o interactive && "${TERM:-}" != "dumb" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
  echo "Zinit not found. Loaded only Starship prompt."
else
  echo "Zinit not found. Run: bash ~/Jun_Dotfiles/Linux/zsh/install.sh"
fi

unset _zinit_path
