#!/bin/bash
# =============================================================================
# Secure Token Management
# =============================================================================

SECRETS_DIR="$HOME/.alias/.secrets"

# Store a secret securely
alias-secret-add() {
    local name="$1"
    local value="$2"
    
    if [ -z "$name" ] || [ -z "$value" ]; then
        echo -e "\n  \033[0;31m✗\033[0m Usage: alias-secret-add <name> <value>\n"
        return 1
    fi
    
    mkdir -p "$SECRETS_DIR"
    chmod 700 "$SECRETS_DIR"
    
    echo -n "$value" | base64 > "$SECRETS_DIR/${name}.enc"
    chmod 600 "$SECRETS_DIR/${name}.enc"
    
    echo -e "\n  \033[0;32m✓\033[0m Secret '\033[1m$name\033[0m' stored securely\n"
}

# Get a secret (requires sudo authentication)
alias-secret-get() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo -e "\n  \033[0;31m✗\033[0m Usage: alias-secret-get <name>\n"
        return 1
    fi
    
    local secret_file="$SECRETS_DIR/${name}.enc"
    
    if [ ! -f "$secret_file" ]; then
        echo -e "\n  \033[0;31m✗\033[0m Secret '$name' not found\n"
        return 1
    fi
    
    echo -e "\n  \033[0;33m🔐 \033[0mAuthentication required for '\033[1m$name\033[0m'"
    if sudo -v 2>/dev/null; then
        echo -e "  \033[0;32m✓\033[0m $(base64 -d < "$secret_file")\n"
    else
        echo -e "  \033[0;31m✗\033[0m Authentication failed\n"
        return 1
    fi
}

# List stored secrets
alias-secret-list() {
    echo ""
    echo -e "  \033[1m📦 Stored Secrets\033[0m"
    echo -e "  \033[2m─────────────────────────────────────\033[0m"
    if [ -d "$SECRETS_DIR" ]; then
        local found=0
        # shellcheck disable=SC2044
        for f in $(find "$SECRETS_DIR" -name "*.enc" 2>/dev/null); do
            if [ -f "$f" ]; then
                local sname
                sname=$(basename "$f" .enc)
                echo -e "    \033[0;36m●\033[0m $sname"
                found=1
            fi
        done
        if [ "$found" -eq 0 ]; then
            echo -e "    \033[2mNo secrets stored\033[0m"
        fi
    else
        echo -e "    \033[2mNo secrets stored\033[0m"
    fi
    echo -e "  \033[2m─────────────────────────────────────\033[0m\n"
}

# Remove a secret
alias-secret-remove() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo -e "\n  \033[0;31m✗\033[0m Usage: alias-secret-remove <name>\n"
        return 1
    fi
    
    local secret_file="$SECRETS_DIR/${name}.enc"
    
    if [ ! -f "$secret_file" ]; then
        echo -e "\n  \033[0;31m✗\033[0m Secret '$name' not found\n"
        return 1
    fi
    
    echo -e "\n  \033[0;33m🔐 \033[0mAuthentication required to remove '\033[1m$name\033[0m'"
    if sudo -v 2>/dev/null; then
        rm -f "$secret_file"
        echo -e "  \033[0;32m✓\033[0m Secret '$name' removed\n"
    else
        echo -e "  \033[0;31m✗\033[0m Authentication failed\n"
        return 1
    fi
}

# Convenience aliases
alias-token() {
    alias-secret-get "cloudflare-token"
}

# Command not found handler - shows suggestions
alias-secret() {
    echo -e "\n  \033[0;33m⚠\033[0m  Command '\033[1malias-secret\033[0m' not found. Did you mean:\n"
    echo -e "      \033[0;36malias-secret-add\033[0m     \033[2mStore a secret\033[0m"
    echo -e "      \033[0;36malias-secret-get\033[0m     \033[2mRetrieve a secret\033[0m"
    echo -e "      \033[0;36malias-secret-list\033[0m    \033[2mList all secrets\033[0m"
    echo -e "      \033[0;36malias-secret-remove\033[0m  \033[2mDelete a secret\033[0m"
    echo -e "      \033[0;36malias-secrets\033[0m        \033[2mShow full help\033[0m"
    echo ""
}

# =============================================================================
# Help Function
# =============================================================================

alias-secrets() {
    local BOLD='\033[1m'
    local DIM='\033[2m'
    local CYAN='\033[0;36m'
    local MAGENTA='\033[0;35m'
    local NC='\033[0m'
    
    echo ""
    echo -e "                     ${BOLD}🔐 Secrets Manager${NC}"
    echo -e "${DIM}  ────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${MAGENTA}alias-secret-add${NC} ${DIM}<name> <value>${NC}"
    echo -e "      Store a secret securely"
    echo ""
    echo -e "  ${MAGENTA}alias-secret-get${NC} ${DIM}<name>${NC}"
    echo -e "      Retrieve secret ${DIM}(requires password)${NC}"
    echo ""
    echo -e "  ${MAGENTA}alias-secret-list${NC}"
    echo -e "      List all stored secret names"
    echo ""
    echo -e "  ${MAGENTA}alias-secret-remove${NC} ${DIM}<name>${NC}"
    echo -e "      Delete a secret ${DIM}(requires password)${NC}"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}⚡ Shortcuts${NC}"
    echo ""
    echo -e "      ${CYAN}alias-token${NC}  ${DIM}→ alias-secret-get cloudflare-token${NC}"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}💡 Example${NC}"
    echo ""
    echo -e "      ${DIM}\$${NC} alias-secret-add cloudflare-token \"KVs6F66...\""
    echo -e "      ${DIM}\$${NC} alias-token"
    echo -e "      ${DIM}\$${NC} alias-secret-list"
    echo -e "      ${DIM}\$${NC} alias-secret-remove cloudflare-token"
    echo ""
}
