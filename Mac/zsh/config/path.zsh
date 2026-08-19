# =============================================================================
# XDG / Homebrew / PATH —— .zprofile 与 .zshrc 共用，全内建实现，零子进程
# =============================================================================

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# 只保留真实存在的目录并按字面去重。
# 刻意不用 ${entry:A} 解析软链：/opt/homebrew/opt/* 与 /Library/TeX/texbin
# 都是版本无关的稳定入口，解析成带版本号的实路径后，一次 upgrade
# 就会让已开着的 shell（及其 export 给子进程的 PATH）指向被删掉的旧目录。
normalize_path_entries() {
  path=($^path(N-/))
  typeset -gU path PATH
  export PATH
  hash -r 2>/dev/null
}

# 等价于 eval "$(brew shellenv)"，但不 fork（brew shellenv 实测 14ms）。
# 这段刻意不做「已初始化就跳过」：macOS 的 /etc/zprofile 会跑 path_helper
# 把系统目录重排到最前面，必须在它之后再前置一次 Homebrew 才有优先级。
# 前置本身幂等（typeset -U 会把重复项移到最前而非追加），只有 INFOPATH
# 是累加式的，单独判重。
for _pd in /opt/homebrew /usr/local; do
  [[ -x "$_pd/bin/brew" ]] || continue
  export HOMEBREW_PREFIX="$_pd" HOMEBREW_CELLAR="$_pd/Cellar" HOMEBREW_REPOSITORY="$_pd"
  [[ ":${INFOPATH:-}:" == *":$_pd/share/info:"* ]] ||
    export INFOPATH="$_pd/share/info${INFOPATH:+:$INFOPATH}"
  path=("$_pd/bin" "$_pd/sbin" $path)
  break
done

# 按优先级前置自定义路径（目录存在才加入）
for _pd in "$HOME/.grok/bin" "$HOME/.local/bin" \
           "$HOMEBREW_PREFIX/opt/rustup/bin" /Library/TeX/texbin; do
  [[ -d "$_pd" ]] && path=("$_pd" $path)
done

# Node：优先无版本 keg，再回退常见 major 版本。
# 注意：追加而非前置。node@22 等版本化 keg 自带 npm（如 10.9.8），
# 前置会遮蔽 $HOMEBREW_PREFIX/bin 下全局安装的 npm（npm i -g npm@latest）。
for _pd in "$HOMEBREW_PREFIX/opt/node" "$HOMEBREW_PREFIX/opt/node@22" \
           "$HOMEBREW_PREFIX/opt/node@20"; do
  [[ -d "$_pd/bin" ]] && { path+=("$_pd/bin"); break }
done
unset _pd

normalize_path_entries
