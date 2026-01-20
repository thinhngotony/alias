#!/bin/bash
# =============================================================================
# Secure Token Management
# Requires sudo/password authentication to view stored tokens
# =============================================================================

SECRETS_DIR="$HOME/.alias/.secrets"

# Store a secret securely
alias-secret-add() {
    local name="$1"
    local value="$2"
    
    if [ -z "$name" ] || [ -z "$value" ]; then
        echo -e "\033[0;31m✗\033[0m Usage: alias-secret-add <name> <value>"
        echo "  Example: alias-secret-add cloudflare-token 'your-token-here'"
        return 1
    fi
    
    mkdir -p "$SECRETS_DIR"
    chmod 700 "$SECRETS_DIR"
    
    # Store encoded (base64)
    echo -n "$value" | base64 > "$SECRETS_DIR/${name}.enc"
    chmod 600 "$SECRETS_DIR/${name}.enc"
    
    echo -e "\033[0;32m✓\033[0m Secret '\033[1m$name\033[0m' stored securely"
}

# Get a secret (requires sudo authentication)
alias-secret-get() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo -e "\033[0;31m✗\033[0m Usage: alias-secret-get <name>"
        return 1
    fi
    
    local secret_file="$SECRETS_DIR/${name}.enc"
    
    if [ ! -f "$secret_file" ]; then
        echo -e "\033[0;31m✗\033[0m Secret '$name' not found"
        return 1
    fi
    
    # Require sudo authentication
    echo -e "\033[2mAuthentication required for '\033[0m\033[1m$name\033[0m\033[2m'\033[0m"
    if sudo -v 2>/dev/null; then
        base64 -d < "$secret_file"
        echo ""
    else
        echo -e "\033[0;31m✗\033[0m Authentication failed"
        return 1
    fi
}

# List stored secrets (names only, not values)
alias-secret-list() {
    echo -e "\n\033[1mStored Secrets\033[0m"
    echo -e "\033[2m─────────────────────────────────────────\033[0m"
    if [ -d "$SECRETS_DIR" ]; then
        local found=0
        # shellcheck disable=SC2044
        for f in $(find "$SECRETS_DIR" -name "*.enc" 2>/dev/null); do
            if [ -f "$f" ]; then
                local sname
                sname=$(basename "$f" .enc)
                echo -e "  \033[0;36m●\033[0m $sname"
                found=1
            fi
        done
        if [ "$found" -eq 0 ]; then
            echo -e "  \033[2mNo secrets stored\033[0m"
        fi
    else
        echo -e "  \033[2mNo secrets stored\033[0m"
    fi
    echo -e "\033[2m─────────────────────────────────────────\033[0m\n"
}

# Remove a secret
alias-secret-remove() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo -e "\033[0;31m✗\033[0m Usage: alias-secret-remove <name>"
        return 1
    fi
    
    local secret_file="$SECRETS_DIR/${name}.enc"
    
    if [ ! -f "$secret_file" ]; then
        echo -e "\033[0;31m✗\033[0m Secret '$name' not found"
        return 1
    fi
    
    # Require sudo authentication
    echo -e "\033[2mAuthentication required to remove '\033[0m\033[1m$name\033[0m\033[2m'\033[0m"
    if sudo -v 2>/dev/null; then
        rm -f "$secret_file"
        echo -e "\033[0;32m✓\033[0m Secret '$name' removed"
    else
        echo -e "\033[0;31m✗\033[0m Authentication failed"
        return 1
    fi
}

# Convenience alias for Cloudflare token
alias-token() {
    alias-secret-get "cloudflare-token"
}

# =============================================================================
# Help Function
# =============================================================================

alias-secrets() {
    echo -e "\n\033[1mSecrets Management\033[0m \033[2m(Secure Token Storage)\033[0m"
    echo -e "\033[2m─────────────────────────────────────────────────────────────\033[0m"
    echo ""
    echo -e "  \033[0;36malias-secret-add\033[0m <name> <value>   Store a secret"
    echo -e "  \033[0;36malias-secret-get\033[0m <name>          Retrieve (requires password)"
    echo -e "  \033[0;36malias-secret-list\033[0m                List all secret names"
    echo -e "  \033[0;36malias-secret-remove\033[0m <name>       Remove a secret"
    echo ""
    echo -e "  \033[0;36malias-token\033[0m                      Get cloudflare-token"
    echo ""
    echo -e "\033[2mExample:\033[0m"
    echo -e "  alias-secret-add cloudflare-token \"KVs6F66...\""
    echo -e "  alias-token"
    echo ""
    echo -e "\033[2mSecurity:\033[0m"
    echo -e "  • Secrets stored in ~/.alias/.secrets/ (mode 600)"
    echo -e "  • Retrieval requires sudo/password authentication"
    echo ""
    echo -e "\033[2m─────────────────────────────────────────────────────────────\033[0m\n"
}
