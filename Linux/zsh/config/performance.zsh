# =============================================================================
# 基础性能 / 历史 / 行为选项（compinit 由 plugins 触发）
# =============================================================================

# 确保缓存与状态目录存在
mkdir -p "${ZSH_CACHE_DIR}" "${ZSH_STATE_DIR}" 2>/dev/null

# 补全目录必须在 compinit 之前进入 fpath
typeset -gU fpath
for _site in \
  "$HOME/.local/share/zsh/site-functions" \
  /usr/local/share/zsh/site-functions \
  /usr/share/zsh/vendor-completions; do
  [[ -d "$_site" ]] && fpath=("$_site" $fpath)
done
unset _site

if [[ -d "$HOME/.grok/completions/zsh" ]]; then
  fpath=("$HOME/.grok/completions/zsh" $fpath)
fi

# 历史记录（XDG state）
HISTFILE="${ZSH_STATE_DIR}/history"
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_VERIFY
setopt HIST_REDUCE_BLANKS
setopt APPEND_HISTORY

# 不与 SHARE_HISTORY 叠用 INC_APPEND_HISTORY，避免多会话记录交错

# 常用交互选项
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt EXTENDED_GLOB
setopt PIPE_FAIL
setopt NO_BEEP
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# 光标：竖线（beam）
_set_cursor() {
  print -n '\e[5 q'
}
precmd_functions=(${precmd_functions:#_set_cursor})
precmd_functions+=(_set_cursor)
