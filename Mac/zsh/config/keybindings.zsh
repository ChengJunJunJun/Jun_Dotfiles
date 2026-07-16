# =============================================================================
# 快捷键配置（macOS / zsh）
# =============================================================================

# Emacs 风格键位，与大多数终端默认习惯一致
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
# 部分终端 Option+Backspace 发 ^[^H
bind_in_keymaps '^[^H' backward-kill-word

# Option+Left / Right（CSI 1;3D / 1;3C）
bind_in_keymaps '^[[1;3D' backward-word
bind_in_keymaps '^[[1;3C' forward-word

# Option 作 Meta 时常见序列
bind_in_keymaps '^[b' backward-word
bind_in_keymaps '^[f' forward-word

# showkeys：输出按键实际发给 zsh 的转义序列，便于调试终端快捷键
showkeys() {
  printf 'Press keys (Ctrl-C to quit)\n'
  while true; do
    IFS= read -rs -k1 key || break
    printf '%q\n' "$key"
  done
}
