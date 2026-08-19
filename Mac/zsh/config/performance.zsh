# =============================================================================
# Shell 核心：fpath / 历史 / setopt / 补全样式
# compinit 本身由 plugins.zsh 的延迟执行器在首个提示符后调用
# =============================================================================

# 目录通常已存在；先判断可省掉每次启动一次 fork（mkdir -p 实测 4.1ms）
[[ -d "$ZSH_CACHE_DIR" && -d "$ZSH_STATE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR" "$ZSH_STATE_DIR" 2>/dev/null

# fpath：Homebrew 与用户补全目录（必须在 compinit 之前）
typeset -gU fpath
for _fd in "$HOMEBREW_PREFIX/share/zsh/site-functions" \
           "$HOMEBREW_PREFIX/share/zsh-completions" \
           "$HOME/.grok/completions/zsh"; do
  [[ -d "$_fd" ]] && fpath=("$_fd" $fpath)
done
unset _fd

# ---------------------------------------------------------------------------
# 历史记录（XDG state）
# 不与 SHARE_HISTORY 叠用 INC_APPEND_HISTORY，避免交错异常
# ---------------------------------------------------------------------------
HISTFILE="${ZSH_STATE_DIR}/history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_SPACE HIST_IGNORE_DUPS \
       HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_EXPIRE_DUPS_FIRST \
       HIST_VERIFY HIST_REDUCE_BLANKS APPEND_HISTORY

# AUTO_CD 目录名即 cd／# 注释／扩展 glob／管道返回失败状态／静音／词中补全／补全后到词尾
setopt AUTO_CD INTERACTIVE_COMMENTS EXTENDED_GLOB PIPE_FAIL NO_BEEP \
       COMPLETE_IN_WORD ALWAYS_TO_END

# 光标：竖线（beam）
_set_cursor() { print -n '\e[5 q' }
precmd_functions=(${precmd_functions:#_set_cursor} _set_cursor)

# ---------------------------------------------------------------------------
# 补全样式
# ---------------------------------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' rehash true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' special-dirs false
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' verbose yes
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format '%F{red}No matches for: %d%f'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'

# 安全的 compinit：文件缺失或超过 24h 时全量重建，否则 -C 跳过检查。
# 末尾编译成 .zwc：实测 compinit -C 由 12.8ms 降到 5.8ms。
_zsh_run_compinit() {
  autoload -Uz compinit
  if [[ ! -f "$ZSH_COMPDUMP" || -n "$ZSH_COMPDUMP"(#qN.mh+24) ]]; then
    compinit -d "$ZSH_COMPDUMP"
  else
    compinit -C -d "$ZSH_COMPDUMP"
  fi
  [[ "$ZSH_COMPDUMP.zwc" -nt "$ZSH_COMPDUMP" ]] || zcompile -R "$ZSH_COMPDUMP" 2>/dev/null
}
