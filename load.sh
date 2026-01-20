#!/bin/bash
# Hyber Alias Loader - v1.1.0

REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
ALIAS_HOME="${HOME}/.alias"
export ALIAS_VERSION="1.1.0"

# Source environment
# shellcheck source=/dev/null
[ -f "$ALIAS_HOME/env.sh" ] && source "$ALIAS_HOME/env.sh"

# Self-update loader (runs in background, completely silent)
_alias_self_update() {
    # Use nohup with full redirection to avoid any job control messages
    (nohup sh -c '
        REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
        ALIAS_HOME="$HOME/.alias"
        loader_tmp="$ALIAS_HOME/load.sh.tmp"
        if curl -s --connect-timeout 3 --max-time 5 "$REPO/load.sh" -o "$loader_tmp" 2>/dev/null && [ -s "$loader_tmp" ]; then
            if ! cmp -s "$loader_tmp" "$ALIAS_HOME/load.sh" 2>/dev/null; then
                mv "$loader_tmp" "$ALIAS_HOME/load.sh" 2>/dev/null
                chmod +x "$ALIAS_HOME/load.sh" 2>/dev/null
            else
                rm -f "$loader_tmp" 2>/dev/null
            fi
        else
            rm -f "$loader_tmp" 2>/dev/null
        fi
    ' >/dev/null 2>&1 &)
}

# Run self-update in background
_alias_self_update

# Download and cache aliases if online, then source from cache
_alias_download() {
    local name=$1
    local url="$REPO/aliases/${name}.sh"
    local cache="$ALIAS_HOME/cache/${name}.sh"

    mkdir -p "$ALIAS_HOME/cache"

    # Try to download (with 5 second timeout)
    if curl -s --connect-timeout 5 --max-time 5 "$url" -o "$cache.tmp" 2>/dev/null && [ -s "$cache.tmp" ]; then
        mv "$cache.tmp" "$cache" 2>/dev/null || true
    else
        rm -f "$cache.tmp" 2>/dev/null || true
    fi

    # Source from cache if exists
    # shellcheck source=/dev/null
    [ -f "$cache" ] && source "$cache"
}

# Load default aliases
_alias_download "git"
_alias_download "k8s"
_alias_download "system"
_alias_download "secrets"

# Source user custom aliases (handle empty directory for zsh compatibility)
if [ -d "$ALIAS_HOME/custom" ] && [ -n "$(ls -A "$ALIAS_HOME/custom" 2>/dev/null)" ]; then
    for file in "$ALIAS_HOME/custom"/*; do
        # shellcheck source=/dev/null
        [ -f "$file" ] && source "$file" 2>/dev/null
    done
fi

# =============================================================================
# Custom Category Management
# =============================================================================

# Add alias to a category: alias-add <category> <alias-name> <command>
# Example: alias-add ai claudex "claude --dangerously-skip-permissions"
alias-add() {
    local category="$1"
    local alias_name="$2"
    shift 2
    local command="$*"

    if [ -z "$category" ] || [ -z "$alias_name" ] || [ -z "$command" ]; then
        echo "Usage: alias-add <category> <alias-name> <command>"
        echo "Example: alias-add ai claudex \"claude --dangerously-skip-permissions\""
        return 1
    fi

    local category_file="$ALIAS_HOME/custom/${category}.sh"
    mkdir -p "$ALIAS_HOME/custom"

    # Check if alias already exists in this category
    if [ -f "$category_file" ] && grep -q "^alias ${alias_name}=" "$category_file" 2>/dev/null; then
        echo "Alias '$alias_name' already exists in category '$category'. Use alias-remove first."
        return 1
    fi

    # Create category file if not exists, with header and help function
    if [ ! -f "$category_file" ]; then
        cat > "$category_file" << EOF
#!/bin/bash
# =============================================================================
# Custom Category: $category
# =============================================================================

# ALIASES_START

# ALIASES_END

# =============================================================================
# Help Function
# =============================================================================

alias-$category() {
    cat << 'HELP'
$category Aliases (Custom)
===============================================================================
HELP
    # Dynamic help from aliases
    grep "^alias " "$ALIAS_HOME/custom/${category}.sh" 2>/dev/null | while read -r line; do
        alias_def=\$(echo "\$line" | sed "s/^alias //" | sed "s/='/ -> '/" | sed "s/'\$/'/")
        printf "  %-12s %s\n" "\$(echo "\$alias_def" | cut -d' ' -f1)" "\$(echo "\$alias_def" | cut -d' ' -f2-)"
    done
    echo "==============================================================================="
}
EOF
    fi

    # Add alias to category file (before ALIASES_END marker)
    sed -i "/^# ALIASES_END/i alias ${alias_name}='${command}'" "$category_file"

    # Source the updated file
    # shellcheck source=/dev/null
    source "$category_file"

    echo "Added alias '$alias_name' -> '$command' to category '$category'"
    echo "Run 'alias-$category' to see all aliases in this category"
}

# Remove alias from a category: alias-remove <category> <alias-name>
alias-remove() {
    local category="$1"
    local alias_name="$2"

    if [ -z "$category" ] || [ -z "$alias_name" ]; then
        echo "Usage: alias-remove <category> <alias-name>"
        return 1
    fi

    local category_file="$ALIAS_HOME/custom/${category}.sh"

    if [ ! -f "$category_file" ]; then
        echo "Category '$category' not found"
        return 1
    fi

    if ! grep -q "^alias ${alias_name}=" "$category_file" 2>/dev/null; then
        echo "Alias '$alias_name' not found in category '$category'"
        return 1
    fi

    # Remove the alias line
    sed -i "/^alias ${alias_name}=/d" "$category_file"

    # Unset the alias
    unalias "$alias_name" 2>/dev/null || true

    echo "Removed alias '$alias_name' from category '$category'"
}

# List all custom categories: alias-list
alias-list() {
    echo "Custom Categories:"
    echo "==============================================================================="
    if [ -d "$ALIAS_HOME/custom" ] && [ -n "$(ls -A "$ALIAS_HOME/custom" 2>/dev/null)" ]; then
        for file in "$ALIAS_HOME/custom"/*.sh; do
            if [ -f "$file" ]; then
                local cat_name
                cat_name=$(basename "$file" .sh)
                local count
                count=$(grep -c "^alias " "$file" 2>/dev/null || echo 0)
                printf "  alias-%-10s %d alias(es)\n" "$cat_name" "$count"
            fi
        done
    else
        echo "  No custom categories. Create one with: alias-add <category> <name> <cmd>"
    fi
    echo "==============================================================================="
}

# =============================================================================
# Master Help Function
# =============================================================================

alias-help() {
    local BOLD='\033[1m'
    local DIM='\033[2m'
    local CYAN='\033[0;36m'
    local GREEN='\033[0;32m'
    local MAGENTA='\033[0;35m'
    local YELLOW='\033[0;33m'
    local NC='\033[0m'
    
    echo ""
    echo -e "                       ${BOLD}⚡ Hyber Alias${NC} ${DIM}v${ALIAS_VERSION:-1.1.0}${NC}"
    echo -e "                ${DIM}Cross-platform shell alias manager${NC}"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}📁 Categories${NC}"
    echo ""
    echo -e "      ${CYAN}alias-git${NC}        ${DIM}Git commands (ga, gc, gs, gph...)${NC}"
    echo -e "      ${CYAN}alias-k8s${NC}        ${DIM}Kubernetes (k, kgp, kgs, kl...)${NC}"
    echo -e "      ${CYAN}alias-system${NC}     ${DIM}System (ll, la, cls, reload...)${NC}"
    echo -e "      ${CYAN}alias-secrets${NC}    ${DIM}Secure token storage${NC}"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}✨ Custom Aliases${NC}"
    echo ""
    echo -e "      ${GREEN}alias-add${NC} ${DIM}<category> <name> <command>${NC}"
    echo -e "      ${GREEN}alias-remove${NC} ${DIM}<category> <name>${NC}"
    echo -e "      ${GREEN}alias-list${NC}"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}🔐 Secure Storage${NC}"
    echo ""
    echo -e "      ${MAGENTA}alias-secret-add${NC} ${DIM}<name> <value>${NC}"
    echo -e "      ${MAGENTA}alias-secret-get${NC} ${DIM}<name>${NC}"
    echo -e "      ${MAGENTA}alias-secret-list${NC}"
    echo -e "      ${MAGENTA}alias-secret-remove${NC} ${DIM}<name>${NC}"
    echo -e "      ${YELLOW}alias-token${NC}  ${DIM}→ get cloudflare-token${NC}"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}💡 Examples${NC}"
    echo ""
    echo -e "      ${DIM}\$${NC} alias-add ai claudex \"claude --dangerously-skip-permissions\""
    echo -e "      ${DIM}\$${NC} alias-secret-add cloudflare-token \"your-token\""
    echo -e "      ${DIM}\$${NC} alias-token"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${DIM}📚 Docs${NC}  https://github.com/thinhngotony/alias"
    echo -e "  ${DIM}💡 Tip${NC}   Type ${CYAN}alias-${NC} + ${BOLD}TAB${NC} for autocomplete"
    echo ""
}

# =============================================================================
# Command Suggestion Handlers
# =============================================================================

alias-() {
    echo -e "\n  \033[0;33m⚠\033[0m  Incomplete command. Available commands:\n"
    echo -e "      \033[0;36malias-help\033[0m       \033[2mShow all commands\033[0m"
    echo -e "      \033[0;36malias-git\033[0m        \033[2mGit aliases\033[0m"
    echo -e "      \033[0;36malias-k8s\033[0m        \033[2mKubernetes aliases\033[0m"
    echo -e "      \033[0;36malias-system\033[0m     \033[2mSystem aliases\033[0m"
    echo -e "      \033[0;36malias-secrets\033[0m    \033[2mSecrets management\033[0m"
    echo -e "      \033[0;36malias-add\033[0m        \033[2mAdd custom alias\033[0m"
    echo -e "      \033[0;36malias-list\033[0m       \033[2mList custom categories\033[0m"
    echo ""
}

alias-a() {
    echo -e "\n  \033[0;33m⚠\033[0m  Command '\033[1malias-a\033[0m' not found. Did you mean:\n"
    echo -e "      \033[0;36malias-add\033[0m        \033[2mAdd custom alias\033[0m"
    echo ""
}

alias-s() {
    echo -e "\n  \033[0;33m⚠\033[0m  Command '\033[1malias-s\033[0m' not found. Did you mean:\n"
    echo -e "      \033[0;36malias-system\033[0m     \033[2mSystem aliases\033[0m"
    echo -e "      \033[0;36malias-secrets\033[0m    \033[2mSecrets management\033[0m"
    echo -e "      \033[0;36malias-secret-add\033[0m \033[2mStore a secret\033[0m"
    echo -e "      \033[0;36malias-secret-get\033[0m \033[2mRetrieve a secret\033[0m"
    echo ""
}

alias-g() {
    echo -e "\n  \033[0;33m⚠\033[0m  Command '\033[1malias-g\033[0m' not found. Did you mean:\n"
    echo -e "      \033[0;36malias-git\033[0m        \033[2mGit aliases\033[0m"
    echo ""
}

alias-k() {
    echo -e "\n  \033[0;33m⚠\033[0m  Command '\033[1malias-k\033[0m' not found. Did you mean:\n"
    echo -e "      \033[0;36malias-k8s\033[0m        \033[2mKubernetes aliases\033[0m"
    echo ""
}

alias-t() {
    echo -e "\n  \033[0;33m⚠\033[0m  Command '\033[1malias-t\033[0m' not found. Did you mean:\n"
    echo -e "      \033[0;36malias-token\033[0m      \033[2mGet cloudflare-token\033[0m"
    echo ""
}

alias-r() {
    echo -e "\n  \033[0;33m⚠\033[0m  Command '\033[1malias-r\033[0m' not found. Did you mean:\n"
    echo -e "      \033[0;36malias-remove\033[0m     \033[2mRemove custom alias\033[0m"
    echo ""
}

alias-l() {
    echo -e "\n  \033[0;33m⚠\033[0m  Command '\033[1malias-l\033[0m' not found. Did you mean:\n"
    echo -e "      \033[0;36malias-list\033[0m       \033[2mList custom categories\033[0m"
    echo ""
}
