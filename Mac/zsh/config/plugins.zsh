# =============================================================================
# 提示符 + 插件
# 用 zsh 原生的 zle -F 取代 zinit turbo：回调只在首个提示符已画出、
# ZLE 进入空闲时触发，效果等价，但省掉 zinit 自身 23.5ms 的 source 开销。
# 插件由 Homebrew 提供，更新随 up() 里的 brew upgrade 一起走。
# =============================================================================

# Starship：缓存 init 输出并编译成 .zwc
# （starship init zsh 子进程 5.4ms；source 未编译的输出 13.7ms → 编译后 10.3ms）
_sb="$HOMEBREW_PREFIX/bin/starship"
[[ -x "$_sb" ]] || _sb="${commands[starship]}"
if [[ -n "$_sb" ]]; then
  _sc="$ZSH_CACHE_DIR/starship.zsh"
  if [[ ! -s "$_sc" || "$_sb" -nt "$_sc" ]]; then
    "$_sb" init zsh >| "$_sc"
    zcompile -R "$_sc" 2>/dev/null
  fi
  source "$_sc"
else
  print -u2 "⚠️  Starship not found. Install with: brew install starship"
fi
unset _sb _sc

[[ -o interactive ]] || return 0

# ---------------------------------------------------------------------------
# 首个提示符画出后统一加载重量级组件
# ---------------------------------------------------------------------------
_zsh_defer_run() {
  local fd=$1 f
  zle -F $fd
  exec {fd}<&-

  # 必须最先：之后 zdefer 队列与插件里的 compdef 才真正生效
  _zsh_run_compinit

  for f in "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
           "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"; do
    [[ -r "$f" ]] && source "$f"
  done

  for f in "${_zsh_defer_cmds[@]}"; do eval "$f"; done   # fzf / zoxide
  unset _zsh_defer_cmds
  unfunction zdefer

  # fast-syntax-highlighting 必须最后：它会包装此前注册的所有 ZLE widget
  f="$HOMEBREW_PREFIX/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  [[ -r "$f" ]] && source "$f"

  (( ${+functions[_zsh_autosuggest_start]} )) && _zsh_autosuggest_start
  if (( ${+widgets[history-substring-search-up]} )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^[OA' history-substring-search-up
    bindkey '^[OB' history-substring-search-down
  fi
  bindkey '^U' backward-kill-line

  unfunction _zsh_defer_run
  zle -R
}

# /dev/null 立即可读，zle -F 会在首个提示符画出、ZLE 空闲时回调；
# 比 <(:) 少一次 fork
exec {_zsh_defer_fd}< /dev/null
zle -F $_zsh_defer_fd _zsh_defer_run
