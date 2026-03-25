# ========================
# 统一配置
# ========================
$dotfiles = "$HOME\Jun_Dotfiles\Windows"

# Git config
$gitSource = "$dotfiles\git\.gitconfig"
$gitTarget = "$HOME\.gitconfig"
$gitignoreSource = "$dotfiles\git\.gitignore"
$gitignoreTarget = "$HOME\.gitignore"

# PowerShell profile
$psSource = "$dotfiles\Microsoft.PowerShell_profile.ps1"
$psTarget = $PROFILE

# ========================
# 函数：创建符号链接（自动覆盖）
# ========================
function New-Symlink {
param (
[string]$Source,
[string]$Target
)
# 确保目录存在
$dir = Split-Path $Target
if (!(Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}
# 删除已有文件
if (Test-Path $Target) {
    Remove-Item $Target -Force
}
# 创建符号链接
New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
Write-Host "✔ $Target -> $Source"
}

# ========================
# 执行
# ========================
Write-Host "== 创建符号链接 =="
New-Symlink -Source $gitSource -Target $gitTarget
New-Symlink -Source $gitignoreSource -Target $gitignoreTarget
New-Symlink -Source $psSource -Target $psTarget

# ========================
# 立即生效（关键）
# ========================
Write-Host "`n== 重新加载 PowerShell Profile =="
. $PROFILE
Write-Host "`n全部完成 ✔"
