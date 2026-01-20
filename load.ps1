# Hyber Alias Loader for PowerShell - v1.1.0

$AliasHome = "$env:USERPROFILE\.alias"
$AliasVersion = "1.1.0"
$Repo = "https://raw.githubusercontent.com/thinhngotony/alias/main"

# Source environment
if (Test-Path "$AliasHome\env.ps1") {
    . "$AliasHome\env.ps1"
}

# Self-update loader in background
$selfUpdateJob = Start-Job -ScriptBlock {
    param($Repo, $AliasHome)
    try {
        $loaderUrl = "$Repo/load.ps1"
        $loaderTmp = "$AliasHome\load.ps1.tmp"
        $loaderPath = "$AliasHome\load.ps1"
        Invoke-WebRequest -Uri $loaderUrl -OutFile $loaderTmp -TimeoutSec 5 -ErrorAction Stop
        if ((Test-Path $loaderTmp) -and (Get-Item $loaderTmp).Length -gt 0) {
            $newContent = Get-Content $loaderTmp -Raw
            $oldContent = if (Test-Path $loaderPath) { Get-Content $loaderPath -Raw } else { "" }
            if ($newContent -ne $oldContent) {
                Move-Item $loaderTmp $loaderPath -Force
            } else {
                Remove-Item $loaderTmp -Force -ErrorAction SilentlyContinue
            }
        }
    } catch {
        Remove-Item "$AliasHome\load.ps1.tmp" -Force -ErrorAction SilentlyContinue
    }
} -ArgumentList $Repo, $AliasHome

# =============================================================================
# Git Aliases
# =============================================================================

function global:ga { git add . }
function global:gauto { git add .; git commit -m "Backup"; git push origin HEAD }
function global:gb { git branch $args }
function global:gcm { param([string]$msg) git commit -m $msg }
function global:gph { param([string]$branch) git push origin $branch }
function global:gpl { param([string]$branch) git pull origin $branch }
function global:gs { git status $args }
function global:gsw { param([string]$branch) git switch $branch }
function global:gd { git diff $args }
function global:glog { git log --oneline -n 20 $args }

# =============================================================================
# Kubernetes Aliases
# =============================================================================

function global:k { kubectl $args }
function global:ka { param([string]$file) kubectl apply -f $file }
function global:kd { kubectl delete $args }
function global:kdesc { kubectl describe $args }
function global:kg { kubectl get $args }
function global:kgp { kubectl get pods }
function global:kgs { kubectl get services }
function global:kl { kubectl logs $args }
function global:ke { kubectl exec -it $args }
function global:kctx { kubectl config current-context }
function global:kns { param([string]$ns) kubectl config set-context --current --namespace $ns }

# =============================================================================
# System Aliases
# =============================================================================

function global:ll { Get-ChildItem -Force | Format-Table Mode, LastWriteTime, Length, Name -AutoSize }
function global:la { Get-ChildItem -Force -Name }
function global:reload { . $PROFILE }
function global:home { Set-Location ~ }
function global:.. { Set-Location .. }
function global:... { Set-Location ..\.. }

# =============================================================================
# Help Functions
# =============================================================================

function global:alias-git {
    Write-Host @"
Git Aliases
===============================================================================
  ga           git add .                      Stage all changes
  gauto        add + commit + push            Quick backup to remote
  gb           git branch                     List branches
  gcm <msg>    git commit -m <msg>            Commit with message
  gd           git diff                       Show unstaged changes
  glog         git log --oneline -n 20        Recent commits (20)
  gph <branch> git push origin <branch>       Push to remote
  gpl <branch> git pull origin <branch>       Pull from remote
  gs           git status                     Working tree status
  gsw <branch> git switch <branch>            Switch branches
===============================================================================
"@
}

function global:alias-k8s {
    Write-Host @"
Kubernetes Aliases
===============================================================================
  k            kubectl                        Shorthand for kubectl
  ka <file>    kubectl apply -f <file>        Apply manifest
  kd           kubectl delete                 Delete resource
  kdesc        kubectl describe               Describe resource
  ke           kubectl exec -it               Exec into container
  kg           kubectl get                    Get resources
  kgp          kubectl get pods               List pods
  kgs          kubectl get services           List services
  kl           kubectl logs                   View logs
  kctx         kubectl config current-context Current context
  kns <ns>     set namespace                  Switch namespace
===============================================================================
"@
}

