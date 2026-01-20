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
    echo -e "                       ${BOLD}🔀 Git Aliases${NC}"
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "      ${CYAN}ga${NC}             ${DIM}git add .${NC}"
    echo -e "      ${CYAN}gauto${NC}          ${DIM}add → commit → push${NC}"
    echo -e "      ${CYAN}gb${NC}             ${DIM}git branch${NC}"
    echo -e "      ${CYAN}gc${NC} <msg>       ${DIM}git commit -m${NC}"
    echo -e "      ${CYAN}gd${NC}             ${DIM}git diff${NC}"
    echo -e "      ${CYAN}glog${NC}           ${DIM}git log --oneline -n 20${NC}"
    echo -e "      ${CYAN}gph${NC} <branch>   ${DIM}git push origin${NC}"
    echo -e "      ${CYAN}gpl${NC} <branch>   ${DIM}git pull origin${NC}"
    echo -e "      ${CYAN}gs${NC}             ${DIM}git status${NC}"
    echo -e "      ${CYAN}gsw${NC} <branch>   ${DIM}git switch${NC}"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
}
