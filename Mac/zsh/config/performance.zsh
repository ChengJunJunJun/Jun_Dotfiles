# =============================================================================
# 基础性能 / 历史 / 行为选项（compinit 由 plugins 触发）
# =============================================================================

# 确保缓存与状态目录存在
mkdir -p "${ZSH_CACHE_DIR}" "${ZSH_STATE_DIR}" 2>/dev/null

# ---------------------------------------------------------------------------
# fpath：Homebrew / 用户补全目录（必须在 compinit 之前）
# ---------------------------------------------------------------------------
typeset -gU fpath

# Apple Silicon / Intel Homebrew site-functions
for _site in \
  /opt/homebrew/share/zsh/site-functions \
  /usr/local/share/zsh/site-functions; do
  [[ -d "$_site" ]] && fpath=("$_site" $fpath)
done
unset _site

# Grok CLI 补全
if [[ -d "$HOME/.grok/completions/zsh" ]]; then
  fpath=("$HOME/.grok/completions/zsh" $fpath)
fi

# ---------------------------------------------------------------------------
# 历史记录（XDG state）
# ---------------------------------------------------------------------------
HISTFILE="${ZSH_STATE_DIR}/history"
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY       # 记录时间戳
setopt SHARE_HISTORY          # 多会话共享历史
setopt HIST_IGNORE_SPACE      # 忽略以空格开头的命令
setopt HIST_IGNORE_DUPS       # 不记录连续重复
setopt HIST_IGNORE_ALL_DUPS   # 删除旧的重复条目
setopt HIST_SAVE_NO_DUPS      # 写入时不保存重复
setopt HIST_EXPIRE_DUPS_FIRST # 淘汰时优先丢重复
setopt HIST_VERIFY            # 历史展开先显示再执行
setopt HIST_REDUCE_BLANKS     # 压缩多余空白
setopt APPEND_HISTORY         # 追加而非覆盖

# 不与 SHARE_HISTORY 叠用 INC_APPEND_HISTORY，避免交错异常

# ---------------------------------------------------------------------------
# 常用交互选项
# ---------------------------------------------------------------------------
setopt AUTO_CD                # 输入目录名即可 cd
setopt INTERACTIVE_COMMENTS   # 交互模式支持 #
setopt EXTENDED_GLOB          # 扩展 glob
setopt PIPE_FAIL              # 管道返回失败命令状态
setopt NO_BEEP                # 关闭蜂鸣
setopt COMPLETE_IN_WORD       # 词中也可补全
setopt ALWAYS_TO_END          # 补全后光标到词尾

# ---------------------------------------------------------------------------
# 光标：竖线（beam）
# ---------------------------------------------------------------------------
_set_cursor() {
  print -n '\e[5 q'
}
precmd_functions=(${precmd_functions:#_set_cursor})
precmd_functions+=(_set_cursor)
