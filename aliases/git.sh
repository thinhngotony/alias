#!/bin/bash
# =============================================================================
# Git Aliases
# =============================================================================

alias ga='git add .'
alias gauto='git add . && git commit -m "Backup" && git push origin HEAD'
alias gb='git branch'
alias gc='git commit -m'
alias gph='git push origin'
alias gpl='git pull origin'
alias gs='git status'
alias gsw='git switch'
alias gd='git diff'
alias glog='git log --oneline -n 20'

# =============================================================================
# Help Function
# =============================================================================

alias-git() {
    local BOLD='\033[1m'
    local DIM='\033[2m'
    local CYAN='\033[0;36m'
    local NC='\033[0m'
    
    echo ""
    echo -e "${BOLD}Git Aliases${NC}"
    echo -e "${DIM}────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${CYAN}ga${NC}             git add .                    ${DIM}Stage all changes${NC}"
    echo -e "  ${CYAN}gauto${NC}          add + commit + push          ${DIM}Quick backup${NC}"
    echo -e "  ${CYAN}gb${NC}             git branch                   ${DIM}List branches${NC}"
    echo -e "  ${CYAN}gc${NC} <msg>       git commit -m <msg>          ${DIM}Commit with message${NC}"
    echo -e "  ${CYAN}gd${NC}             git diff                     ${DIM}Show changes${NC}"
    echo -e "  ${CYAN}glog${NC}           git log --oneline -n 20      ${DIM}Recent commits${NC}"
    echo -e "  ${CYAN}gph${NC} <branch>   git push origin <branch>     ${DIM}Push to remote${NC}"
    echo -e "  ${CYAN}gpl${NC} <branch>   git pull origin <branch>     ${DIM}Pull from remote${NC}"
    echo -e "  ${CYAN}gs${NC}             git status                   ${DIM}Working tree status${NC}"
    echo -e "  ${CYAN}gsw${NC} <branch>   git switch <branch>          ${DIM}Switch branches${NC}"
    echo ""
    echo -e "${DIM}────────────────────────────────────────────────────────────────${NC}"
    echo ""
}
