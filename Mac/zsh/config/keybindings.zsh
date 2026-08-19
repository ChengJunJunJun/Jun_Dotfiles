# =============================================================================
# 快捷键配置（macOS / zsh）
# =============================================================================

# Emacs 风格键位，与大多数终端默认习惯一致
bindkey -e

# 同一序列绑到多个 keymap，避免被模式切换或插件影响：
# Option+Backspace（^[^?，部分终端发 ^[^H）、Option+←/→、Option 作 Meta
for _kb in '^[^?:backward-kill-word' '^[^H:backward-kill-word' \
           '^[[1;3D:backward-word'   '^[[1;3C:forward-word' \
           '^[b:backward-word'       '^[f:forward-word'; do
  for _km in emacs viins main; do bindkey -M $_km "${_kb%%:*}" "${_kb#*:}"; done
done
unset _kb _km

# showkeys：输出按键实际发给 zsh 的转义序列，便于调试终端快捷键
showkeys() {
  print 'Press keys (Ctrl-C to quit)'
  while IFS= read -rs -k1 key; do printf '%q\n' "$key"; done
}
