#!/bin/bash
# Hyber Alias Uninstaller

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Portable sed in-place (works on both macOS and Linux)
sed_inplace() {
    if sed --version 2>/dev/null | grep -q GNU; then
        # GNU sed (Linux)
        sed -i "$@"
    else
        # BSD sed (macOS)
        sed -i '' "$@"
    fi
}

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
        sed_inplace '/# Hyber/d' "$HOME/.bashrc"
        sed_inplace '/\.alias\/load\.sh/d' "$HOME/.bashrc"
        echo -e "${GREEN}✓ Removed from ~/.bashrc${NC}"
    fi
fi

# Remove from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    if grep -q "\.alias/load\.sh" "$HOME/.zshrc" 2>/dev/null; then
        sed_inplace '/# Hyber/d' "$HOME/.zshrc"
        sed_inplace '/\.alias\/load\.sh/d' "$HOME/.zshrc"
        echo -e "${GREEN}✓ Removed from ~/.zshrc${NC}"
    fi
fi

# Remove from fish config
if [ -f "$HOME/.config/fish/conf.d/hyber-alias.fish" ]; then
    rm -f "$HOME/.config/fish/conf.d/hyber-alias.fish"
    echo -e "${GREEN}✓ Removed from fish config${NC}"
fi

echo ""
echo -e "${GREEN}✓ Uninstall complete${NC}"
echo ""
echo "Open a new terminal to apply changes."
echo ""
