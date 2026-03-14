#!/usr/bin/env fish
# =============================================================================
# Hyber Alias Installer - Fish Shell
# =============================================================================

set REPO "https://raw.githubusercontent.com/thinhngotony/alias/main"
set ALIAS_HOME "$HOME/.alias"

# Fetch latest version from GitHub releases
set VERSION (curl -sfS "https://api.github.com/repos/thinhngotony/alias/releases/latest" 2>/dev/null \
    | grep '"tag_name"' | head -1 | sed 's/.*"tag_name" *: *"//;s/".*//' | sed 's/^v//')
if test -z "$VERSION"
    set VERSION "latest"
end

# Header
echo ""
echo "                       ⚡ Hyber Alias v$VERSION"
echo "                Cross-platform shell alias manager"
echo ""
echo "  ────────────────────────────────────────────────────────────────"
echo ""
echo "  System"
echo "      OS         "(uname -s)
echo "      Shell      fish"
echo "      Config     ~/.config/fish/config.fish"
echo ""
echo "  ────────────────────────────────────────────────────────────────"
echo ""
echo "  Installing"
echo ""

# Create directories
mkdir -p $ALIAS_HOME
mkdir -p ~/.config/fish/conf.d
echo "      ✓ Created directories"

# Download fish aliases
curl -sfS "$REPO/aliases/fish.fish" -o ~/.config/fish/conf.d/hyber-alias.fish 2>/dev/null
or begin
    echo "      ✗ Failed to download"
    exit 1
end
echo "      ✓ Downloaded aliases"

# Save environment
echo "set -gx HYBER_VERSION \"$VERSION\"" > $ALIAS_HOME/env.fish
echo "set -gx HYBER_SHELL \"fish\"" >> $ALIAS_HOME/env.fish
echo "      ✓ Saved environment"

echo ""
echo "  ────────────────────────────────────────────────────────────────"
echo ""
echo "  ✓ Installation complete"
echo ""
echo "  Quick start"
echo ""
echo "      alias-help     Show all available aliases"
echo "      alias-git      Git shortcuts"
echo "      alias-k8s      Kubernetes shortcuts"
echo ""
echo "  📚 Docs  https://github.com/thinhngotony/alias"
echo ""

# Reload
source ~/.config/fish/conf.d/hyber-alias.fish
