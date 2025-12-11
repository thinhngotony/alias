# Hyber Alias Loader for PowerShell

$AliasHome = "$env:USERPROFILE\.alias"

# Source environment
if (Test-Path "$AliasHome\env.ps1") {
    . "$AliasHome\env.ps1"
}

# Git aliases - Global scope so they persist
function global:ga { git add . }
function global:gauto { git add .; git commit -m "Backup"; git push origin HEAD }
function global:gb { git branch }
function global:gc { param([string]$msg) git commit -m $msg }
function global:gph { param([string]$branch) git push origin $branch }
function global:gpl { param([string]$branch) git pull origin $branch }
function global:gs { git status }
function global:gsw { param([string]$branch) git switch $branch }
function global:gd { git diff }
function global:glog { git log --oneline -n 20 }

# Kubernetes aliases
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

# System aliases
function global:ll { Get-ChildItem -Force }
function global:la { Get-ChildItem -Force -Name }
function global:reload { . $PROFILE }
function global:home { Set-Location ~ }
function global:.. { Set-Location .. }
function global:... { Set-Location ..\.. }

# Source user custom aliases
if (Test-Path "$AliasHome\custom") {
    Get-ChildItem "$AliasHome\custom\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
        . $_.FullName
    }
}
