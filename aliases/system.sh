#!/bin/bash
# =============================================================================
# System Aliases
# =============================================================================

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
if [ -n "$ZSH_VERSION" ]; then
    alias reload='source ~/.zshrc'
else
    alias reload='source ~/.bashrc'
fi
alias home='cd ~'
alias ..='cd ..'
alias ...='cd ../..'

# =============================================================================
# Help Function
# =============================================================================

alias-system() {
    local BOLD='\033[1m'
    local DIM='\033[2m'
    local CYAN='\033[0;36m'
    local NC='\033[0m'
    
    echo ""
    echo -e "                      ${BOLD}🖥️  System Aliases${NC}"
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "      ${CYAN}ll${NC}             ${DIM}ls -lah${NC}"
    echo -e "      ${CYAN}la${NC}             ${DIM}ls -A${NC}"
    echo -e "      ${CYAN}l${NC}              ${DIM}ls -CF${NC}"
    echo -e "      ${CYAN}cls${NC}            ${DIM}clear${NC}"
    echo -e "      ${CYAN}reload${NC}         ${DIM}source ~/.bashrc|~/.zshrc${NC}"
    echo -e "      ${CYAN}home${NC}           ${DIM}cd ~${NC}"
    echo -e "      ${CYAN}..${NC}             ${DIM}cd ..${NC}"
    echo -e "      ${CYAN}...${NC}            ${DIM}cd ../..${NC}"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
}
