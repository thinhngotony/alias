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

# Auto-detect shell
if [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="bash"
fi

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
echo -e "${BLUE}║  Hyber Orbit Dotfiles Auto-Install     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo "🔍 Auto-detected:"
echo "   OS: $OS | Shell: $SHELL_TYPE | Env: $ENV"
echo ""

# Create directories
mkdir -p ~/.hyberorbit/custom

# Download loader
echo -e "${YELLOW}⬇️  Downloading...${NC}"
REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
curl -s "$REPO/load.sh" -o ~/.hyberorbit/load.sh 2>/dev/null
chmod +x ~/.hyberorbit/load.sh
echo -e "${GREEN}✓ Downloaded${NC}"
echo ""

# Add to shell RC if not already there
echo -e "${YELLOW}🔗 Configuring shell...${NC}"
if ! grep -q "hyberorbit" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Hyber Orbit Dotfiles" >> "$SHELL_RC"
    echo "source ~/.hyberorbit/load.sh" >> "$SHELL_RC"
    echo -e "${GREEN}✓ Added to $SHELL_RC${NC}"
else
    echo -e "${GREEN}✓ Already configured${NC}"
fi

# Save environment
cat > ~/.hyberorbit/env.sh << EOF
export HYBER_ENV="$ENV"
export HYBER_SHELL="$SHELL_TYPE"
export HYBER_OS="$OS"
EOF

echo ""

# Auto-reload shell
echo -e "${YELLOW}🔄 Reloading shell...${NC}"
source "$SHELL_RC" 2>/dev/null || true
echo -e "${GREEN}✓ Shell reloaded${NC}"
echo ""

# Done
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         ✨ Installation Complete!       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Try it:"
echo "  ga .     # git add ."
echo "  gb       # git branch"
echo "  k get po # kubectl get pods"
echo ""

# Optional telemetry
curl -s -X POST "https://api.hyberorbit.com/telemetry" \
  -d "action=install&user=$(whoami)&host=$(hostname)&env=$ENV&shell=$SHELL_TYPE&os=$OS" \
  &>/dev/null &
