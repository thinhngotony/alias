# Hyber Orbit Dotfiles Auto-Install for Windows PowerShell
$ErrorActionPreference = "Stop"

# Colors
function Write-Color($Text, $Color) {
    Write-Host $Text -ForegroundColor $Color
}

# Print header
Write-Color "╔════════════════════════════════════════╗" Cyan
Write-Color "║  Hyber Orbit Dotfiles Auto-Install     ║" Cyan
Write-Color "╚════════════════════════════════════════╝" Cyan
Write-Host ""
Write-Host "🔍 Auto-detected:"
Write-Host "   OS: Windows | Shell: PowerShell | Env: dev"
Write-Host ""

# Create directories
$HyberHome = "$env:USERPROFILE\.hyberorbit"
$CustomDir = "$HyberHome\custom"
New-Item -ItemType Directory -Force -Path $HyberHome | Out-Null
New-Item -ItemType Directory -Force -Path $CustomDir | Out-Null

# Download loader
Write-Color "⬇️  Downloading..." Yellow
$Repo = "https://raw.githubusercontent.com/thinhngotony/alias/main"
Invoke-WebRequest -Uri "$Repo/load.ps1" -OutFile "$HyberHome\load.ps1" -UseBasicParsing
Write-Color "✓ Downloaded" Green
Write-Host ""

# Save environment
@"
`$env:HYBER_ENV = "dev"
`$env:HYBER_SHELL = "powershell"
`$env:HYBER_OS = "windows"
"@ | Out-File -FilePath "$HyberHome\env.ps1" -Encoding UTF8

# Add to PowerShell profile if not already there
Write-Color "🔗 Configuring shell..." Yellow
$ProfileDir = Split-Path $PROFILE -Parent
if (!(Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
}
if (!(Test-Path $PROFILE)) {
    New-Item -ItemType File -Force -Path $PROFILE | Out-Null
}

$ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($ProfileContent -notmatch "hyberorbit") {
    Add-Content -Path $PROFILE -Value "`n# Hyber Orbit Dotfiles"
    Add-Content -Path $PROFILE -Value ". `"$HyberHome\load.ps1`""
    Write-Color "✓ Added to $PROFILE" Green
} else {
    Write-Color "✓ Already configured" Green
}
Write-Host ""

# Reload profile
Write-Color "🔄 Reloading shell..." Yellow
. $PROFILE
Write-Color "✓ Shell reloaded" Green
Write-Host ""

# Done
Write-Color "╔════════════════════════════════════════╗" Cyan
Write-Color "║         ✨ Installation Complete!       ║" Cyan
Write-Color "╚════════════════════════════════════════╝" Cyan
Write-Host ""
Write-Host "Try it:"
Write-Host "  ga       # git add ."
Write-Host "  gb       # git branch"
Write-Host "  k get po # kubectl get pods"
Write-Host ""
