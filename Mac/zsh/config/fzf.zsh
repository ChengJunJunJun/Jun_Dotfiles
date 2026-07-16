# =============================================================================
# fzf：使用 Homebrew 自带脚本，避免 vendoring 上游源码
# =============================================================================

# ---------------------------------------------------------------------------
# 默认命令：优先 fd（始终导出，供脚本/非 TTY 使用）
# ---------------------------------------------------------------------------
if (( ${+commands[fd]} )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif (( ${+commands[find]} )); then
  export FZF_DEFAULT_COMMAND='find . -type f'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='find . -type d'
fi

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 40% --layout=reverse --border --info=inline}"
export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS:---preview 'head -n 200 {} 2>/dev/null || ls -la {}'}"
export FZF_ALT_C_OPTS="${FZF_ALT_C_OPTS:---preview 'ls -la {}'}"
export FZF_CTRL_R_OPTS="${FZF_CTRL_R_OPTS:---preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'}"

# 非交互环境只保留环境变量
[[ -o interactive ]] || return 0

# ---------------------------------------------------------------------------
# Source Homebrew fzf shell 集成
# ---------------------------------------------------------------------------
_fzf_prefix=""
if (( ${+commands[brew]} )); then
  _fzf_prefix="$(brew --prefix fzf 2>/dev/null)"
fi
[[ -z "$_fzf_prefix" && -d /opt/homebrew/opt/fzf ]] && _fzf_prefix=/opt/homebrew/opt/fzf
[[ -z "$_fzf_prefix" && -d /usr/local/opt/fzf ]] && _fzf_prefix=/usr/local/opt/fzf

if [[ -n "$_fzf_prefix" ]]; then
  [[ -r "${_fzf_prefix}/shell/key-bindings.zsh" ]] && source "${_fzf_prefix}/shell/key-bindings.zsh"
  [[ -r "${_fzf_prefix}/shell/completion.zsh" ]] && source "${_fzf_prefix}/shell/completion.zsh"
elif (( ${+commands[fzf]} )); then
  source <(fzf --zsh) 2>/dev/null
else
  echo "⚠️  fzf not found. Install with: brew install fzf"
fi

unset _fzf_prefix
