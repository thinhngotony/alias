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
    local BOLD='\033[1m'
    local DIM='\033[2m'
    local CYAN='\033[0;36m'
    local NC='\033[0m'
    
    echo ""
    echo -e "                    ${BOLD}☸️  Kubernetes Aliases${NC}"
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "      ${CYAN}k${NC}              ${DIM}kubectl${NC}"
    echo -e "      ${CYAN}ka${NC} <file>      ${DIM}kubectl apply -f${NC}"
    echo -e "      ${CYAN}kd${NC}             ${DIM}kubectl delete${NC}"
    echo -e "      ${CYAN}kdesc${NC}          ${DIM}kubectl describe${NC}"
    echo -e "      ${CYAN}ke${NC}             ${DIM}kubectl exec -it${NC}"
    echo -e "      ${CYAN}kg${NC}             ${DIM}kubectl get${NC}"
    echo -e "      ${CYAN}kgp${NC}            ${DIM}kubectl get pods${NC}"
    echo -e "      ${CYAN}kgs${NC}            ${DIM}kubectl get services${NC}"
    echo -e "      ${CYAN}kl${NC}             ${DIM}kubectl logs${NC}"
    echo -e "      ${CYAN}kctx${NC}           ${DIM}current-context${NC}"
    echo -e "      ${CYAN}kns${NC} <ns>       ${DIM}set namespace${NC}"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
}
