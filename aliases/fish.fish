# =============================================================================
# Hyber Alias for Fish Shell
# =============================================================================

# Git Aliases
alias ga 'git add .'
alias gauto 'git add . && git commit -m "Backup" && git push origin HEAD'
alias gb 'git branch'
alias gc 'git commit -m'
alias gph 'git push origin'
alias gpl 'git pull origin'
alias gs 'git status'
alias gsw 'git switch'
alias gd 'git diff'
alias glog 'git log --oneline -n 20'

# Kubernetes Aliases
alias k 'kubectl'
alias ka 'kubectl apply -f'
alias kd 'kubectl delete'
alias kdesc 'kubectl describe'
alias kg 'kubectl get'
alias kgp 'kubectl get pods'
alias kgs 'kubectl get services'
alias kl 'kubectl logs'
alias ke 'kubectl exec -it'
alias kctx 'kubectl config current-context'
alias kns 'kubectl config set-context --current --namespace'

# System Aliases
alias ll 'ls -lah'
alias la 'ls -A'
alias l 'ls -CF'
alias cls 'clear'
alias reload 'source ~/.config/fish/config.fish'
alias home 'cd ~'

# =============================================================================
# Help Functions
# =============================================================================

function alias-help
    echo ""
    echo "                       ⚡ Hyber Alias v1.1.0"
    echo "                Cross-platform shell alias manager"
    echo ""
    echo "  ────────────────────────────────────────────────────────────────"
    echo ""
    echo "  📁 Categories"
    echo ""
    echo "      alias-git        Git commands (ga, gc, gs, gph...)"
    echo "      alias-k8s        Kubernetes (k, kgp, kgs, kl...)"
    echo "      alias-system     System (ll, la, cls, reload...)"
    echo ""
    echo "  ────────────────────────────────────────────────────────────────"
    echo ""
    echo "  💡 Tip   Type alias- + TAB for autocomplete"
    echo "  📚 Docs  https://github.com/thinhngotony/alias"
    echo ""
end

function alias-git
    echo ""
    echo "                         Git Aliases"
    echo "  ────────────────────────────────────────────────────────────────"
    echo ""
    echo "      ga             git add ."
    echo "      gauto          add → commit → push"
    echo "      gb             git branch"
    echo "      gc <msg>       git commit -m"
    echo "      gd             git diff"
    echo "      glog           git log --oneline -n 20"
    echo "      gph <branch>   git push origin"
    echo "      gpl <branch>   git pull origin"
    echo "      gs             git status"
    echo "      gsw <branch>   git switch"
    echo ""
end

function alias-k8s
    echo ""
    echo "                     ☸  Kubernetes Aliases"
    echo "  ────────────────────────────────────────────────────────────────"
    echo ""
    echo "      k              kubectl"
    echo "      ka <file>      kubectl apply -f"
    echo "      kd             kubectl delete"
    echo "      kdesc          kubectl describe"
    echo "      ke             kubectl exec -it"
    echo "      kg             kubectl get"
    echo "      kgp            kubectl get pods"
    echo "      kgs            kubectl get services"
    echo "      kl             kubectl logs"
    echo "      kctx           current-context"
    echo "      kns <ns>       set namespace"
    echo ""
end

function alias-system
    echo ""
    echo "                       💻 System Aliases"
    echo "  ────────────────────────────────────────────────────────────────"
    echo ""
    echo "      ll             ls -lah"
    echo "      la             ls -A"
    echo "      l              ls -CF"
    echo "      cls            clear"
    echo "      reload         source config.fish"
    echo "      home           cd ~"
    echo ""
end
