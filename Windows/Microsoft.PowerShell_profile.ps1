# Shared commands work in interactive terminals, SSH and scripted shells.
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:STARSHIP_CONFIG = Join-Path $HOME '.config/starship.toml'
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
    & npm update -g '@anthropic-ai/claude-code'
    if ($LASTEXITCODE -ne 0) { return }
    if (Get-Command grok -ErrorAction SilentlyContinue) { & grok update }
}

# Never initialize terminal UI for redirected SSH commands or automation.
$interactiveTerminal = $Host.Name -eq 'ConsoleHost' -and
    -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected -and
    -not ([Environment]::GetCommandLineArgs() -match '^-noni')
if (-not $interactiveTerminal) { return }

Import-Module PSReadLine -ErrorAction Stop
if ($Host.UI.SupportsVirtualTerminal) {
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
} else {
    Set-PSReadLineOption -PredictionSource None
}
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Cache generated init code, not prompt output. Binary/path/arguments/PowerShell
# changes invalidate it automatically. A warm launch starts no init subprocesses.
function global:Get-DotfilesShellInit {
    param([string]$Name, [string[]]$Arguments)
    $command = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if (!$command) { return }
    $process = $null
    try {
        $binary = Get-Item -LiteralPath $command.Source -ErrorAction Stop
        # Resolve WinGet links so upgrades invalidate even if the link timestamp stays unchanged.
        if ($binary.LinkType -eq 'SymbolicLink') { $binary = $binary.ResolveLinkTarget($true) }
        if (!$binary -or !$binary.Exists) { throw "Executable target is missing: $($command.Source)" }
        $signature = '{0}|{1}|{2}|{3}|{4}' -f $command.Source, $binary.FullName,
            $binary.LastWriteTimeUtc.Ticks, $binary.Length, ($PSVersionTable.PSVersion.ToString() + '|' + ($Arguments -join '|'))
        $hash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($signature)))
        $header = "# dotfiles-init-v1 $hash"
        $cacheDir = Join-Path $env:LOCALAPPDATA 'Jun-Dotfiles/powershell'
        $cacheFile = Join-Path $cacheDir "$Name.ps1"
        if ([IO.File]::Exists($cacheFile)) {
            $cached = [IO.File]::ReadAllText($cacheFile)
            if ($cached.StartsWith($header + "`n")) { return $cached }
        }
        $info = [Diagnostics.ProcessStartInfo]::new($command.Source)
        $info.UseShellExecute = $false
        $info.CreateNoWindow = $true
        $info.RedirectStandardOutput = $true
        $info.RedirectStandardError = $true
        $info.StandardOutputEncoding = [Text.Encoding]::UTF8
        foreach ($argument in $Arguments) { $info.ArgumentList.Add($argument) }
        $process = [Diagnostics.Process]::new()
        $process.StartInfo = $info
        $null = $process.Start()
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        if (!$process.WaitForExit(3000)) {
            $process.Kill($true)
            throw 'Initialization timed out after 3 seconds.'
        }
        $code = $stdout.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($code)) {
            throw "Init failed ($($process.ExitCode)): $($stderr.GetAwaiter().GetResult())"
        }
        # Never replace a working cache with partial output. Concurrent shells use separate temp files.
        $cached = $header + "`n" + $code
        $temporary = $null
        try {
            $null = [IO.Directory]::CreateDirectory($cacheDir)
            $temporary = Join-Path $cacheDir "$Name-$([guid]::NewGuid().ToString('N')).tmp"
            [IO.File]::WriteAllText($temporary, $cached, [Text.UTF8Encoding]::new($false))
            [IO.File]::Move($temporary, $cacheFile, $true)
        } catch {
            Write-Verbose "Cannot persist $Name init cache: $_"
        } finally {
            if ($temporary -and [IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) }
        }
        return $cached
    } catch {
        Write-Warning "$Name initialization skipped: $_"
    } finally {
        if ($process) { $process.Dispose() }
    }
}

# Import PSFzf only on the first fuzzy-search key. Dispatch that same key once,
# so the first Ctrl+R still searches instead of merely loading the module.
function global:Enable-DotfilesFzf {
    try {
        if (!(Get-Command fzf -CommandType Application -ErrorAction SilentlyContinue)) {
            throw 'fzf is missing from PATH.'
        }
        if (!(Get-Module PSFzf)) { Import-Module PSFzf -Global -ErrorAction Stop }
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
        Set-PSReadLineKeyHandler -Key Alt+c -ScriptBlock { Invoke-FuzzySetLocation }
        return $true
    } catch {
        Write-Warning "Fuzzy search unavailable: $_ Check that fzf and PSFzf are installed and available."
        return $false
    }
}
Set-PSReadLineKeyHandler -Key Ctrl+t -BriefDescription 'LoadFzfFiles' -ScriptBlock {
    if (Enable-DotfilesFzf) { Invoke-FzfPsReadlineHandlerProvider }
}
Set-PSReadLineKeyHandler -Key Ctrl+r -BriefDescription 'LoadFzfHistory' -ScriptBlock {
    if (Enable-DotfilesFzf) { Invoke-FzfPsReadlineHandlerHistory }
}
Set-PSReadLineKeyHandler -Key Alt+c -BriefDescription 'LoadFzfDirectory' -ScriptBlock {
    if (Enable-DotfilesFzf) { Invoke-FuzzySetLocation }
}

if ($env:TERM -ne 'dumb') {
    # Cache the full script: plain `init powershell` returns a second init invocation.
    $starshipInit = Get-DotfilesShellInit starship @('init', 'powershell', '--print-full-init')
    if ($starshipInit) {
        Invoke-Expression $starshipInit
        # Starship replaced prompt; let zoxide wrap the new prompt once on reload.
        $global:__zoxide_hooked = 0
    }
}
$zoxideInit = Get-DotfilesShellInit zoxide @('init', 'powershell')
if ($zoxideInit) { Invoke-Expression $zoxideInit }
Remove-Variable starshipInit,zoxideInit -ErrorAction SilentlyContinue
