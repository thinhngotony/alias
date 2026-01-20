# =============================================================================
# Hyber Alias Installer v1.1.0
# Cross-platform shell alias manager
# https://github.com/thinhngotony/alias
# =============================================================================

$ErrorActionPreference = "Stop"

$Version = "1.1.0"
$Repo = "https://raw.githubusercontent.com/thinhngotony/alias/main"
$AliasHome = "$env:USERPROFILE\.alias"

# Check execution policy (skip in CI environments)
if (-not $env:SKIP_POLICY_CHECK) {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "Undefined") {
        Write-Host ""
        Write-Host "Execution policy is restricted. Updating..." -ForegroundColor Yellow
        try {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-Host "Policy updated" -ForegroundColor Green
        } catch {
            Write-Host "ERROR: Could not set execution policy." -ForegroundColor Red
            Write-Host "Run as Administrator: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Red
            exit 1
        }
    }
}

# Header
Write-Host ""
Write-Host "Hyber Alias" -ForegroundColor White -NoNewline
Write-Host " v$Version" -ForegroundColor DarkGray
Write-Host "Cross-platform shell alias manager" -ForegroundColor DarkGray
Write-Host ""

# System info
Write-Host "System" -ForegroundColor DarkGray
Write-Host "  OS         " -NoNewline; Write-Host "windows" -ForegroundColor White
Write-Host "  Shell      " -NoNewline; Write-Host "powershell" -ForegroundColor White
Write-Host "  Config     " -NoNewline; Write-Host "$PROFILE" -ForegroundColor DarkGray
Write-Host ""

# Install
Write-Host "Installing" -ForegroundColor DarkGray

# Create directories
New-Item -ItemType Directory -Force -Path $AliasHome | Out-Null
New-Item -ItemType Directory -Force -Path "$AliasHome\custom" | Out-Null
Write-Host "  " -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host " Created ~/.alias" -ForegroundColor DarkGray

# Download files
try {
    Invoke-WebRequest -Uri "$Repo/load.ps1" -OutFile "$AliasHome\load.ps1" -UseBasicParsing
    Write-Host "  " -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host " Downloaded aliases"
} catch {
    Write-Host "  " -NoNewline; Write-Host "✗" -ForegroundColor Red -NoNewline; Write-Host " Failed to download loader"
    exit 1
}

# Configure shell
$ProfileDir = Split-Path $PROFILE -Parent
if (!(Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
}
if (!(Test-Path $PROFILE)) {
    New-Item -ItemType File -Force -Path $PROFILE | Out-Null
}

$ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($null -eq $ProfileContent -or $ProfileContent -notmatch "\.alias\\load\.ps1") {
    Add-Content -Path $PROFILE -Value "`n# Hyber Alias - https://github.com/thinhngotony/alias"
    Add-Content -Path $PROFILE -Value "if (Test-Path `"$AliasHome\load.ps1`") { . `"$AliasHome\load.ps1`" }"
    Write-Host "  " -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host " Configured $PROFILE" -ForegroundColor DarkGray
} else {
    Write-Host "  " -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host " Already configured"
}

# Save environment
@"
`$env:HYBER_ENV = "dev"
`$env:HYBER_SHELL = "powershell"
`$env:HYBER_OS = "windows"
`$env:HYBER_VERSION = "$Version"
"@ | Out-File -FilePath "$AliasHome\env.ps1" -Encoding UTF8
Write-Host "  " -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host " Saved environment"

Write-Host ""

# Success
Write-Host "Installation complete" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  → Run this command to activate aliases:" -ForegroundColor Cyan
Write-Host ""
Write-Host "      . $PROFILE" -ForegroundColor White
Write-Host ""
Write-Host "  → Or open a new PowerShell window" -ForegroundColor Cyan
Write-Host ""
Write-Host "Quick start" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  alias-help     " -ForegroundColor Cyan -NoNewline; Write-Host "Show all available aliases"
Write-Host "  alias-git      " -ForegroundColor Cyan -NoNewline; Write-Host "Git shortcuts (ga, gcm, gs...)"
Write-Host "  alias-k8s      " -ForegroundColor Cyan -NoNewline; Write-Host "Kubernetes shortcuts (k, kgp...)"
Write-Host "  alias-add      " -ForegroundColor Cyan -NoNewline; Write-Host "Add custom aliases to categories"
Write-Host ""
Write-Host "Documentation  " -ForegroundColor DarkGray -NoNewline; Write-Host "https://github.com/thinhngotony/alias"
Write-Host ""
