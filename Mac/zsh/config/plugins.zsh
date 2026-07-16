# =============================================================================
# 插件管理（Zinit turbo + Starship）
# =============================================================================

typeset -ga _zinit_candidates=(
  /opt/homebrew/opt/zinit/zinit.zsh
  /usr/local/opt/zinit/zinit.zsh
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

# ---------------------------------------------------------------------------
# Starship：优先 Homebrew，避免与 zinit gh-r 双轨
# ---------------------------------------------------------------------------
if (( ${+commands[starship]} )); then
  eval "$(starship init zsh)"
elif [[ -x /opt/homebrew/bin/starship ]]; then
  eval "$(/opt/homebrew/bin/starship init zsh)"
elif [[ -x /usr/local/bin/starship ]]; then
  eval "$(/usr/local/bin/starship init zsh)"
else
  echo "⚠️  Starship not found. Install with: brew install starship"
fi

# ---------------------------------------------------------------------------
# Zinit 插件（turbo 延迟加载）
# - autosuggestions / completions 先加载
# - fsh 最后；其 atinit 触发 compinit + zicdreplay
# ---------------------------------------------------------------------------
if (( ${+functions[zinit]} )); then
  typeset -gA ZINIT
  ZINIT[ZCOMPDUMP_PATH]="${ZSH_COMPDUMP}"

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

  # 插件就绪后绑定历史子串搜索与 ^U
  zinit wait lucid atload'
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
    bindkey "^[OA" history-substring-search-up
    bindkey "^[OB" history-substring-search-down
    bindkey "^U" backward-kill-line
  ' for zdharma-continuum/null

  # turbo 在首次 prompt 触发；若异常未跑 compinit，用一次性 precmd 兜底
  typeset -g _ZSH_COMPINIT_DEFERRED=1
  _zsh_compinit_fallback() {
    if [[ -n ${_ZSH_COMPINIT_DEFERRED:-} ]] && ! (( ${+_comps[brew]} || ${+_comps[git]} )); then
      (( ${+functions[_zsh_run_compinit]} )) && _zsh_run_compinit
    fi
    precmd_functions=(${precmd_functions:#_zsh_compinit_fallback})
    unset _ZSH_COMPINIT_DEFERRED
    unfunction _zsh_compinit_fallback 2>/dev/null
  }
  precmd_functions=(_zsh_compinit_fallback ${precmd_functions[@]})
else
  echo "⚠️  Zinit not found. Install with: brew install zinit"
  if (( ${+functions[_zsh_run_compinit]} )); then
    _zsh_run_compinit
  fi
fi
