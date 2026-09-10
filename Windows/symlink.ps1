[CmdletBinding(SupportsShouldProcess)]
param()
$ErrorActionPreference = 'Stop'
$dotfiles = $PSScriptRoot
function New-BackedUpLink {
    param([string]$Source,[string]$Target)
    if (!(Test-Path -LiteralPath $Source)) { throw "Missing source: $Source" }
    $Source = [IO.Path]::GetFullPath($Source)
    $Target = [IO.Path]::GetFullPath($Target)
    $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -eq 'SymbolicLink' -and
        [IO.Path]::GetFullPath([string]$item.Target) -eq $Source) { Write-Host "Already linked: $Target"; return }
    if (!$PSCmdlet.ShouldProcess($Target,"Link to $Source (back up existing target)")) { return }
    New-Item -ItemType Directory -Path (Split-Path $Target) -Force | Out-Null
    $backup = $null
    if ($item) {
        $backup = $Target + '.backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0,6)
        Move-Item -LiteralPath $Target -Destination $backup
    }
    try { New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null }
    catch {
        if ($backup) { Move-Item -LiteralPath $backup -Destination $Target }
        throw
    }
    Write-Host "Linked: $Target"
}
New-BackedUpLink "$dotfiles/git/.gitconfig" "$HOME/.gitconfig"
New-BackedUpLink "$dotfiles/git/.gitignore" "$HOME/.gitignore"
New-BackedUpLink "$dotfiles/Microsoft.PowerShell_profile.ps1" $PROFILE
New-BackedUpLink "$dotfiles/config/starship.toml" "$HOME/.config/starship.toml"
New-BackedUpLink "$dotfiles/config/nvim" "$env:LOCALAPPDATA/nvim"
New-BackedUpLink "$dotfiles/config/yazi" "$env:APPDATA/yazi/config"
