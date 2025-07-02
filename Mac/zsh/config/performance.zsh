# =============================================================================
# 性能优化和监控配置
# =============================================================================

# 🔧 启动性能优化
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# 设置历史记录
HISTSIZE=10000
SAVEHIST=10000       
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt HIST_REDUCE_BLANKS

# 🖱️ 光标设置
_set_cursor() {
  echo -ne '\e[5 q'
}
_set_cursor

# 去重 PATH
typeset -U path 