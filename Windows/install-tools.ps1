[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$packages = @{
    'starship'='Starship.Starship'; 'fzf'='junegunn.fzf'; 'zoxide'='ajeetdsouza.zoxide'; 'rg'='BurntSushi.ripgrep.MSVC'
    'fd'='sharkdp.fd'; 'nvim'='Neovim.Neovim'; 'yazi'='sxyazi.yazi'
    'lazygit'='JesseDuffield.lazygit'; 'jq'='jqlang.jq'; 'zig'='zig.zig'
}
foreach($name in $packages.Keys) {
    if(Get-Command $name -ErrorAction SilentlyContinue) { continue }
    winget install --id $packages[$name] --exact --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity --silent
    if($LASTEXITCODE -ne 0) { throw "Installation failed: $name ($LASTEXITCODE)" }
}
if(!(Test-Path "$env:ProgramFiles/7-Zip/7z.exe")) {
    winget install --id 7zip.7zip --exact --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity --silent
    if($LASTEXITCODE -ne 0) { throw '7-Zip installation failed' }
}
if(!(Get-Module -ListAvailable PSFzf)) {
    Install-Module PSFzf -Repository PSGallery -Scope CurrentUser -Force -AllowClobber
}
$env:PATH=[Environment]::GetEnvironmentVariable('Path','Machine')+';'+[Environment]::GetEnvironmentVariable('Path','User')
if(Get-Command uv -ErrorAction SilentlyContinue) {
    foreach($tool in @('ruff','ty')) {
        if(!(Get-Command $tool -ErrorAction SilentlyContinue)) {
            uv tool install $tool
            if($LASTEXITCODE -ne 0) { throw "uv tool install failed: $tool" }
        }
    }
}
& "$PSScriptRoot/symlink.ps1"
if (!(Get-Command ya -ErrorAction SilentlyContinue)) {
    throw 'Yazi package manager (ya) is missing. Install a matching Yazi/ya release and rerun this script.'
}
$previousYaziConfig = $env:YAZI_CONFIG_HOME
try {
    $env:YAZI_CONFIG_HOME = Join-Path $PSScriptRoot 'config/yazi'
    & ya pkg install
    if ($LASTEXITCODE -ne 0) { throw 'Yazi package restoration failed.' }
} finally {
    $env:YAZI_CONFIG_HOME = $previousYaziConfig
}
Write-Host 'Restart Windows Terminal to load the updated PATH and profile.'
