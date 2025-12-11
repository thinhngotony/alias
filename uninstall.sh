#!/bin/bash
# Hyber Alias Uninstaller

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${YELLOW}Uninstalling Hyber Alias...${NC}"
echo ""

# Remove alias directory
if [ -d "$HOME/.alias" ]; then
    rm -rf "$HOME/.alias"
    echo -e "${GREEN}✓ Removed ~/.alias${NC}"
else
    echo -e "${YELLOW}~ ~/.alias not found (already removed?)${NC}"
fi

# Remove from .bashrc
if [ -f "$HOME/.bashrc" ]; then
    if grep -q "\.alias/load\.sh" "$HOME/.bashrc" 2>/dev/null; then
        sed -i '/# Hyber/d' "$HOME/.bashrc"
        sed -i '/\.alias\/load\.sh/d' "$HOME/.bashrc"
        echo -e "${GREEN}✓ Removed from ~/.bashrc${NC}"
    fi
fi

# Remove from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    if grep -q "\.alias/load\.sh" "$HOME/.zshrc" 2>/dev/null; then
        sed -i '/# Hyber/d' "$HOME/.zshrc"
        sed -i '/\.alias\/load\.sh/d' "$HOME/.zshrc"
        echo -e "${GREEN}✓ Removed from ~/.zshrc${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Uninstall complete!${NC}"
echo "Open a new terminal to apply changes."
echo ""
