# =============================================================================
# fzf：环境变量在此导出（脚本 / 非交互也要用），
# shell 集成排进 zdefer —— 既不阻塞首个提示符，又能在 compinit 之后
# 才注册补全（在此之前 fzf 的 compdef 守卫不通过，补全会被静默跳过）
# =============================================================================

# 先 stat 再回退命令哈希：首次访问 $commands 会扫描整个 PATH，实测 4.7ms
if [[ -x "$HOMEBREW_PREFIX/bin/fd" ]] || (( ${+commands[fd]} )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
else
  export FZF_DEFAULT_COMMAND='find . -type f'
  export FZF_ALT_C_COMMAND='find . -type d'
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 40% --layout=reverse --border --info=inline}"
export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS:---preview 'head -n 200 {} 2>/dev/null || ls -la {}'}"
export FZF_ALT_C_OPTS="${FZF_ALT_C_OPTS:---preview 'ls -la {}'}"
export FZF_CTRL_R_OPTS="${FZF_CTRL_R_OPTS:---preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'}"

[[ -o interactive ]] || return 0

# 静态路径优先：brew --prefix fzf 实测 13.6ms
_fzf_shell="$HOMEBREW_PREFIX/opt/fzf/shell"
if [[ -r "$_fzf_shell/key-bindings.zsh" ]]; then
  zdefer "source '$_fzf_shell/key-bindings.zsh'; source '$_fzf_shell/completion.zsh'"
elif (( ${+commands[fzf]} )); then
  zdefer 'source <(fzf --zsh)'
else
  print -u2 "⚠️  fzf not found. Install with: brew install fzf"
fi
unset _fzf_shell
