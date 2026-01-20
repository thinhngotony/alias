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
    echo -e "${BOLD}Kubernetes Aliases${NC}"
    echo -e "${DIM}────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${CYAN}k${NC}              kubectl                      ${DIM}Shorthand${NC}"
    echo -e "  ${CYAN}ka${NC} <file>      kubectl apply -f <file>      ${DIM}Apply manifest${NC}"
    echo -e "  ${CYAN}kd${NC}             kubectl delete               ${DIM}Delete resource${NC}"
    echo -e "  ${CYAN}kdesc${NC}          kubectl describe             ${DIM}Describe resource${NC}"
    echo -e "  ${CYAN}ke${NC}             kubectl exec -it             ${DIM}Exec into container${NC}"
    echo -e "  ${CYAN}kg${NC}             kubectl get                  ${DIM}Get resources${NC}"
    echo -e "  ${CYAN}kgp${NC}            kubectl get pods             ${DIM}List pods${NC}"
    echo -e "  ${CYAN}kgs${NC}            kubectl get services         ${DIM}List services${NC}"
    echo -e "  ${CYAN}kl${NC}             kubectl logs                 ${DIM}View logs${NC}"
    echo -e "  ${CYAN}kctx${NC}           current-context              ${DIM}Show context${NC}"
    echo -e "  ${CYAN}kns${NC} <ns>       set namespace                ${DIM}Switch namespace${NC}"
    echo ""
    echo -e "${DIM}────────────────────────────────────────────────────────────────${NC}"
    echo ""
}
