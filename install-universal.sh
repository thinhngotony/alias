#!/bin/sh
# =============================================================================
# Hyber Alias Universal Installer v1.1.0
# Auto-detects shell and installs appropriate aliases
# Works from any shell: bash, zsh, fish, sh
# =============================================================================

VERSION="1.1.0"
REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
ALIAS_HOME="$HOME/.alias"

# Colors (POSIX compatible)
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*) echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "linux" ;;
    esac
}

# Detect user's default shell
detect_shell() {
    shell_name=$(basename "$SHELL")
    case "$shell_name" in
        zsh) echo "zsh" ;;
        fish) echo "fish" ;;
        bash) echo "bash" ;;
        *) echo "bash" ;;
    esac
}

OS=$(detect_os)
USER_SHELL=$(detect_shell)

# Header
printf "\n"
printf "                       ${BOLD}⚡ Hyber Alias${NC} ${DIM}v${VERSION}${NC}\n"
printf "                ${DIM}Cross-platform shell alias manager${NC}\n"
printf "\n"
printf "${DIM}  ────────────────────────────────────────────────────────────────${NC}\n"
printf "\n"
printf "  ${BOLD}System${NC}\n"
printf "\n"
printf "      OS         ${BOLD}%s${NC}\n" "$OS"
printf "      Shell      ${BOLD}%s${NC}\n" "$USER_SHELL"
printf "\n"
printf "${DIM}  ────────────────────────────────────────────────────────────────${NC}\n"
printf "\n"
printf "  ${BOLD}Installing${NC}\n"
printf "\n"

# Create directories
mkdir -p "$ALIAS_HOME/cache" "$ALIAS_HOME/custom"
printf "      ${GREEN}✓${NC} Created ~/.alias\n"

# Install based on detected shell
case "$USER_SHELL" in
    fish)
        # Fish shell installation
        mkdir -p "$HOME/.config/fish/conf.d"
        curl -sfS "$REPO/aliases/fish.fish" -o "$HOME/.config/fish/conf.d/hyber-alias.fish" 2>/dev/null
        if [ $? -eq 0 ]; then
            printf "      ${GREEN}✓${NC} Downloaded fish aliases\n"
        else
            printf "      ${RED}✗${NC} Failed to download\n"
            exit 1
        fi
        SHELL_RC="$HOME/.config/fish/config.fish"
        ;;
    *)
        # Bash/Zsh installation
        curl -sfS "$REPO/load.sh" -o "$ALIAS_HOME/load.sh" 2>/dev/null
        chmod +x "$ALIAS_HOME/load.sh"
        curl -sfS "$REPO/aliases/git.sh" -o "$ALIAS_HOME/cache/git.sh" 2>/dev/null || true
        curl -sfS "$REPO/aliases/k8s.sh" -o "$ALIAS_HOME/cache/k8s.sh" 2>/dev/null || true
        curl -sfS "$REPO/aliases/system.sh" -o "$ALIAS_HOME/cache/system.sh" 2>/dev/null || true
        curl -sfS "$REPO/aliases/secrets.sh" -o "$ALIAS_HOME/cache/secrets.sh" 2>/dev/null || true
        printf "      ${GREEN}✓${NC} Downloaded aliases\n"
        
        # Determine shell RC file
        case "$USER_SHELL" in
            zsh) SHELL_RC="$HOME/.zshrc" ;;
            *) SHELL_RC="$HOME/.bashrc" ;;
        esac
        
        # Add to shell RC if not already there
        if ! grep -q "/.alias/load.sh" "$SHELL_RC" 2>/dev/null; then
            printf "\n# Hyber Alias - https://github.com/thinhngotony/alias\n" >> "$SHELL_RC"
            printf "[ -f ~/.alias/load.sh ] && source ~/.alias/load.sh\n" >> "$SHELL_RC"
            printf "      ${GREEN}✓${NC} Configured ${DIM}%s${NC}\n" "$SHELL_RC"
        else
            printf "      ${GREEN}✓${NC} Already configured\n"
        fi
        ;;
esac

# Save environment
cat > "$ALIAS_HOME/env.sh" << ENVEOF
export HYBER_VERSION="$VERSION"
export HYBER_SHELL="$USER_SHELL"
export HYBER_OS="$OS"
ENVEOF
printf "      ${GREEN}✓${NC} Saved environment\n"

printf "\n"
printf "${DIM}  ────────────────────────────────────────────────────────────────${NC}\n"
printf "\n"
printf "  ${GREEN}${BOLD}✓ Installation complete${NC}\n"
printf "\n"
printf "  ${BOLD}Quick start${NC}\n"
printf "\n"
printf "      ${CYAN}alias-help${NC}     Show all available aliases\n"
printf "      ${CYAN}alias-git${NC}      Git shortcuts\n"
printf "      ${CYAN}alias-k8s${NC}      Kubernetes shortcuts\n"
printf "\n"
printf "  ${DIM}📚 Docs${NC}  https://github.com/thinhngotony/alias\n"
printf "\n"
printf "${DIM}  ────────────────────────────────────────────────────────────────${NC}\n"
printf "\n"
printf "  ${DIM}Activating aliases...${NC}\n"
printf "\n"

# Activate based on shell
case "$USER_SHELL" in
    fish)
        exec fish -l
        ;;
    zsh)
        exec zsh -l
        ;;
    *)
        exec bash -l
        ;;
esac
