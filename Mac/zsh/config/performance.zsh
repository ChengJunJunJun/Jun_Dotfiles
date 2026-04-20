# =============================================================================
# 性能优化和监控配置
# =============================================================================

# 🔧 启动性能优化 - 自动补全系统
autoload -Uz compinit

# 确保缓存目录存在，补全缓存和其他运行态缓存统一放这里
mkdir -p "${ZSH_CACHE_DIR}" 2>/dev/null

# 每24小时重建一次补全缓存，其他时候跳过检查以提升启动速度
if [[ -n "${ZSH_COMPDUMP}"(#qNmh+24) ]]; then
  compinit -d "${ZSH_COMPDUMP}"
else
  compinit -C -d "${ZSH_COMPDUMP}"
fi

# 📜 历史记录配置
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS      # 不记录重复命令
setopt HIST_IGNORE_SPACE     # 忽略以空格开头的命令
setopt HIST_VERIFY           # 历史扩展时先显示，不直接执行
setopt SHARE_HISTORY         # 多个会话共享历史
setopt HIST_REDUCE_BLANKS    # 删除多余空格
setopt APPEND_HISTORY        # 追加而非覆盖历史文件
setopt INC_APPEND_HISTORY    # 即时追加历史记录

# 🖱️ 光标设置（竖线光标）
_set_cursor() {
  echo -ne '\e[5 q'
}
precmd_functions=(${precmd_functions:#_set_cursor})
precmd_functions+=(_set_cursor)
