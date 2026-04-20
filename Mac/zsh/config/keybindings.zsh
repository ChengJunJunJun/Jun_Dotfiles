# =============================================================================
# 快捷键配置（macOS / zsh）
# =============================================================================

# 使用 Emacs 风格键位，和大多数终端默认习惯保持一致
bindkey -e

# 将同一快捷键绑定到多个常用 keymap，避免被模式切换或插件影响
bind_in_keymaps() {
  local sequence="$1"
  local widget="$2"

  bindkey -M emacs "$sequence" "$widget"
  bindkey -M viins "$sequence" "$widget"
  bindkey -M main "$sequence" "$widget"
}

# Option+Backspace 删除前一个单词
bind_in_keymaps '^[^?' backward-kill-word

# Option+Left 按单词向左移动（兼容 CSI 1;3D 序列）
bind_in_keymaps '^[[1;3D' backward-word

# Option+Right 按单词向右移动（兼容 CSI 1;3C 序列）
bind_in_keymaps '^[[1;3C' forward-word


# showkeys：输出按键实际发给 zsh 的转义序列，便于调试终端快捷键
showkeys() {
  printf 'Press keys (Ctrl-C to quit)\n'
  while true; do
    IFS= read -rs -k1 key || break
    printf '%q\n' "$key"
  done
}
