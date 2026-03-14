#!/bin/bash
# =============================================================================
# AI Aliases
# =============================================================================

alias copilotx='copilot --allow-all-tools --allow-all-paths'
alias claudex='claude --allow-dangerously-skip-permissions --dangerously-skip-permissions'

# =============================================================================
# Help Function
# =============================================================================

alias-ai() {
    local BOLD='\033[1m'
    local DIM='\033[2m'
    local CYAN='\033[0;36m'
    local NC='\033[0m'
    
    echo ""
    echo -e "                        ${BOLD}🤖 AI Aliases${NC}"
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "      ${CYAN}copilotx${NC}       ${DIM}copilot --allow-all-tools --allow-all-paths${NC}"
    echo -e "      ${CYAN}claudex${NC}        ${DIM}claude --allow-dangerously-skip-permissions${NC}"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
}