function global:alias-system {
    Write-Host @"
System Aliases
===============================================================================
  ll           Get-ChildItem -Force           Detailed list with hidden
  la           Get-ChildItem -Force -Name     List all names
  reload       . `$PROFILE                     Reload PowerShell profile
  home         Set-Location ~                 Go to home directory
  ..           Set-Location ..                Up one level
  ...          Set-Location ..\..             Up two levels
===============================================================================
"@
}

# =============================================================================
# Custom Category Management
# =============================================================================

function global:alias-add {
    param(
        [Parameter(Mandatory=$true)][string]$Category,
        [Parameter(Mandatory=$true)][string]$AliasName,
        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)][string[]]$Command
    )
    
    $commandStr = $Command -join " "
    $categoryFile = "$AliasHome\custom\$Category.ps1"
    
    if (-not (Test-Path "$AliasHome\custom")) {
        New-Item -ItemType Directory -Path "$AliasHome\custom" -Force | Out-Null
    }
    
    # Check if alias already exists
    if ((Test-Path $categoryFile) -and (Select-String -Path $categoryFile -Pattern "function global:$AliasName " -Quiet)) {
        Write-Host "Alias '$AliasName' already exists in category '$Category'. Use alias-remove first."
        return
    }
    
    # Create category file if not exists
    if (-not (Test-Path $categoryFile)) {
        @"
# Custom Category: $Category

# =============================================================================
# Help Function
# =============================================================================

function global:alias-$Category {
    Write-Host "$Category Aliases (Custom)"
    Write-Host "==============================================================================="
    Get-Content "$AliasHome\custom\$Category.ps1" | Select-String "^function global:" | ForEach-Object {
        `$line = `$_.Line -replace "function global:", "" -replace " \{.*", ""
        if (`$line -ne "alias-$Category") {
            Write-Host "  `$line"
        }
    }
    Write-Host "==============================================================================="
}

# ALIASES_START
# ALIASES_END
"@ | Out-File $categoryFile -Encoding UTF8
    }
    
    # Add alias function
    $aliasFunc = "function global:$AliasName { $commandStr `$args }"
    $content = Get-Content $categoryFile -Raw
    $content = $content -replace "# ALIASES_END", "$aliasFunc`n# ALIASES_END"
    $content | Out-File $categoryFile -Encoding UTF8
    
    # Load the new function
    Invoke-Expression $aliasFunc
    
    Write-Host "Added alias '$AliasName' -> '$commandStr' to category '$Category'"
    Write-Host "Run 'alias-$Category' to see all aliases in this category"
}

function global:alias-remove {
    param(
        [Parameter(Mandatory=$true)][string]$Category,
        [Parameter(Mandatory=$true)][string]$AliasName
    )
    
    $categoryFile = "$AliasHome\custom\$Category.ps1"
    
    if (-not (Test-Path $categoryFile)) {
        Write-Host "Category '$Category' not found"
        return
    }
    
    $content = Get-Content $categoryFile -Raw
    if ($content -notmatch "function global:$AliasName ") {
        Write-Host "Alias '$AliasName' not found in category '$Category'"
        return
    }
    
    # Remove the function line
    $content = $content -replace "function global:$AliasName \{[^}]+\}\r?\n?", ""
    $content | Out-File $categoryFile -Encoding UTF8
    
    # Remove from current session
    Remove-Item "Function:\$AliasName" -ErrorAction SilentlyContinue
    
    Write-Host "Removed alias '$AliasName' from category '$Category'"
}

function global:alias-list {
    Write-Host "Custom Categories:"
    Write-Host "==============================================================================="
    if (Test-Path "$AliasHome\custom") {
        Get-ChildItem "$AliasHome\custom\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
            $catName = $_.BaseName
            $count = (Select-String -Path $_.FullName -Pattern "^function global:" | Where-Object { $_.Line -notmatch "alias-$catName" }).Count
            Write-Host ("  alias-{0,-10} {1} alias(es)" -f $catName, $count)
        }
    } else {
        Write-Host "  No custom categories. Create one with: alias-add <category> <name> <cmd>"
    }
    Write-Host "==============================================================================="
}

function global:alias-help {
    Write-Host @"
Hyber Alias
===============================================================================

Available Categories (type alias-<category> for details):

  alias-git      Git commands (ga, gcm, gs, gph, gpl...)
  alias-k8s      Kubernetes commands (k, ka, kgp, kgs...)
  alias-system   System commands (ll, la, reload...)

Custom Alias Management:

  alias-add <category> <name> <command>   Add alias to category
  alias-remove <category> <name>          Remove alias from category
  alias-list                              List all custom categories
  alias-help                              Show this help

Example:
  alias-add ai claudex "claude --dangerously-skip-permissions"
  alias-add ai gpt "chatgpt --model gpt-4"
  alias-ai                                # Show all AI aliases

Tip: Type 'alias-' then press TAB for autocomplete

===============================================================================
"@
}

# Source user custom aliases
if (Test-Path "$AliasHome\custom") {
    Get-ChildItem "$AliasHome\custom\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
        . $_.FullName
    }
}
