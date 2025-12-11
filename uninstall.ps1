# Hyber Orbit Aliases Uninstaller for Windows PowerShell

Write-Host ""
Write-Host "Uninstalling Hyber Orbit Aliases..." -ForegroundColor Yellow
Write-Host ""

# Remove alias directory
$AliasHome = "$env:USERPROFILE\.alias"
if (Test-Path $AliasHome) {
    Remove-Item -Recurse -Force $AliasHome
    Write-Host "[OK] Removed $AliasHome" -ForegroundColor Green
} else {
    Write-Host "[~] $AliasHome not found (already removed?)" -ForegroundColor Yellow
}

# Remove from PowerShell profile
if (Test-Path $PROFILE) {
    $content = Get-Content $PROFILE -Raw
    if ($content -match '\.alias') {
        $newContent = (Get-Content $PROFILE) | Where-Object {
            $_ -notmatch '# Hyber Orbit' -and $_ -notmatch '\.alias\\load\.ps1'
        }
        $newContent | Set-Content $PROFILE
        Write-Host "[OK] Removed from $PROFILE" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Uninstall complete!" -ForegroundColor Green
Write-Host "Open a new PowerShell window to apply changes."
Write-Host ""
