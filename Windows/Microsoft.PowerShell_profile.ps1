# Shared commands work in interactive terminals, SSH and scripted shells.
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:STARSHIP_CONFIG = Join-Path $HOME '.config/starship.toml'
$gitCommand = Get-Command git -ErrorAction SilentlyContinue
if ($gitCommand) {
    $gitFile = Join-Path (Split-Path (Split-Path $gitCommand.Source)) 'usr/bin/file.exe'
    if (Test-Path $gitFile) { $env:YAZI_FILE_ONE = $gitFile }
}
$sevenZip = Join-Path $env:ProgramFiles '7-Zip'
if ((Test-Path "$sevenZip/7z.exe") -and $sevenZip -notin ($env:PATH -split ';')) {
    $env:PATH += ";$sevenZip"
}

function global:ll { Get-ChildItem -Force @args }
function global:la { Get-ChildItem -Force @args }
function global:vim { & nvim @args }
function global:vi { & nvim @args }
function global:gs { & git status @args }
function global:gl { & git log --oneline --graph @args }
# Remove built-in aliases before using these names as Git functions.
Remove-Item Alias:gc,Alias:gp -Force -ErrorAction SilentlyContinue
function global:gc { & git commit @args }
function global:gp { & git pull @args }
function global:gco { & git checkout @args }
function global:lg { & lazygit @args }
function global:proj { Set-Location 'D:\Projects' }
function global:fdf { & fd --type f --hidden --exclude .git @args }
function global:fdd { & fd --type d --hidden --exclude .git @args }
function global:rga { & rg --smart-case --hidden --glob '!.git' --line-number @args }
function global:y {
    $cwdFile = [IO.Path]::GetTempFileName()
    try {
        & yazi @args --cwd-file $cwdFile
        $target = Get-Content -LiteralPath $cwdFile -Raw
        if ($target -and (Test-Path -LiteralPath $target.Trim() -PathType Container)) {
            Set-Location -LiteralPath $target.Trim()
        }
    } finally { Remove-Item -LiteralPath $cwdFile -Force -ErrorAction SilentlyContinue }
}
$env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
$env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
$env:FZF_ALT_C_COMMAND = 'fd --type d --hidden --exclude .git'
$env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --info=inline'

# Familiar Mac command names, implemented with Windows commands.
function global:s. {
    # Functions in this profile use global scope so updates survive this call.
    . $PROFILE
}
function global:l { Get-ChildItem @args }
function global:.. { Set-Location .. }
function global:... { Set-Location ../.. }
function global:echopath {
    $i = 0
    $env:PATH -split ';' | ForEach-Object { '{0,3}  {1}' -f (++$i), $_ }
}
function global:ssh4090 { & ssh 4090 @args }
function global:ssh3090 { & ssh 3090 @args }
function global:refresh { Clear-DnsClientCache }
function global:rust_up { & rustup update stable @args }
function global:up { & winget upgrade --all @args }
function global:update-ai {
    & npm update -g '@anthropic-ai/claude-code' '@openai/codex'
    if ($LASTEXITCODE -ne 0) { return }
    if (Get-Command grok -ErrorAction SilentlyContinue) { & grok update }
}

# Never initialize terminal UI for redirected SSH commands or automation.
$interactiveTerminal = $Host.Name -eq 'ConsoleHost' -and
    -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected
if (-not $interactiveTerminal) { return }

Import-Module PSReadLine -ErrorAction Stop
if ($Host.UI.SupportsVirtualTerminal) {
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
} else {
    Set-PSReadLineOption -PredictionSource None
}
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& zoxide init powershell | Out-String)
}
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Alt+c -ScriptBlock { Invoke-FuzzySetLocation }
}
if ($env:TERM -ne 'dumb' -and (Get-Command starship -ErrorAction SilentlyContinue)) {
    Invoke-Expression (& starship init powershell | Out-String)
}
