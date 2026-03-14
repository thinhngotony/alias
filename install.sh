#!/bin/bash
set -e

# =============================================================================
# Hyber Alias Installer
# Cross-platform shell alias manager
# https://github.com/thinhngotony/alias
# =============================================================================

REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
ALIAS_HOME="$HOME/.alias"

# Fetch latest version from GitHub releases
VERSION=$(curl -sfS "https://api.github.com/repos/thinhngotony/alias/releases/latest" 2>/dev/null \
    | grep '"tag_name"' | head -1 | sed 's/.*"tag_name" *: *"//;s/".*//' | sed 's/^v//')

# Validate version is semver-like (digits and dots only)
if ! printf '%s' "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+'; then
    VERSION="latest"
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

detect_shell() {
    case "$SHELL" in
        */zsh) echo "zsh" ;;
        */bash) echo "bash" ;;
        */fish) echo "fish" ;;
        *) echo "bash" ;;
    esac
}

get_shell_rc() {
    case $1 in
        zsh) echo "$HOME/.zshrc" ;;
        fish) mkdir -p "$HOME/.config/fish"; echo "$HOME/.config/fish/config.fish" ;;
        *) echo "$HOME/.bashrc" ;;
    esac
}

# =============================================================================
# Main
# =============================================================================

OS=$(detect_os)
SHELL_TYPE=$(detect_shell)
SHELL_RC=$(get_shell_rc "$SHELL_TYPE")
DOWNLOAD_FAILURES=0

# Header
echo ""
echo -e "${BOLD}Hyber Alias${NC} ${DIM}v${VERSION}${NC}"
echo -e "${DIM}Cross-platform shell alias manager${NC}"
echo ""

# System info
echo -e "${DIM}System${NC}"
echo -e "  OS         ${BOLD}${OS}${NC}"
echo -e "  Shell      ${BOLD}${SHELL_TYPE}${NC}"
echo -e "  Config     ${DIM}${SHELL_RC}${NC}"
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

    if curl -sfS "$url" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
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

# Download files
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

# Configure shell
if ! grep -q "/.alias/load.sh" "$SHELL_RC" 2>/dev/null; then
    {
        echo ""
        echo "# Hyber Alias - https://github.com/thinhngotony/alias"
        echo "[ -f ~/.alias/load.sh ] && source ~/.alias/load.sh"
    } >> "$SHELL_RC"
    echo -e "  ${CHECK} Configured ${DIM}${SHELL_RC}${NC}"
else
    echo -e "  ${CHECK} Already configured"
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

# Print activation instructions (no exec to avoid breaking piped installs)
echo -e "${BOLD}Activate aliases${NC}"
echo ""
case "$SHELL_TYPE" in
    zsh)  echo -e "  Run: ${CYAN}source ~/.zshrc${NC}" ;;
    fish) echo -e "  Run: ${CYAN}source ~/.config/fish/config.fish${NC}" ;;
    *)    echo -e "  Run: ${CYAN}source ~/.bashrc${NC}" ;;
esac
echo -e "  Or open a new terminal."
echo ""
