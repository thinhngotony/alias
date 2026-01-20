#!/bin/bash
set -e

# =============================================================================
# Hyber Alias Installer v1.1.0
# Cross-platform shell alias manager
# https://github.com/thinhngotony/alias
# =============================================================================

VERSION="1.1.0"
REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
ALIAS_HOME="$HOME/.alias"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Symbols
CHECK="${GREEN}✓${NC}"
ARROW="${CYAN}→${NC}"

# =============================================================================
# Detection
# =============================================================================

detect_os() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "linux"
    fi
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

# Download files
curl -sfS "$REPO/load.sh" -o "$ALIAS_HOME/load.sh" 2>/dev/null || { echo -e "  ${RED}✗${NC} Failed to download loader"; exit 1; }
chmod +x "$ALIAS_HOME/load.sh"
curl -sfS "$REPO/aliases/git.sh" -o "$ALIAS_HOME/cache/git.sh" 2>/dev/null || true
curl -sfS "$REPO/aliases/k8s.sh" -o "$ALIAS_HOME/cache/k8s.sh" 2>/dev/null || true
curl -sfS "$REPO/aliases/system.sh" -o "$ALIAS_HOME/cache/system.sh" 2>/dev/null || true
echo -e "  ${CHECK} Downloaded aliases"

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
export HYBER_ENV="${ENV:-dev}"
export HYBER_SHELL="$SHELL_TYPE"
export HYBER_OS="$OS"
export HYBER_VERSION="$VERSION"
EOF
echo -e "  ${CHECK} Saved environment"

echo ""

# Success
echo -e "${GREEN}${BOLD}Installation complete${NC}"
echo ""
echo -e "${DIM}Next steps${NC}"
echo ""
echo -e "  ${ARROW} Run this command to activate aliases:"
echo ""
echo -e "      ${BOLD}source ${SHELL_RC}${NC}"
echo ""
echo -e "  ${ARROW} Or open a new terminal window"
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

# Optional telemetry (silent, non-blocking)
(curl -s -X POST "https://alias.hyberorbit.com/telemetry" \
  -d "action=install&version=$VERSION&os=$OS&shell=$SHELL_TYPE" \
  &>/dev/null &) 2>/dev/null || true
