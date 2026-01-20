#!/bin/bash
# Hyber Alias Loader - v1.1.0

REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
ALIAS_HOME="${HOME}/.alias"
export ALIAS_VERSION="1.1.0"

# Source environment
# shellcheck source=/dev/null
[ -f "$ALIAS_HOME/env.sh" ] && source "$ALIAS_HOME/env.sh"

# Self-update loader (runs in background to not slow down shell startup)
_alias_self_update() {
    (
        local loader_url="$REPO/load.sh"
        local loader_tmp="$ALIAS_HOME/load.sh.tmp"
        if curl -s --connect-timeout 3 --max-time 5 "$loader_url" -o "$loader_tmp" 2>/dev/null && [ -s "$loader_tmp" ]; then
            # Only update if content is different
            if ! cmp -s "$loader_tmp" "$ALIAS_HOME/load.sh" 2>/dev/null; then
                mv "$loader_tmp" "$ALIAS_HOME/load.sh" 2>/dev/null && chmod +x "$ALIAS_HOME/load.sh"
            else
                rm -f "$loader_tmp" 2>/dev/null
            fi
        else
            rm -f "$loader_tmp" 2>/dev/null
        fi
    ) &
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
    cat << 'EOF'
Hyber Alias
===============================================================================

Available Categories (type alias-<category> for details):

  alias-git      Git commands (ga, gc, gs, gph, gpl...)
  alias-k8s      Kubernetes commands (k, ka, kgp, kgs...)
  alias-system   System commands (ll, la, cls, reload...)
  alias-secrets  Secure token storage (password protected)

Custom Alias Management:

  alias-add <category> <name> <command>   Add alias to category
  alias-remove <category> <name>          Remove alias from category
  alias-list                              List all custom categories
  alias-help                              Show this help

Secure Token Storage:

  alias-secret-add <name> <value>         Store token (password protected)
  alias-secret-get <name>                 Retrieve token (requires password)
  alias-token                             Shortcut for cloudflare-token

Example:
  alias-add ai claudex "claude --dangerously-skip-permissions"
  alias-secret-add cloudflare-token "your-token"
  alias-token  # Requires password to view

Tip: Type 'alias-' then press TAB for autocomplete

===============================================================================
EOF
}
