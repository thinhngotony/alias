#!/bin/bash
# =============================================================================
# System Aliases
# =============================================================================

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
# Dynamic reload based on current shell
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
    echo -e "${BOLD}System Aliases${NC}"
    echo -e "${DIM}────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${CYAN}ll${NC}             ls -lah                      ${DIM}Detailed list${NC}"
    echo -e "  ${CYAN}la${NC}             ls -A                        ${DIM}List all${NC}"
    echo -e "  ${CYAN}l${NC}              ls -CF                       ${DIM}Compact list${NC}"
    echo -e "  ${CYAN}cls${NC}            clear                        ${DIM}Clear screen${NC}"
    echo -e "  ${CYAN}reload${NC}         source ~/.bashrc|~/.zshrc    ${DIM}Reload config${NC}"
    echo -e "  ${CYAN}home${NC}           cd ~                         ${DIM}Go home${NC}"
    echo -e "  ${CYAN}..${NC}             cd ..                        ${DIM}Up one level${NC}"
    echo -e "  ${CYAN}...${NC}            cd ../..                     ${DIM}Up two levels${NC}"
    echo ""
    echo -e "${DIM}────────────────────────────────────────────────────────────────${NC}"
    echo ""
}
