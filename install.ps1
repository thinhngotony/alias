# Hyber Orbit Dotfiles Auto-Install for Windows PowerShell
$ErrorActionPreference = "Stop"

# Print header
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Hyber Orbit Dotfiles Auto-Install    " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Auto-detected:"
Write-Host "   OS: Windows | Shell: PowerShell | Env: dev"
Write-Host ""

# Check execution policy
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "Undefined") {
    Write-Host "[!] PowerShell execution policy is restricted." -ForegroundColor Yellow
    Write-Host "    Running: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
    Write-Host ""
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "[OK] Execution policy updated" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Could not set execution policy. Run PowerShell as Administrator and execute:" -ForegroundColor Red
        Write-Host "        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

# Create directories
$HyberHome = "$env:USERPROFILE\.hyberorbit"
$CustomDir = "$HyberHome\custom"
New-Item -ItemType Directory -Force -Path $HyberHome | Out-Null
New-Item -ItemType Directory -Force -Path $CustomDir | Out-Null

# Download loader
Write-Host "[..] Downloading..." -ForegroundColor Yellow
$Repo = "https://raw.githubusercontent.com/thinhngotony/alias/main"
try {
    Invoke-WebRequest -Uri "$Repo/load.ps1" -OutFile "$HyberHome\load.ps1" -UseBasicParsing
    Write-Host "[OK] Downloaded" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to download loader: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Save environment
@"
`$env:HYBER_ENV = "dev"
`$env:HYBER_SHELL = "powershell"
`$env:HYBER_OS = "windows"
"@ | Out-File -FilePath "$HyberHome\env.ps1" -Encoding UTF8

# Add to PowerShell profile if not already there
Write-Host "[..] Configuring shell..." -ForegroundColor Yellow
$ProfileDir = Split-Path $PROFILE -Parent
if (!(Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
}
if (!(Test-Path $PROFILE)) {
    New-Item -ItemType File -Force -Path $PROFILE | Out-Null
}

$ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($null -eq $ProfileContent -or $ProfileContent -notmatch "hyberorbit") {
    Add-Content -Path $PROFILE -Value "`n# Hyber Orbit Dotfiles"
    Add-Content -Path $PROFILE -Value ". `"$HyberHome\load.ps1`""
    Write-Host "[OK] Added to $PROFILE" -ForegroundColor Green
} else {
    Write-Host "[OK] Already configured" -ForegroundColor Green
}
Write-Host ""

# Reload profile
Write-Host "[..] Loading aliases..." -ForegroundColor Yellow
try {
    . "$HyberHome\load.ps1"
    Write-Host "[OK] Aliases loaded" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Could not load aliases: $_" -ForegroundColor Yellow
    Write-Host "       Open a new PowerShell window to use aliases." -ForegroundColor Yellow
}
Write-Host ""

# Done
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "       Installation Complete!          " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Try these commands:"
Write-Host "  ga       # git add ."
Write-Host "  gb       # git branch"
Write-Host "  gs       # git status"
Write-Host "  k get po # kubectl get pods"
Write-Host ""
Write-Host "Add custom aliases in: $HyberHome\custom\"
Write-Host ""
