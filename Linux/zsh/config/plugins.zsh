# =============================================================================
# 插件管理（Zinit release 工具 + turbo 延迟加载）
# =============================================================================

typeset -ga _zinit_candidates=(
  "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
  "$HOME/.local/share/zinit/zinit.zsh"
)

for _zinit_path in "${_zinit_candidates[@]}"; do
  if [[ -r "$_zinit_path" ]]; then
    source "$_zinit_path"
    break
  fi
done
unset _zinit_candidates _zinit_path

if (( ${+functions[zinit]} )); then
  # apt 管理 fd/rg；Zinit 仅管理 apt 缺失或版本偏旧的 release 工具。
  zinit ice as"program" from"gh-r"
  zinit light "junegunn/fzf"

  zinit ice as"program" from"gh-r" pick"zoxide"
  zinit light "ajeetdsouza/zoxide"

  # Starship 由 Zinit 下载，并缓存初始化脚本与补全。
  if [[ -o interactive && "${TERM:-}" != "dumb" ]]; then
    zinit ice as"command" from"gh-r" \
      atclone'./starship init zsh > init.zsh; ./starship completions zsh > _starship' \
      atpull'%atclone' src"init.zsh"
    zinit light "starship/starship"
  fi

  typeset -gA ZINIT
  ZINIT[ZCOMPDUMP_PATH]="${ZSH_COMPDUMP}"

  # 自动建议和补全先就绪，语法高亮最后触发 compinit / zicdreplay。
  zinit wait lucid light-mode for \
    atload'_zsh_autosuggest_start' \
      zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions \
    atinit'_zsh_run_compinit; zicdreplay' \
      zdharma-continuum/fast-syntax-highlighting

  zinit wait lucid light-mode for \
    zsh-users/zsh-history-substring-search \
    OMZP::git

  zinit wait lucid atload'
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
    bindkey "^[OA" history-substring-search-up
    bindkey "^[OB" history-substring-search-down
    bindkey "^U" backward-kill-line
  ' for zdharma-continuum/null

  # turbo 在首次 prompt 触发；若钩子异常则由一次性 precmd 初始化补全。
  typeset -g _ZSH_COMPINIT_DEFERRED=1
  _zsh_compinit_fallback() {
    if [[ -n "${_ZSH_COMPINIT_DEFERRED:-}" ]]; then
      (( ${+functions[_zsh_run_compinit]} )) && _zsh_run_compinit
    fi
    precmd_functions=(${precmd_functions:#_zsh_compinit_fallback})
    unset _ZSH_COMPINIT_DEFERRED
    unfunction _zsh_compinit_fallback 2>/dev/null
  }
  precmd_functions=(${precmd_functions:#_zsh_compinit_fallback})
  precmd_functions=(_zsh_compinit_fallback ${precmd_functions[@]})
else
  echo "⚠️  Zinit not found. Run: bash ~/Jun_Dotfiles/Linux/zsh/install.sh"

  if [[ -o interactive && "${TERM:-}" != "dumb" ]] && (( ${+commands[starship]} )); then
    eval "$(starship init zsh)"
  fi

  (( ${+functions[_zsh_run_compinit]} )) && _zsh_run_compinit
fi
