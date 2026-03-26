#!/bin/bash
set -e

# =============================================================================
# Hyber Alias Installer
# Cross-platform shell alias manager
# https://github.com/thinhngotony/alias
# =============================================================================

ALIAS_HOME="$HOME/.alias"

# Fetch latest version from GitHub releases
VERSION=$(curl -sfS "https://api.github.com/repos/thinhngotony/alias/releases/latest" 2>/dev/null \
    | grep '"tag_name"' | head -1 | sed 's/.*"tag_name" *: *"//;s/".*//' | sed 's/^v//')

# Validate version is semver-like (digits and dots only)
if ! printf '%s' "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+'; then
    VERSION="latest"
fi

# Use tag-based URL for immutable CDN content (no stale cache issues)
# Fall back to main branch if version detection failed
if [ "$VERSION" != "latest" ]; then
    REPO="https://raw.githubusercontent.com/thinhngotony/alias/v${VERSION}"
else
    REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Symbols
CHECK="${GREEN}✓${NC}"

# =============================================================================
# Detection
# =============================================================================

detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "linux" ;;
    esac
}

# Detect the user's ACTIVE shell by walking the process tree.
# When run via 'curl | sh' or 'bash install.sh', PPID may not directly
# point to the interactive shell, so we walk ancestors.
detect_active_shell() {
    local pid=$PPID
    local depth=0
    while [ "$pid" -gt 1 ] && [ "$depth" -lt 10 ]; do
        local comm=""
        if [ -f "/proc/$pid/comm" ]; then
            comm=$(cat "/proc/$pid/comm" 2>/dev/null)
        elif command -v ps >/dev/null 2>&1; then
            comm=$(ps -p "$pid" -o comm= 2>/dev/null)
        fi

        case "$comm" in
            fish) echo "fish"; return ;;
            zsh)  echo "zsh";  return ;;
            bash) echo "bash"; return ;;
        esac

        # Move to parent
        if [ -f "/proc/$pid/stat" ]; then
            pid=$(awk '{print $4}' "/proc/$pid/stat" 2>/dev/null || echo 1)
        elif command -v ps >/dev/null 2>&1; then
            pid=$(ps -p "$pid" -o ppid= 2>/dev/null | tr -d ' ')
            [ -z "$pid" ] && pid=1
        else
            break
        fi
        depth=$((depth + 1))
    done

    # Fallback: $SHELL
    case "$SHELL" in
        */zsh)  echo "zsh" ;;
        */fish) echo "fish" ;;
        */bash) echo "bash" ;;
        *)      echo "bash" ;;
    esac
}

# =============================================================================
# Main
# =============================================================================

OS=$(detect_os)
SHELL_TYPE=$(detect_active_shell)
DOWNLOAD_FAILURES=0

# Detect available shells
HAS_BASH=false
HAS_ZSH=false
HAS_FISH=false
command -v bash >/dev/null 2>&1 && HAS_BASH=true
command -v zsh  >/dev/null 2>&1 && HAS_ZSH=true
command -v fish >/dev/null 2>&1 && HAS_FISH=true

# Header
echo ""
echo -e "${BOLD}Hyber Alias${NC} ${DIM}v${VERSION}${NC}"
echo -e "${DIM}Cross-platform shell alias manager${NC}"
echo ""

# System info
echo -e "${DIM}System${NC}"
echo -e "  OS         ${BOLD}${OS}${NC}"
echo -e "  Shell      ${BOLD}${SHELL_TYPE}${NC}"
echo ""

# Install
echo -e "${DIM}Installing${NC}"

# Create directories
mkdir -p "$ALIAS_HOME/cache" "$ALIAS_HOME/custom"
echo -e "  ${CHECK} Created ${DIM}~/.alias${NC}"

# Safe download helper
_safe_download() {
    local url="$1"
    local dest="$2"
    local label="$3"
    local required="${4:-false}"

    local dest_dir
    dest_dir=$(dirname "$dest")
    local tmp
    tmp=$(mktemp "$dest_dir/.download.XXXXXX") || {
        if [ "$required" = "true" ]; then
            echo -e "  ${RED}✗${NC} Failed to create temp file for $label"
            return 1
        fi
        DOWNLOAD_FAILURES=$((DOWNLOAD_FAILURES + 1))
        return 1
    }

    if curl -sfS "${url}" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
        mv "$tmp" "$dest" 2>/dev/null
        return 0
    else
        rm -f "$tmp" 2>/dev/null
        if [ "$required" = "true" ]; then
            echo -e "  ${RED}✗${NC} Failed to download $label"
            return 1
        fi
        DOWNLOAD_FAILURES=$((DOWNLOAD_FAILURES + 1))
        echo -e "  ${YELLOW}⚠${NC}  Failed to download $label (non-critical)"
        return 1
    fi
}

