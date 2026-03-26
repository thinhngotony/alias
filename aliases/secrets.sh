#!/bin/bash
# =============================================================================
# Secure Token Management
# Uses AES-256-CBC encryption via OpenSSL (not base64)
# =============================================================================

SECRETS_DIR="$HOME/.alias/.secrets"

# Validate secret name: alphanumeric, hyphens, underscores only
_secret_validate_name() {
    local name="$1"
    if [ -z "$name" ]; then
        return 1
    fi
    if ! printf '%s' "$name" | grep -qE '^[a-zA-Z0-9_-]{1,64}$'; then
        echo -e "\n  \033[0;31m✗\033[0m Secret name must contain only letters, numbers, hyphens, and underscores (max 64 chars)\n"
        return 1
    fi
    case "$name" in
        *..* | */* | *\\*)
            echo -e "\n  \033[0;31m✗\033[0m Secret name contains invalid characters\n"
            return 1
            ;;
    esac
    return 0
}

# Check if a secret file is legacy base64 (not OpenSSL encrypted)
_secret_is_legacy() {
    local file="$1"
    # OpenSSL encrypted files start with "Salted__" magic bytes
    if head -c 8 "$file" 2>/dev/null | grep -q "Salted__"; then
        return 1  # Not legacy
    fi
    return 0  # Legacy base64
}

# Store a secret securely with AES-256-CBC encryption
alias-secret-add() {
    local name="$1"
    local value="$2"

    if [ -z "$name" ] || [ -z "$value" ]; then
        echo -e "\n  \033[0;31m✗\033[0m Usage: alias-secret-add <name> <value>\n"
        return 1
    fi

    _secret_validate_name "$name" || return 1

    # Verify openssl is available
    if ! command -v openssl >/dev/null 2>&1; then
        echo -e "\n  \033[0;31m✗\033[0m OpenSSL is required but not found\n"
        return 1
    fi

    mkdir -p "$SECRETS_DIR"
    chmod 700 "$SECRETS_DIR"

    local secret_file="$SECRETS_DIR/${name}.enc"

    # Prompt for encryption password
    local password password_confirm
    echo ""
    printf "  🔐 Enter encryption password: "
    read -r -s password
    echo ""
    if [ -z "$password" ]; then
        echo -e "  \033[0;31m✗\033[0m Password cannot be empty\n"
        return 1
    fi
    printf "  🔐 Confirm password: "
    read -r -s password_confirm
    echo ""

    if [ "$password" != "$password_confirm" ]; then
        echo -e "  \033[0;31m✗\033[0m Passwords do not match\n"
        return 1
    fi

    # Encrypt with AES-256-CBC + PBKDF2 key derivation
    if printf '%s' "$value" | openssl enc -aes-256-cbc -pbkdf2 -salt -pass "pass:${password}" -out "$secret_file" 2>/dev/null; then
        chmod 600 "$secret_file"
        echo -e "\n  \033[0;32m✓\033[0m Secret '\033[1m$name\033[0m' encrypted and stored\n"
    else
        rm -f "$secret_file" 2>/dev/null
        echo -e "  \033[0;31m✗\033[0m Failed to encrypt secret\n"
        return 1
    fi
}

# Get a secret (requires decryption password)
alias-secret-get() {
    local name="$1"

    if [ -z "$name" ]; then
        echo -e "\n  \033[0;31m✗\033[0m Usage: alias-secret-get <name>\n"
        return 1
    fi

    _secret_validate_name "$name" || return 1

    local secret_file="$SECRETS_DIR/${name}.enc"

    if [ ! -f "$secret_file" ]; then
        echo -e "\n  \033[0;31m✗\033[0m Secret '$name' not found\n"
        return 1
    fi

    # Check for legacy base64 format and warn
    if _secret_is_legacy "$secret_file"; then
        echo -e "\n  \033[0;33m⚠\033[0m  Secret '$name' uses legacy encoding (base64)."
        echo -e "     Re-encrypt with: alias-secret-add $name \"\$(base64 -d < '$secret_file')\"\n"
        echo -e "  \033[0;33m🔐 \033[0mRetrieving legacy secret '\033[1m$name\033[0m'"
        if sudo -v 2>/dev/null; then
            local decrypted
            decrypted=$(base64 -d < "$secret_file" 2>/dev/null)
            echo -e "  \033[0;32m✓\033[0m $decrypted\n"
        else
            echo -e "  \033[0;31m✗\033[0m Authentication failed\n"
            return 1
        fi
        return 0
    fi

    # Prompt for decryption password
    echo ""
    local password
    printf "  🔐 Enter decryption password: "
    read -r -s password
    echo ""

    if [ -z "$password" ]; then
        echo -e "  \033[0;31m✗\033[0m Password cannot be empty\n"
        return 1
    fi

    local decrypted
    if decrypted=$(openssl enc -aes-256-cbc -pbkdf2 -d -salt -pass "pass:${password}" -in "$secret_file" 2>/dev/null); then
        # Try to copy to clipboard, verify it actually worked before claiming success
        local copied=false
        if command -v pbcopy >/dev/null 2>&1; then
            if printf '%s' "$decrypted" | pbcopy 2>/dev/null; then
                copied=true
            fi
        elif command -v xclip >/dev/null 2>&1; then
            if printf '%s' "$decrypted" | xclip -selection clipboard 2>/dev/null; then
                copied=true
            fi
        elif command -v xsel >/dev/null 2>&1; then
            if printf '%s' "$decrypted" | xsel --clipboard 2>/dev/null; then
                copied=true
            fi
        fi

        if [ "$copied" = true ]; then
            echo -e "  \033[0;32m✓\033[0m Secret '\033[1m$name\033[0m' copied to clipboard\n"
        else
            echo -e "  \033[0;32m✓\033[0m $decrypted\n"
        fi
    else
        echo -e "  \033[0;31m✗\033[0m Decryption failed (wrong password?)\n"
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
        local sname enc_type
        while IFS= read -r -d '' f; do
            if [ -f "$f" ]; then
                sname=$(basename "$f" .enc)
                enc_type="encrypted"
                if _secret_is_legacy "$f"; then
                    enc_type="legacy-base64"
                fi
                echo -e "    \033[0;36m●\033[0m $sname \033[2m($enc_type)\033[0m"
                found=1
            fi
        done < <(find "$SECRETS_DIR" -maxdepth 1 -name "*.enc" -print0 2>/dev/null)
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

    _secret_validate_name "$name" || return 1

    local secret_file="$SECRETS_DIR/${name}.enc"

    if [ ! -f "$secret_file" ]; then
        echo -e "\n  \033[0;31m✗\033[0m Secret '$name' not found\n"
        return 1
    fi

    echo -e "\n  \033[0;33m🔐 \033[0mAuthentication required to remove '\033[1m$name\033[0m'"
    if sudo -v 2>/dev/null; then
        # Overwrite before deleting for secure removal
        if command -v shred >/dev/null 2>&1; then
            shred -fuz "$secret_file" 2>/dev/null
        else
            dd if=/dev/urandom of="$secret_file" bs=1 count=256 conv=notrunc 2>/dev/null
            rm -f "$secret_file"
        fi
        echo -e "  \033[0;32m✓\033[0m Secret '$name' securely removed\n"
    else
        echo -e "  \033[0;31m✗\033[0m Authentication failed\n"
        return 1
    fi
}

# Convenience aliases
alias-token() {
    alias-secret-get "cloudflare-token"
}

# Command not found handler - shows help directly
alias-secret() {
    alias-secrets
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
    echo -e "      Encrypt and store a secret (AES-256-CBC)"
    echo ""
    echo -e "  ${MAGENTA}alias-secret-get${NC} ${DIM}<name>${NC}"
    echo -e "      Decrypt and retrieve secret ${DIM}(copies to clipboard if available)${NC}"
    echo ""
    echo -e "  ${MAGENTA}alias-secret-list${NC}"
    echo -e "      List all stored secret names"
    echo ""
    echo -e "  ${MAGENTA}alias-secret-remove${NC} ${DIM}<name>${NC}"
    echo -e "      Securely delete a secret ${DIM}(requires sudo)${NC}"
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
