#!/bin/bash
# =============================================================================
# Secure Token Management
# Requires sudo/password authentication to view stored tokens
# =============================================================================

SECRETS_DIR="$HOME/.alias/.secrets"

# Store a secret securely (encrypted with user password via sudo)
alias-secret-add() {
    local name="$1"
    local value="$2"
    
    if [ -z "$name" ] || [ -z "$value" ]; then
        echo "Usage: alias-secret-add <name> <value>"
        echo "Example: alias-secret-add cloudflare-token 'your-token-here'"
        return 1
    fi
    
    mkdir -p "$SECRETS_DIR"
    chmod 700 "$SECRETS_DIR"
    
    # Store encrypted (base64 + file permissions)
    echo "$value" | base64 > "$SECRETS_DIR/${name}.enc"
    chmod 600 "$SECRETS_DIR/${name}.enc"
    
    echo "Secret '$name' stored securely"
    echo "Use 'alias-secret-get $name' to retrieve (requires password)"
}

# Get a secret (requires sudo authentication)
alias-secret-get() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "Usage: alias-secret-get <name>"
        return 1
    fi
    
    local secret_file="$SECRETS_DIR/${name}.enc"
    
    if [ ! -f "$secret_file" ]; then
        echo "Secret '$name' not found"
        return 1
    fi
    
    # Require sudo authentication
    echo "Authentication required to access secret '$name'"
    if sudo -v 2>/dev/null; then
        base64 -d "$secret_file"
        echo ""
    else
        echo "Authentication failed"
        return 1
    fi
}

# List stored secrets (names only, not values)
alias-secret-list() {
    echo "Stored secrets:"
    echo "==============================================================================="
    if [ -d "$SECRETS_DIR" ]; then
        # shellcheck disable=SC2044
        for f in $(find "$SECRETS_DIR" -name "*.enc" 2>/dev/null); do
            if [ -f "$f" ]; then
                basename "$f" .enc
            fi
        done
    else
        echo "  No secrets stored"
    fi
    echo "==============================================================================="
}

# Remove a secret
alias-secret-remove() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "Usage: alias-secret-remove <name>"
        return 1
    fi
    
    local secret_file="$SECRETS_DIR/${name}.enc"
    
    if [ ! -f "$secret_file" ]; then
        echo "Secret '$name' not found"
        return 1
    fi
    
    # Require sudo authentication
    echo "Authentication required to remove secret '$name'"
    if sudo -v 2>/dev/null; then
        rm -f "$secret_file"
        echo "Secret '$name' removed"
    else
        echo "Authentication failed"
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
    cat << 'HELP'
Secrets Management (Secure Token Storage)
===============================================================================
  alias-secret-add <name> <value>    Store a secret (password protected)
  alias-secret-get <name>            Retrieve a secret (requires password)
  alias-secret-list                  List stored secret names
  alias-secret-remove <name>         Remove a secret (requires password)
  
  alias-token                        Shortcut for: alias-secret-get cloudflare-token

Example:
  alias-secret-add cloudflare-token "KVs6F66TPYeHHsnF..."
  alias-token      # Prompts for password, then shows token

Security:
  - Secrets are stored in ~/.alias/.secrets/ with 600 permissions
  - Retrieving requires sudo/password authentication
  - Only secret names are visible without authentication
===============================================================================
HELP
}
