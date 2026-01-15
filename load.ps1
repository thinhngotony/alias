# Hyber Alias Loader for PowerShell

$AliasHome = "$env:USERPROFILE\.alias"

# Source environment
if (Test-Path "$AliasHome\env.ps1") {
    . "$AliasHome\env.ps1"
}

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

function global:alias-help {
    Write-Host @"
Hyber Alias
===============================================================================

Available Categories (type alias-<category> for details):

  alias-git      Git commands (ga, gcm, gs, gph, gpl...)
  alias-k8s      Kubernetes commands (k, ka, kgp, kgs...)
  alias-system   System commands (ll, la, reload...)
  alias-help     Show this help

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
