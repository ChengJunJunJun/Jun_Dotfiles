# =============================================================================
# 补全系统配置（zstyle + compinit 辅助函数）
# compinit 由 plugins.zsh 通过 Zinit turbo 或 fallback 调用
# =============================================================================

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZSH_CACHE_DIR}"
zstyle ':completion:*' rehash true

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*' group-name ''
zstyle ':completion:*' special-dirs false

zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*' squeeze-slashes true

zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format '%F{red}No matches for: %d%f'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'

# 文件缺失或超过 24 小时时全量重建，否则使用 -C 快速路径
typeset -g _ZSH_COMPINIT_DONE=0

_zsh_run_compinit() {
  (( _ZSH_COMPINIT_DONE == 0 )) || return 0

  autoload -Uz compinit
  mkdir -p "${ZSH_CACHE_DIR}" 2>/dev/null

  if [[ ! -f "${ZSH_COMPDUMP}" || -n "${ZSH_COMPDUMP}"(#qN.mh+24) ]]; then
    compinit -d "${ZSH_COMPDUMP}"
  else
    compinit -C -d "${ZSH_COMPDUMP}"
  fi

  typeset -g _ZSH_COMPINIT_DONE=1
}
