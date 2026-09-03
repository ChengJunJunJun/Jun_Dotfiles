#!/usr/bin/env bash
#
# 生成状态栏左侧的会话列表，写入每个会话各自的 @sessions 选项。
#
# 为什么不放在 status-left 的 #() 里:
#   #() 每次状态栏重绘都要 fork 一个子进程。旧实现是每秒 1 个 bash + 2 个 tmux
#   客户端，而会话列表其实只在会话增 / 删 / 改名时才会变。改成由 theme.conf 里
#   的 hook 触发后，平时开销为零。
#
# 为什么写「每个会话各自的」选项而不是一个全局选项:
#   要高亮的是「当前会话」，而它对每个客户端都不一样。tmux 的用户选项支持会话
#   作用域，status-left 里的 #{@sessions} 会按客户端所在的会话去解析，所以两个
#   终端 attach 到不同会话时，各自看到的高亮都是对的。
#   （旧脚本在 #() 里用 `tmux display-message -p '#S'` 猜当前会话，多客户端时会猜错；
#     而且 theme.conf 明明把 session_id / session_name 当参数传了进来，脚本却没读。）

set -u

# 配色从 theme.conf 设的用户选项读取，避免两个文件各硬编码一份。
# show -gv 不需要 target，在 session-closed 这种没有「当前会话」的 hook 里也安全。
thm_bg=$(tmux show -gv @thm_bg 2>/dev/null)
thm_fg=$(tmux show -gv @thm_fg 2>/dev/null)
thm_gray=$(tmux show -gv @thm_gray 2>/dev/null)
thm_magenta=$(tmux show -gv @thm_magenta 2>/dev/null)
: "${thm_bg:=#1e1e2e}"
: "${thm_fg:=#cdd6f4}"
: "${thm_gray:=#313244}"
: "${thm_magenta:=#cba6f7}"

# 按行读: 会话名里可能有空格，旧脚本的 `for s in $sessions` 会把它拆成两个会话。
# 用 session_id 而不是名字做定位: 名字里的 : 会被 tmux 当成 target 语法的一部分。
ids=()
names=()
while IFS=$'\t' read -r id name; do
    [ -n "$id" ] || continue
    ids+=("$id")
    names+=("$name")
done < <(tmux list-sessions -F "#{session_id}"$'\t'"#{session_name}" 2>/dev/null)

[ ${#ids[@]} -gt 0 ] || exit 0

count=${#ids[@]}
for ((i = 0; i < count; i++)); do
    out=""
    for ((j = 0; j < count; j++)); do
        # 状态栏里的 # 必须转义成 ##，否则会被当作 format 的开头
        label=${names[$j]//#/##}
        n=$((j + 1))
        if [ "$i" -eq "$j" ]; then
            out="$out#[fg=$thm_bg,bg=$thm_magenta,bold] $n:$label #[fg=$thm_magenta,bg=$thm_bg,nobold]"
        else
            # 旧脚本这里用的是 fg=$thm_bg (深色) 配 bg=$thm_gray (深灰)，
            # 两个颜色几乎一样，非当前会话基本看不清。改成正常前景色。
            out="$out#[fg=$thm_fg,bg=$thm_gray,nobold] $n:$label #[fg=$thm_gray,bg=$thm_bg]"
        fi
    done
    tmux set-option -t "${ids[$i]}" -q @sessions "$out"
done
