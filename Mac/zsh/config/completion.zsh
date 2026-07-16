# =============================================================================
# 补全系统配置（zstyle + compinit 辅助函数）
# compinit 由 plugins.zsh 通过 zinit turbo 或 fallback 调用
# =============================================================================

# 性能优化的补全设置
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZSH_CACHE_DIR}"
zstyle ':completion:*' rehash true

# 补全行为
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*' group-name ''
zstyle ':completion:*' special-dirs false

# 目录补全
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*' squeeze-slashes true

# 历史词补全
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# 补全菜单样式
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format '%F{red}No matches for: %d%f'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'

# ---------------------------------------------------------------------------
# 安全的 compinit：文件缺失或超过 24h 时全量重建，否则 -C 跳过检查
# ---------------------------------------------------------------------------
_zsh_run_compinit() {
  autoload -Uz compinit
  mkdir -p "${ZSH_CACHE_DIR}" 2>/dev/null

  if [[ ! -f "${ZSH_COMPDUMP}" || -n "${ZSH_COMPDUMP}"(#qN.mh+24) ]]; then
    compinit -d "${ZSH_COMPDUMP}"
  else
    compinit -C -d "${ZSH_COMPDUMP}"
  fi
}
