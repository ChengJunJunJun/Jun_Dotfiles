# Windows 终端配置

PowerShell 7 + Starship + PSFzf + zoxide，配合原生 Neovim 和 Yazi。

## 安装与恢复

在 PowerShell 7 中运行 `./install-tools.ps1`，然后重新打开 Windows Terminal。
只重建配置链接时运行 `./symlink.ps1`；可用 `-WhatIf` 预览。
链接脚本保留已有目标为 `.backup-时间戳-随机后缀`，正确链接不会重复替换。

## 常用操作

- `Ctrl+R`：模糊搜索命令历史；选择后不会直接执行。
- `Ctrl+T`：查找文件并插入路径。
- `Alt+C`：查找并进入目录。
- `z 关键字` / `zi`：根据访问历史跳目录 / 交互选择。
- `fdf` / `fdd` / `rga`：文件 / 目录 / 全文搜索。
- `gs` / `gl` / `gc` / `gp`：Git status / log / commit / pull，参数会传递给 Git。
- `nvim`：Neovim；空格是 leader；`Space ff` 找文件、`Space fg` 搜内容、`Space e` 文件树、`Space cf` 格式化。
- `y`：启动 Yazi，退出后 PowerShell 跟随到选中的目录。
- Yazi 内 `s` / `S` 搜索文件名 / 内容，`z` / `Z` 使用 fzf / zoxide，`O` 选择打开方式。

## Windows 适配

PowerShell 仅在交互终端加载 PSReadLine 预测界面、PSFzf、zoxide 和 Starship，避免 SSH 自动化报错。
Neovim 使用 Windows state 目录保存撤销记录，Python 虚拟环境路径为 `.venv/Scripts/python.exe`，原生分屏替代 tmux 联动。
Yazi 使用 Explorer / Windows 默认应用打开文件，支持 D 盘项目，不加载 Mac 的用户目录边界插件。
Windows Git 使用普通提交，不启用提交签名，无需 1Password 验证。
配置没有修改 Windows Terminal 的字体和全局快捷键。图标显示取决于终端字体。

## 版本控制与依赖恢复

- 提交 PowerShell、Starship、Neovim、Yazi 配置和安装脚本。
- 保留 Neovim 的 `lazy-lock.json`；需要按锁定版本恢复时，在 Neovim 中运行 `:Lazy restore`。
- Yazi 主题目录由 Git 忽略；`package.toml` 保留版本信息。安装脚本建立链接后运行 `ya pkg install` 恢复依赖，也可在链接建立后手动运行此命令。参见 [Yazi 包管理文档](https://yazi-rs.github.io/docs/cli/)。
- `.backup-*` 文件保留在本机，不纳入版本控制。
- Python 工具需要 `uv`：如果本机已安装，脚本会安装缺失的 `ruff` 和 `ty`；否则需自行安装并确保它们在 PATH 中。

## SSH 中运行 Codex

PowerShell Profile 中的 `codex` 函数在检测到 `SSH_CONNECTION` 或 `SSH_CLIENT` 时添加 `default_permissions=":danger-full-access"`，避免 Windows 沙箱在 SSH 会话下启动超时。本机启动仍采用 config.toml 中的工作区沙箱，审批策略保持不变。

首次应用后执行 `. $PROFILE`，然后退出旧 Codex 会话并重新运行 `codex`。直接调用 `codex.cmd`、`codex.exe` 或通过不加载 Profile 的进程启动不会经过此包装函数。
