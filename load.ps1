# Hyber Orbit Dotfiles Loader for PowerShell

$HyberHome = "$env:USERPROFILE\.hyberorbit"

# Source environment
if (Test-Path "$HyberHome\env.ps1") {
    . "$HyberHome\env.ps1"
}

# Git aliases
function ga { git add . }
function gauto { git add .; git commit -m "Backup"; git push origin HEAD }
function gb { git branch }
function gc { param([string]$msg) git commit -m $msg }
function gph { param([string]$branch) git push origin $branch }
function gpl { param([string]$branch) git pull origin $branch }
function gs { git status }
function gsw { param([string]$branch) git switch $branch }
function gd { git diff }
function glog { git log --oneline -n 20 }

# Kubernetes aliases
function k { kubectl $args }
function ka { param([string]$file) kubectl apply -f $file }
function kd { kubectl delete $args }
function kdesc { kubectl describe $args }
function kg { kubectl get $args }
function kgp { kubectl get pods }
function kgs { kubectl get services }
function kl { kubectl logs $args }
function ke { kubectl exec -it $args }
function kctx { kubectl config current-context }
function kns { param([string]$ns) kubectl config set-context --current --namespace $ns }

# System aliases
function ll { Get-ChildItem -Force }
function la { Get-ChildItem -Force -Name }
function cls { Clear-Host }
function reload { . $PROFILE }
function home { Set-Location ~ }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

# Source user custom aliases
if (Test-Path "$HyberHome\custom") {
    Get-ChildItem "$HyberHome\custom\*.ps1" | ForEach-Object {
        . $_.FullName
    }
}
