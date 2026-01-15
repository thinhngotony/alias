#!/bin/bash
# =============================================================================
# Kubernetes Aliases
# =============================================================================

alias k='kubectl'
alias ka='kubectl apply -f'
alias kd='kubectl delete'
alias kdesc='kubectl describe'
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kl='kubectl logs'
alias ke='kubectl exec -it'
alias kctx='kubectl config current-context'
alias kns='kubectl config set-context --current --namespace'

# =============================================================================
# Help Function
# =============================================================================

alias-k8s() {
    cat << 'EOF'
Kubernetes Aliases
═══════════════════════════════════════════════════════════════════════════════
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
═══════════════════════════════════════════════════════════════════════════════
EOF
}
