# ========================
# 基础设置
# ========================

# UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ========================
# alias（像 Linux）
# ========================

Set-Alias ll ls
Set-Alias la ls
Set-Alias vim nvim
Set-Alias cat Get-Content

# ========================
# 常用函数
# ========================

function gs { git status }
function gl { git log --oneline --graph }
function gp { git pull }
function gc { git commit }
function gco { git checkout }

# ========================
# 快速跳目录
# ========================

function proj {
    cd D:\Projects
}

# ========================
# 自动补全增强
# ========================

Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# 上下键历史搜索
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward