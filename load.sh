#!/bin/bash
# Hyber Alias Loader
#
# IMPORTANT: This file is sourced (not executed) by interactive shells.
# Never use 'set -e' here — it would apply ERR_EXIT to the calling shell,
# causing it to exit on any non-zero return (even from hooks or completions).
# All functions use explicit error handling instead.

ALIAS_HOME="${HOME}/.alias"

# Allow custom repository URL for forks/self-hosting
ALIAS_REPO_URL="${ALIAS_REPO_URL:-https://raw.githubusercontent.com/thinhngotony/alias}"

# Source environment
# shellcheck source=/dev/null
[ -f "$ALIAS_HOME/env.sh" ] && source "$ALIAS_HOME/env.sh"
export ALIAS_VERSION="${HYBER_VERSION:-latest}"

# Use tag-based URL for immutable CDN content, fall back to main
if [ "$ALIAS_VERSION" != "latest" ]; then
    REPO="${ALIAS_REPO_URL}/v${ALIAS_VERSION}"
else
    REPO="${ALIAS_REPO_URL}/main"
fi
# Avoid network work on every shell startup.
_ALIAS_CACHE_TTL=300
_ALIAS_UPDATE_INTERVAL=3600


# =============================================================================
# Self-update loader (runs in background at most once per hour)
# Uses mktemp for safe temp files and mkdir-based locking to prevent races
# Set ALIAS_AUTO_UPDATE=false to disable auto-updates
# =============================================================================
_alias_file_mtime() {
    local file="$1"
    stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null
}

_alias_file_age() {
    local file="$1"
    local now mtime
    [ -f "$file" ] || return 1
    now=$(date +%s) || return 1
    mtime=$(_alias_file_mtime "$file") || return 1
    printf '%s\n' "$((now - mtime))"
}

_alias_update_check_due() {
    local marker="$ALIAS_HOME/.update-check"
    local age
    if [ ! -f "$marker" ]; then
        return 0
    fi
    age=$(_alias_file_age "$marker") || return 0
    [ "$age" -ge "$_ALIAS_UPDATE_INTERVAL" ]
}

_alias_self_update() {
    local check_lock="$ALIAS_HOME/.update-check.lock"
    local lock_age

    # Allow users to opt-out of auto-updates
    if [ "${ALIAS_AUTO_UPDATE:-true}" = "false" ]; then
        return 0
    fi

    # Rate-limit the background network check and serialize its timestamp.
    if ! _alias_update_check_due; then
        return 0
    fi
    mkdir -p "$ALIAS_HOME" 2>/dev/null || return 0

    if [ -d "$check_lock" ]; then
        if [ -f "$check_lock/pid" ]; then
            lock_age=$(_alias_file_age "$check_lock/pid") || lock_age=0
            if [ "$lock_age" -gt 120 ]; then
                rm -rf "$check_lock" 2>/dev/null
            else
                return 0
            fi
        else
            rm -rf "$check_lock" 2>/dev/null
        fi
    fi

    if ! mkdir "$check_lock" 2>/dev/null; then
        return 0
    fi
    if ! printf '%s\n' "$$" > "$check_lock/pid" 2>/dev/null; then
        rm -rf "$check_lock" 2>/dev/null
        return 0
    fi

    # Re-check after taking the lock so concurrent shells do not all spawn jobs.
    if ! _alias_update_check_due; then
        rm -rf "$check_lock" 2>/dev/null
        return 0
    fi
    if ! touch "$ALIAS_HOME/.update-check" 2>/dev/null; then
        rm -rf "$check_lock" 2>/dev/null
        return 0
    fi
    rm -rf "$check_lock" 2>/dev/null

    # Use nohup with full redirection to avoid any job control messages
    # shellcheck disable=SC2016
    (nohup sh -c '
        ALIAS_HOME="$HOME/.alias"
        ALIAS_REPO_URL="${ALIAS_REPO_URL:-https://raw.githubusercontent.com/thinhngotony/alias}"
        # Always check main branch for latest loader
        REPO="${ALIAS_REPO_URL}/main"
        LOCK_DIR="$ALIAS_HOME/.update.lock"

        # Atomic lock using mkdir (POSIX-safe)
        # Clean stale locks older than 120 seconds
        if [ -d "$LOCK_DIR" ]; then
            lock_age=0
            if [ -f "$LOCK_DIR/pid" ]; then
                # Cross-platform stat: try GNU stat first, then BSD stat (macOS)
                lock_mtime=$(stat -c %Y "$LOCK_DIR/pid" 2>/dev/null || stat -f %m "$LOCK_DIR/pid" 2>/dev/null || echo "0")
                lock_age=$(( $(date +%s) - lock_mtime ))
            fi
            if [ "$lock_age" -gt 120 ]; then
                rm -rf "$LOCK_DIR" 2>/dev/null
            else
                exit 0
            fi
        fi

        if ! mkdir "$LOCK_DIR" 2>/dev/null; then
            exit 0
        fi
        echo $$ > "$LOCK_DIR/pid" 2>/dev/null

        # Use mktemp for unpredictable temp file
        loader_tmp=$(mktemp "$ALIAS_HOME/load.sh.XXXXXX") || { rm -rf "$LOCK_DIR" 2>/dev/null; exit 1; }

        # Download with HTTPS enforcement and proper error handling
        if curl -sfS --proto "=https" --connect-timeout 3 --max-time 5 "$REPO/load.sh" -o "$loader_tmp" 2>/dev/null && [ -s "$loader_tmp" ]; then
            if ! cmp -s "$loader_tmp" "$ALIAS_HOME/load.sh" 2>/dev/null; then
                if chmod +x "$loader_tmp" 2>/dev/null && mv "$loader_tmp" "$ALIAS_HOME/load.sh" 2>/dev/null; then
                    : # Success
                else
                    rm -f "$loader_tmp" 2>/dev/null
                fi
            else
                rm -f "$loader_tmp" 2>/dev/null
            fi
        else
            rm -f "$loader_tmp" 2>/dev/null
        fi

        rm -rf "$LOCK_DIR" 2>/dev/null
    ' >/dev/null 2>&1 &)
}

# Run the self-update check in the background when its hourly interval expires.
_alias_self_update


# =============================================================================
# Download and cache aliases if online, then source from cache
# Cached alias modules are refreshed at most every five minutes.
# =============================================================================
_alias_cleanup_download_temps() {
    [ -d "$ALIAS_HOME/cache" ] || return 0
    # Remove interrupted downloads after active curl processes have timed out.
    find "$ALIAS_HOME/cache" -maxdepth 1 -type f -name '*.sh.*' -mmin +10 -exec rm -f {} + 2>/dev/null || true
}

_alias_download() {
    local name="$1"
    local url="$REPO/aliases/${name}.sh"
    local cache="$ALIAS_HOME/cache/${name}.sh"
    local now mtime

    mkdir -p "$ALIAS_HOME/cache"

    if [ -f "$cache" ]; then
        now=$(date +%s) || now=0
        mtime=$(_alias_file_mtime "$cache") || mtime=""
        if [ -n "$mtime" ] && [ "$((now - mtime))" -lt "$_ALIAS_CACHE_TTL" ]; then
            # shellcheck source=/dev/null
            source "$cache"
            return $?
        fi
    fi

    # Use mktemp for safe temp file
    local tmp
    tmp=$(mktemp "$ALIAS_HOME/cache/${name}.sh.XXXXXX") || return 1

    # Download with HTTPS enforcement
    if curl -sfS --proto '=https' --connect-timeout 5 --max-time 5 "${url}" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
        mv "$tmp" "$cache" 2>/dev/null || rm -f "$tmp" 2>/dev/null
    else
        rm -f "$tmp" 2>/dev/null
    fi

    # Source from cache if exists, including a stale copy when offline.
    # shellcheck source=/dev/null
    [ -f "$cache" ] && source "$cache"
}

_alias_cleanup_download_temps

# Load default aliases
_alias_download "git"
_alias_download "k8s"
_alias_download "system"
_alias_download "secrets"
_alias_download "ai"


# =============================================================================
# Source user custom aliases
# Only source regular .sh files (no symlinks, no directories)
# =============================================================================
if [ -d "$ALIAS_HOME/custom" ]; then
    # Use find instead of glob to avoid zsh "no matches found" error
    # when the directory exists but contains no .sh files
    while IFS= read -r -d '' file; do
        # Only source regular files (not symlinks)
        if [ -f "$file" ] && [ ! -L "$file" ]; then
            # shellcheck source=/dev/null
            source "$file" 2>/dev/null
        fi
    done < <(find "$ALIAS_HOME/custom" -maxdepth 1 -name '*.sh' -print0 2>/dev/null)
fi

# =============================================================================
# Input Validation Helpers
# =============================================================================

# Validate a name (category or alias): alphanumeric, hyphens, underscores only
_alias_validate_name() {
    local name="$1"
    local label="$2"
    if [ -z "$name" ]; then
        echo "Error: $label cannot be empty"
        return 1
    fi
    # Must be alphanumeric, hyphens, underscores; 1-64 chars
    if ! printf '%s' "$name" | grep -qE '^[a-zA-Z0-9_-]{1,64}$'; then
        echo "Error: $label must contain only letters, numbers, hyphens, and underscores (max 64 chars)"
        return 1
    fi
    # Block path traversal attempts
    case "$name" in
        *..* | */* | *\\*)
            echo "Error: $label contains invalid characters"
            return 1
            ;;
    esac
    return 0
}

# Collect exact alias definitions from cached remote and custom category files.
_alias_collect_alias_file_matches() {
    local alias_name="$1"
    local alias_type="$2"
    local directory="$3"
    local output_file="$4"
    local file category line prefix definition

    [ -d "$directory" ] || return 0
    prefix="alias ${alias_name}="
    while IFS= read -r -d '' file; do
        [ -f "$file" ] && [ ! -L "$file" ] || continue
        category=$(basename "$file" .sh)
        while IFS= read -r line; do
            case "$line" in
                "$prefix"*)
                    definition="${line#"$prefix"}"
                    printf '%s\t%s\t%s\t%s\n' "$alias_type" "$category" "$file" "$definition" >> "$output_file"
                    ;;
            esac
        done < "$file"
    done < <(find "$directory" -maxdepth 1 -type f -name '*.sh' -print0 2>/dev/null)
}

_alias_collect_alias_matches() {
    local alias_name="$1"
    local output_file="$2"
    _alias_collect_alias_file_matches "$alias_name" "System" "$ALIAS_HOME/cache" "$output_file"
    _alias_collect_alias_file_matches "$alias_name" "Custom" "$ALIAS_HOME/custom" "$output_file"
}


# =============================================================================
# Custom Category Management
# =============================================================================

# Add alias to a category: alias-add <category> <alias-name> <command>
# Example: alias-add ai claudex "claude --dangerously-skip-permissions"
alias-add() {
    local category="$1"
    local alias_name="$2"
    shift 2 2>/dev/null || true
    local command="$*"

    if [ -z "$category" ] || [ -z "$alias_name" ] || [ -z "$command" ]; then
        echo "Usage: alias-add <category> <alias-name> <command>"
        echo "Example: alias-add ai claudex \"claude --dangerously-skip-permissions\""
        return 1
    fi

    # Validate inputs
    _alias_validate_name "$category" "Category" || return 1
    _alias_validate_name "$alias_name" "Alias name" || return 1

    local category_file="$ALIAS_HOME/custom/${category}.sh"
    mkdir -p "$ALIAS_HOME/custom"

    # Check if alias already exists in this category
    if [ -f "$category_file" ] && grep -q "^alias ${alias_name}=" "$category_file" 2>/dev/null; then
        echo "Alias '$alias_name' already exists in category '$category'. Use alias-remove first."
        return 1
    fi

    # Escape single quotes in the command for safe alias definition
    local escaped_command
    escaped_command="${command//\'/\'\\\'\'}"

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

    # Safely insert alias before ALIASES_END marker using line-by-line copy
    # This avoids sed regex injection entirely
    local alias_line="alias ${alias_name}='${escaped_command}'"
    local tmpfile
    tmpfile=$(mktemp "$ALIAS_HOME/custom/.tmp.XXXXXX") || { echo "Error: failed to create temp file"; return 1; }

    while IFS= read -r line; do
        if [ "$line" = "# ALIASES_END" ]; then
            printf '%s\n' "$alias_line"
        fi
        printf '%s\n' "$line"
    done < "$category_file" > "$tmpfile"

    mv "$tmpfile" "$category_file"

    # Source the updated file
    # shellcheck source=/dev/null
    source "$category_file"

    echo "Added alias '$alias_name' -> '$command' to category '$category'"
    echo "Run 'alias-$category' to see all aliases in this category"
}

# Remove an alias definition from a cached or custom category file.
_alias_remove_alias_line() {
    local alias_name="$1"
    local category_file="$2"
    local tmpfile line
    local found=0

    tmpfile=$(mktemp "${category_file}.tmp.XXXXXX") || {
        echo "Error: failed to create temp file"
        return 1
    }

    while IFS= read -r line; do
        case "$line" in
            "alias ${alias_name}="*)
                found=1
                continue
                ;;
            *) printf '%s\n' "$line" ;;
        esac
    done < "$category_file" > "$tmpfile"

    if [ "$found" -eq 0 ]; then
        rm -f "$tmpfile" 2>/dev/null
        echo "Alias '$alias_name' not found"
        return 1
    fi
    if ! mv "$tmpfile" "$category_file" 2>/dev/null; then
        rm -f "$tmpfile" 2>/dev/null
        echo "Error: failed to update '$category_file'"
        return 1
    fi

    unalias "$alias_name" 2>/dev/null || true
}

# Remove an alias from a category, or search all categories when only a name is given.
alias-remove() {
    local category="" alias_name="" category_file="" matches="" matches_file="" record="" selected=""
    local match_type="" match_file="" definition="" selection="" display_file="" tab=""
    local count=0 index=0

    case "$#" in
        1)
            alias_name="$1"
            case "$alias_name" in
                ""|*[!a-zA-Z0-9_.-]*|*/*|*\\*)
                    echo "Error: Alias name must contain only letters, numbers, dots, hyphens, and underscores (max 64 chars)"
                    return 1
                    ;;
            esac
            echo ""
            echo "🔍 Searching for '$alias_name' across all aliases..."
            tab="$(printf '\t')"
            matches_file=$(mktemp "$ALIAS_HOME/.alias-remove.XXXXXX") || {
                echo "Error: failed to create search file"
                return 1
            }
            if ! _alias_collect_alias_matches "$alias_name" "$matches_file"; then
                rm -f "$matches_file" 2>/dev/null
                echo "Error: failed to search aliases"
                return 1
            fi
            matches=$(cat "$matches_file")
            rm -f "$matches_file" 2>/dev/null
            if [ -z "$matches" ]; then
                echo "No alias '$alias_name' found."
                return 1
            fi
            count=$(printf '%s\n' "$matches" | wc -l | tr -d '[:space:]')
            if [ "$count" -eq 1 ]; then
                echo "Found 1 match:"
            else
                echo "Found $count matches:"
            fi
            index=0
            while IFS= read -r record; do
                index=$((index + 1))
                IFS="$tab" read -r match_type category match_file definition <<< "$record"
                display_file="$match_file"
                case "$display_file" in
                    "$HOME"/*) display_file="~${display_file#"$HOME"}" ;;
                esac
                printf "  [%d] %s (%s) - %s\n" "$index" "$alias_name" "$match_type" "$definition"
                printf "      Category: %s\n" "$category"
                printf "      File: %s\n" "$display_file"
            done <<< "$matches"

            echo ""
            printf "Enter number to confirm removal (or 'q' to cancel): "
            IFS= read -r selection
            case "$selection" in
                q|Q)
                    echo "Cancelled"
                    return 0
                    ;;
                ''|*[!0-9]*)
                    echo "Invalid selection"
                    return 1
                    ;;
            esac
            if [ "$selection" -lt 1 ] || [ "$selection" -gt "$count" ]; then
                echo "Invalid selection"
                return 1
            fi

            index=0
            while IFS= read -r record; do
                index=$((index + 1))
                if [ "$index" -eq "$selection" ]; then
                    selected="$record"
                    break
                fi
            done <<< "$matches"
            IFS="$tab" read -r match_type category match_file definition <<< "$selected"
            _alias_remove_alias_line "$alias_name" "$match_file" || return 1
            if [ "$match_type" = "System" ]; then
                echo "Removed alias '$alias_name' from cached system category '$category'"
                echo "Note: it will return when that cache refreshes."
            else
                echo "Removed alias '$alias_name' from category '$category'"
            fi
            ;;
        2)
            category="$1"
            alias_name="$2"
            _alias_validate_name "$category" "Category" || return 1
            _alias_validate_name "$alias_name" "Alias name" || return 1
            category_file="$ALIAS_HOME/custom/${category}.sh"

            if [ ! -f "$category_file" ]; then
                echo "Category '$category' not found"
                return 1
            fi

            if ! grep -q "^alias ${alias_name}=" "$category_file" 2>/dev/null; then
                echo "Alias '$alias_name' not found in category '$category'"
                return 1
            fi

            _alias_remove_alias_line "$alias_name" "$category_file" || return 1
            echo "Removed alias '$alias_name' from category '$category'"
            ;;
        *)
            echo "Usage: alias-remove [category] <alias-name>"
            echo "Examples:"
            echo "  alias-remove my-alias"
            echo "  alias-remove ai my-alias"
            return 1
            ;;
    esac
}


# List all custom categories: alias-list
alias-list() {
    echo "Custom Categories:"
    echo "==============================================================================="
    local _found=0
    if [ -d "$ALIAS_HOME/custom" ]; then
        while IFS= read -r -d '' file; do
            if [ -f "$file" ] && [ ! -L "$file" ]; then
                local cat_name
                cat_name=$(basename "$file" .sh)
                local count
                count=$(grep -c "^alias " "$file" 2>/dev/null || echo 0)
                printf "  alias-%-10s %d alias(es)\n" "$cat_name" "$count"
                _found=1
            fi
        done < <(find "$ALIAS_HOME/custom" -maxdepth 1 -name '*.sh' -print0 2>/dev/null)
    fi
    if [ "$_found" -eq 0 ]; then
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
    local NC='\033[0m'

    echo ""
    echo -e "                       ${BOLD}⚡ Hyber Alias${NC} ${DIM}v${ALIAS_VERSION:-latest}${NC}"
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
    echo -e "      ${CYAN}alias-ai${NC}         ${DIM}AI coding agents (copilotx, claudex)${NC}"
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}✨ Custom Aliases${NC}"
    echo ""
    echo -e "      ${GREEN}alias-add${NC} ${DIM}<category> <name> <command>${NC}"
    echo -e "      ${GREEN}alias-remove${NC} ${DIM}[category] <name>${NC}"
    echo -e "          ${DIM}Search all aliases when category is omitted${NC}"
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
    echo ""
    echo -e "${DIM}  ────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}💡 Examples${NC}"
    echo ""
    echo -e "      ${DIM}\$${NC} alias-add ai claudex \"claude --dangerously-skip-permissions\""
    echo -e "      ${DIM}\$${NC} alias-secret-add my-token \"your-token\""
    echo -e "      ${DIM}\$${NC} alias-secret-get my-token"
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
    echo -e "      \033[0;36malias-remove\033[0m     \033[2mSearch/remove alias\033[0m"
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

alias-r() {
    echo -e "\n  \033[0;33m⚠\033[0m  Command '\033[1malias-r\033[0m' not found. Did you mean:\n"
    echo -e "      \033[0;36malias-remove\033[0m     \033[2mSearch/remove alias\033[0m"
    echo ""
}

alias-l() {
    echo -e "\n  \033[0;33m⚠\033[0m  Command '\033[1malias-l\033[0m' not found. Did you mean:\n"
    echo -e "      \033[0;36malias-list\033[0m       \033[2mList custom categories\033[0m"
    echo ""
}