# Download bash/zsh loader + aliases
if [ "$HAS_BASH" = true ] || [ "$HAS_ZSH" = true ]; then
    if ! _safe_download "$REPO/load.sh" "$ALIAS_HOME/load.sh" "loader" "true"; then
        exit 1
    fi
    chmod +x "$ALIAS_HOME/load.sh"

    _safe_download "$REPO/aliases/git.sh" "$ALIAS_HOME/cache/git.sh" "git aliases"
    _safe_download "$REPO/aliases/k8s.sh" "$ALIAS_HOME/cache/k8s.sh" "k8s aliases"
    _safe_download "$REPO/aliases/system.sh" "$ALIAS_HOME/cache/system.sh" "system aliases"
    _safe_download "$REPO/aliases/secrets.sh" "$ALIAS_HOME/cache/secrets.sh" "secrets aliases"
    _safe_download "$REPO/aliases/ai.sh" "$ALIAS_HOME/cache/ai.sh" "ai aliases"

    if [ "$DOWNLOAD_FAILURES" -gt 0 ]; then
        echo -e "  ${YELLOW}⚠${NC}  Downloaded aliases ($DOWNLOAD_FAILURES file(s) failed, will retry on next shell start)"
    else
        echo -e "  ${CHECK} Downloaded aliases"
    fi
fi

# Configure bash
if [ "$HAS_BASH" = true ] && [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "/.alias/load.sh" "$HOME/.bashrc" 2>/dev/null; then
        {
            echo ""
            echo "# Hyber Alias - https://github.com/thinhngotony/alias"
            echo "[ -f ~/.alias/load.sh ] && source ~/.alias/load.sh"
        } >> "$HOME/.bashrc"
        echo -e "  ${CHECK} Configured ${DIM}~/.bashrc${NC}"
    else
        echo -e "  ${CHECK} Already configured ${DIM}~/.bashrc${NC}"
    fi
fi

# Configure zsh
if [ "$HAS_ZSH" = true ] && [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "/.alias/load.sh" "$HOME/.zshrc" 2>/dev/null; then
        {
            echo ""
            echo "# Hyber Alias - https://github.com/thinhngotony/alias"
            echo "[ -f ~/.alias/load.sh ] && source ~/.alias/load.sh"
        } >> "$HOME/.zshrc"
        echo -e "  ${CHECK} Configured ${DIM}~/.zshrc${NC}"
    else
        echo -e "  ${CHECK} Already configured ${DIM}~/.zshrc${NC}"
    fi
fi

# Configure fish
if [ "$HAS_FISH" = true ]; then
    mkdir -p "$HOME/.config/fish/conf.d"
    if _safe_download "$REPO/aliases/fish.fish" "$HOME/.config/fish/conf.d/hyper-alias.fish" "fish aliases"; then
        echo -e "  ${CHECK} Configured ${DIM}fish (conf.d)${NC}"
    fi
fi

# Save environment
cat > "$ALIAS_HOME/env.sh" << EOF
export HYBER_VERSION="${VERSION}"
export HYBER_SHELL="${SHELL_TYPE}"
export HYBER_OS="${OS}"
EOF
chmod 600 "$ALIAS_HOME/env.sh"
echo -e "  ${CHECK} Saved environment"

echo ""

# Success
echo -e "${GREEN}${BOLD}Installation complete${NC}"
echo ""
echo -e "${DIM}Quick start${NC}"
echo ""
echo -e "  ${CYAN}alias-help${NC}     Show all available aliases"
echo -e "  ${CYAN}alias-git${NC}      Git shortcuts (ga, gc, gs, gph...)"
echo -e "  ${CYAN}alias-k8s${NC}      Kubernetes shortcuts (k, kgp, kgs...)"
echo -e "  ${CYAN}alias-add${NC}      Add custom aliases to categories"
echo ""
echo -e "${DIM}Documentation${NC}  https://github.com/thinhngotony/alias"
echo ""

# Print activation for ALL configured shells
echo -e "${BOLD}Activate aliases${NC}"
echo ""

_printed=0
if [ "$HAS_FISH" = true ]; then
    if [ "$SHELL_TYPE" = "fish" ]; then
        echo -e "  Run: ${CYAN}source ~/.config/fish/conf.d/hyper-alias.fish${NC}  ${GREEN}← your shell${NC}"
    else
        echo -e "  fish:  ${DIM}source ~/.config/fish/conf.d/hyper-alias.fish${NC}"
    fi
    _printed=1
fi
if [ "$HAS_BASH" = true ] && [ -f "$HOME/.bashrc" ]; then
    if [ "$SHELL_TYPE" = "bash" ]; then
        echo -e "  Run: ${CYAN}source ~/.bashrc${NC}  ${GREEN}← your shell${NC}"
    else
        echo -e "  bash:  ${DIM}source ~/.bashrc${NC}"
    fi
    _printed=1
fi
if [ "$HAS_ZSH" = true ] && [ -f "$HOME/.zshrc" ]; then
    if [ "$SHELL_TYPE" = "zsh" ]; then
        echo -e "  Run: ${CYAN}source ~/.zshrc${NC}  ${GREEN}← your shell${NC}"
    else
        echo -e "  zsh:   ${DIM}source ~/.zshrc${NC}"
    fi
    _printed=1
fi
if [ "$_printed" -eq 0 ]; then
    echo -e "  Run: ${CYAN}source ~/.bashrc${NC}"
fi

echo ""
echo -e "  Or open a new terminal."
echo ""
