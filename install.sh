#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Auto-detect OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    OS="windows"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    OS="linux"
fi

# Auto-detect shell (use login shell, not current shell running this script)
case "$SHELL" in
    */zsh) SHELL_TYPE="zsh" ;;
    */bash) SHELL_TYPE="bash" ;;
    */fish) SHELL_TYPE="fish" ;;
    *) SHELL_TYPE="bash" ;;
esac

# Auto-detect environment
if [ -f "/.dockerenv" ] || [ -f "/run/secrets" ] || [ -n "$KUBERNETES_SERVICE_HOST" ]; then
    ENV="prod"
elif [[ "$HOSTNAME" == *"staging"* ]] || [[ "$HOSTNAME" == *"test"* ]]; then
    ENV="staging"
else
    ENV="dev"
fi

# Set shell RC file
case $SHELL_TYPE in
    bash) SHELL_RC="$HOME/.bashrc" ;;
    zsh) SHELL_RC="$HOME/.zshrc" ;;
    fish) SHELL_RC="$HOME/.config/fish/config.fish"; mkdir -p "$HOME/.config/fish" ;;
    *) SHELL_RC="$HOME/.bashrc" ;;
esac

# Print header
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Hyber Alias Auto-Install          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo "🔍 Auto-detected:"
echo "   OS: $OS | Shell: $SHELL_TYPE | Env: $ENV"
echo ""

# Create directories
mkdir -p ~/.alias/custom

# Download loader and aliases
echo -e "${YELLOW}⬇️  Downloading...${NC}"
REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
mkdir -p ~/.alias/cache

# Download loader
curl -s "$REPO/load.sh" -o ~/.alias/load.sh 2>/dev/null
chmod +x ~/.alias/load.sh

# Pre-download aliases to cache (so first shell load is instant)
curl -s "$REPO/aliases/git.sh" -o ~/.alias/cache/git.sh 2>/dev/null
curl -s "$REPO/aliases/k8s.sh" -o ~/.alias/cache/k8s.sh 2>/dev/null
curl -s "$REPO/aliases/system.sh" -o ~/.alias/cache/system.sh 2>/dev/null

echo -e "${GREEN}✓ Downloaded${NC}"
echo ""

# Add to shell RC if not already there
echo -e "${YELLOW}🔗 Configuring shell...${NC}"
if ! grep -q "/.alias/load.sh" "$SHELL_RC" 2>/dev/null; then
    {
        echo ""
        echo "# Hyber Alias"
        echo "source ~/.alias/load.sh"
    } >> "$SHELL_RC"
    echo -e "${GREEN}✓ Added to $SHELL_RC${NC}"
else
    echo -e "${GREEN}✓ Already configured${NC}"
fi

# Save environment
cat > ~/.alias/env.sh << EOF
export HYBER_ENV="$ENV"
export HYBER_SHELL="$SHELL_TYPE"
export HYBER_OS="$OS"
EOF

echo ""

# Done
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         ✨ Installation Complete!       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}To activate aliases, run:${NC}"
echo ""
echo "  source $SHELL_RC"
echo ""
echo "Or open a new terminal window."
echo ""
echo "Try it:"
echo "  alias-help  # Show all categories"
echo "  ga .        # git add ."
echo "  k get po    # kubectl get pods"
echo ""

# Optional telemetry
curl -s -X POST "https://alias.hyberorbit.com/telemetry" \
  -d "action=install&user=$(whoami)&host=$(hostname)&env=$ENV&shell=$SHELL_TYPE&os=$OS" \
  &>/dev/null &
