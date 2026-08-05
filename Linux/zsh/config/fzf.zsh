# =============================================================================
# fzf：加载当前安装来源提供的 shell 集成，不在仓库内 vendoring 上游源码
# =============================================================================

# 默认搜索命令：Ubuntu 的 fd-find 在创建 fd 链接前仍可正常使用。
if (( ${+commands[fd]} )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif (( ${+commands[fdfind]} )); then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
elif (( ${+commands[find]} )); then
  export FZF_DEFAULT_COMMAND='find . -type f'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='find . -type d'
fi

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 40% --layout=reverse --border --info=inline}"
export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS:---preview 'head -n 200 {} 2>/dev/null || ls -la {}'}"
export FZF_ALT_C_OPTS="${FZF_ALT_C_OPTS:---preview 'ls -la {}'}"
export FZF_CTRL_R_OPTS="${FZF_CTRL_R_OPTS:---preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'}"

# 非交互或非 TTY 环境只保留环境变量，避免 ZLE 选项恢复报错。
[[ -o interactive && -t 0 && -t 1 ]] || return 0

_fzf_loaded=0
if (( ${+commands[fzf]} )); then
  _fzf_init="$(fzf --zsh 2>/dev/null)"
  if [[ $? -eq 0 && -n "$_fzf_init" ]]; then
    eval "$_fzf_init"
    _fzf_loaded=1
  else
    # Ubuntu/Debian 的旧版 fzf 将集成脚本放在 examples 目录。
    for _fzf_script in \
      /usr/share/doc/fzf/examples/key-bindings.zsh \
      /usr/share/doc/fzf/examples/completion.zsh; do
      if [[ -r "$_fzf_script" ]]; then
        source "$_fzf_script"
        _fzf_loaded=1
      fi
    done
    unset _fzf_script
  fi
fi

if (( _fzf_loaded == 0 )); then
  echo "⚠️  fzf shell integration not found. Run the Zinit install phase from Linux/zsh/install.sh."
fi

unset _fzf_init _fzf_loaded
