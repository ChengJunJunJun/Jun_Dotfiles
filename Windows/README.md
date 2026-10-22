# Windows 终端配置

PowerShell 7 + Starship + PSFzf + zoxide，配合原生 Neovim。

## 配置位置

此目录只维护配置。工具自行安装，配置可复制或建立符号链接到对应位置：

| 仓库配置 | 使用位置 |
|---|---|
| `Microsoft.PowerShell_profile.ps1` | PowerShell 7 的 `$PROFILE` |
| `git/.gitconfig` | `$HOME/.gitconfig` |
| `git/.gitignore` | 由 `.gitconfig` 的 `core.excludesfile` 引用 |
| `config/starship.toml` | `$HOME/.config/starship.toml` |
| `config/nvim/` | `$env:LOCALAPPDATA/nvim/` |

应用配置后重新打开 PowerShell。

## 应用配置的命令

在 **PowerShell 7** 中运行。创建符号链接需要开启 Windows 开发者模式，或以管理员身份打开 PowerShell。

只想在当前终端立即使用 PowerShell 配置：

```powershell
. 'C:\Users\Administrator\Jun_Dotfiles\Windows\Microsoft.PowerShell_profile.ps1'
```

让 PowerShell、Git、Starship 和 Neovim 使用仓库配置，直接覆盖已有配置，不保留备份：

```powershell
$configRoot = 'C:\Users\Administrator\Jun_Dotfiles\Windows'

New-Item -ItemType Directory -Path (Split-Path $PROFILE), "$HOME\.config" -Force | Out-Null

Remove-Item -LiteralPath $PROFILE, "$HOME\.gitconfig", "$HOME\.config\starship.toml" -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath "$env:LOCALAPPDATA\nvim" -Recurse -Force -ErrorAction SilentlyContinue

New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$configRoot\Microsoft.PowerShell_profile.ps1"
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$configRoot\git\.gitconfig"
New-Item -ItemType SymbolicLink -Path "$HOME\.config\starship.toml" -Target "$configRoot\config\starship.toml"
New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "$configRoot\config\nvim"

# 在当前终端加载；以后新开的 PowerShell 会自动加载。
. $PROFILE
```

Git 的全局忽略规则已由 `.gitconfig` 指向仓库内的 `Windows/git/.gitignore`，无需单独建立链接。Neovim 链接建立后，首次打开 `nvim` 会引导安装插件；在 Neovim 内运行 `:Lazy restore` 可恢复锁定的插件版本。

修改 PowerShell 配置后，在当前终端重新加载：

```powershell
. $PROFILE
# 也可以使用配置提供的快捷命令：
s.
```

## 常用操作

- `Ctrl+R`：模糊搜索命令历史；选择后不会直接执行。
- `Ctrl+T`：查找文件并插入路径。
- `Alt+C`：查找并进入目录。
- `z 关键字` / `zi`：根据访问历史跳目录 / 交互选择。
- `fdf` / `fdd` / `rga`：文件 / 目录 / 全文搜索。
- `gs` / `gl` / `gc` / `gp`：Git status / log / commit / pull，参数会传递给 Git。
- `nvim`：Neovim；空格是 leader；`Space ff` 找文件、`Space fg` 搜内容、`Space e` 文件树、`Space cf` 格式化。

## Windows 适配

PowerShell 仅在交互终端加载 PSReadLine 预测界面、zoxide 和 Starship；PSFzf 在首次按 `Ctrl+R` / `Ctrl+T` / `Alt+C` 时加载，首次按键会直接完成对应操作。重定向和 `-NonInteractive` 启动不加载这些终端组件。
Neovim 使用 Windows state 目录保存撤销记录，Python 虚拟环境路径为 `.venv/Scripts/python.exe`，原生分屏替代 tmux 联动。
Windows Git 使用普通提交，不启用提交签名，无需 1Password 验证。
配置没有修改 Windows Terminal 的字体和全局快捷键。图标显示取决于终端字体。

## 依赖与插件

- 常用工具：Git、Starship、fzf、zoxide、ripgrep、fd、Neovim、lazygit、jq、Zig、7-Zip，以及 PowerShell 模块 PSReadLine、PSFzf。
- 保留 Neovim 的 `lazy-lock.json`；需要按锁定版本恢复时，在 Neovim 中运行 `:Lazy restore`。
- Python 工具使用 `uv`、`ruff` 和 `ty`，自行安装并确保它们在 PATH 中。

已安装上述命令行工具后，可按需安装 PowerShell 模块和 Python 工具：

```powershell
Install-Module PSFzf -Repository PSGallery -Scope CurrentUser
uv tool install ruff
uv tool install ty
```

## 启动优化

Starship 的完整初始化脚本和 zoxide 初始化脚本缓存在 `%LOCALAPPDATA%\Jun-Dotfiles\powershell`。缓存命中时不再运行初始化子进程；提示符渲染、Git 状态查询仍按工具自身逻辑执行。工具路径、符号链接目标、文件时间/大小、初始化参数或 PowerShell 版本变化时自动重建缓存。缓存写入失败时使用本次生成的代码；初始化失败时警告并跳过该组件。

PSFzf 的模块导入开销移到第一次模糊搜索。`Ctrl+R` 仍然只将历史命令插入编辑行，按回车才执行。快捷键使用 [PSReadLine 自定义处理器](https://learn.microsoft.com/en-us/powershell/module/psreadline/set-psreadlinekeyhandler)。
