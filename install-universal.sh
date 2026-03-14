#!/bin/sh
# =============================================================================
# Hyber Alias Universal Installer
# Auto-detects shell and installs appropriate aliases
# Works from any shell: bash, zsh, fish, sh
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

# Colors (POSIX compatible)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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
    _shell_name=$(basename "$SHELL")
    case "$_shell_name" in
        zsh) echo "zsh" ;;
        fish) echo "fish" ;;
        bash) echo "bash" ;;
        *) echo "bash" ;;
    esac
}

OS=$(detect_os)
USER_SHELL=$(detect_shell)

# Track download failures
DOWNLOAD_FAILURES=0

# Safe download helper: downloads to a temp file, then moves atomically
safe_download() {
    _sd_url="$1"
    _sd_dest="$2"
    _sd_label="$3"
    _sd_required="${4:-false}"

    _sd_dest_dir=$(dirname "$_sd_dest")
    _sd_tmp=$(mktemp "$_sd_dest_dir/.download.XXXXXX") || {
        if [ "$_sd_required" = "true" ]; then
            printf "      %bFailed to create temp file for %s%b\n" "$RED" "$_sd_label" "$NC"
            return 1
        fi
        DOWNLOAD_FAILURES=$((DOWNLOAD_FAILURES + 1))
        return 1
    }

    if curl -sfS "$_sd_url" -o "$_sd_tmp" 2>/dev/null && [ -s "$_sd_tmp" ]; then
        mv "$_sd_tmp" "$_sd_dest" 2>/dev/null
        return 0
    else
        rm -f "$_sd_tmp" 2>/dev/null
        if [ "$_sd_required" = "true" ]; then
            printf "      %b✗%b Failed to download %s\n" "$RED" "$NC" "$_sd_label"
            return 1
        fi
        DOWNLOAD_FAILURES=$((DOWNLOAD_FAILURES + 1))
        printf "      %b⚠%b  Failed to download %s (non-critical)\n" "$YELLOW" "$NC" "$_sd_label"
        return 1
    fi
}

# Header
printf "\n"
printf "                       %b⚡ Hyber Alias%b %bv%s%b\n" "$BOLD" "$NC" "$DIM" "$VERSION" "$NC"
printf "                %bCross-platform shell alias manager%b\n" "$DIM" "$NC"
printf "\n"
printf "%b  ────────────────────────────────────────────────────────────────%b\n" "$DIM" "$NC"
printf "\n"
printf "  %bSystem%b\n" "$BOLD" "$NC"
printf "\n"
printf "      OS         %b%s%b\n" "$BOLD" "$OS" "$NC"
printf "      Shell      %b%s%b\n" "$BOLD" "$USER_SHELL" "$NC"
printf "\n"
printf "%b  ────────────────────────────────────────────────────────────────%b\n" "$DIM" "$NC"
printf "\n"
printf "  %bInstalling%b\n" "$BOLD" "$NC"
printf "\n"

# Create directories
mkdir -p "$ALIAS_HOME/cache" "$ALIAS_HOME/custom"
printf "      %b✓%b Created ~/.alias\n" "$GREEN" "$NC"

# Install based on detected shell
case "$USER_SHELL" in
    fish)
        # Fish shell installation
        mkdir -p "$HOME/.config/fish/conf.d"
        if ! safe_download "$REPO/aliases/fish.fish" "$HOME/.config/fish/conf.d/hyper-alias.fish" "fish aliases" "true"; then
            exit 1
        fi
        printf "      %b✓%b Downloaded fish aliases\n" "$GREEN" "$NC"

        # Also add sourcing to config.fish if not already present
        SHELL_RC="$HOME/.config/fish/config.fish"
        if [ -f "$SHELL_RC" ] && ! grep -q "hyber-alias\|hyper-alias" "$SHELL_RC" 2>/dev/null; then
            printf "\n# Hyber Alias - https://github.com/thinhngotony/alias\n" >> "$SHELL_RC"
            printf "source ~/.config/fish/conf.d/hyper-alias.fish\n" >> "$SHELL_RC"
            printf "      %b✓%b Configured %b%s%b\n" "$GREEN" "$NC" "$DIM" "$SHELL_RC" "$NC"
        fi
        ;;
    *)
        # Bash/Zsh installation
        if ! safe_download "$REPO/load.sh" "$ALIAS_HOME/load.sh" "loader" "true"; then
            exit 1
        fi
        chmod +x "$ALIAS_HOME/load.sh"

        safe_download "$REPO/aliases/git.sh" "$ALIAS_HOME/cache/git.sh" "git aliases"
        safe_download "$REPO/aliases/k8s.sh" "$ALIAS_HOME/cache/k8s.sh" "k8s aliases"
        safe_download "$REPO/aliases/system.sh" "$ALIAS_HOME/cache/system.sh" "system aliases"
        safe_download "$REPO/aliases/secrets.sh" "$ALIAS_HOME/cache/secrets.sh" "secrets aliases"
        safe_download "$REPO/aliases/ai.sh" "$ALIAS_HOME/cache/ai.sh" "ai aliases"

        if [ "$DOWNLOAD_FAILURES" -gt 0 ]; then
            printf "      %b⚠%b  Downloaded aliases (%d file(s) failed, will retry on next shell start)\n" "$YELLOW" "$NC" "$DOWNLOAD_FAILURES"
        else
            printf "      %b✓%b Downloaded aliases\n" "$GREEN" "$NC"
        fi

        # Determine shell RC file
        case "$USER_SHELL" in
            zsh) SHELL_RC="$HOME/.zshrc" ;;
            *) SHELL_RC="$HOME/.bashrc" ;;
        esac

        # Add to shell RC if not already there
        if ! grep -q "/.alias/load.sh" "$SHELL_RC" 2>/dev/null; then
            printf "\n# Hyber Alias - https://github.com/thinhngotony/alias\n" >> "$SHELL_RC"
            printf "[ -f ~/.alias/load.sh ] && source ~/.alias/load.sh\n" >> "$SHELL_RC"
            printf "      %b✓%b Configured %b%s%b\n" "$GREEN" "$NC" "$DIM" "$SHELL_RC" "$NC"
        else
            printf "      %b✓%b Already configured\n" "$GREEN" "$NC"
        fi
        ;;
esac

# Save environment (quote values to prevent injection)
cat > "$ALIAS_HOME/env.sh" << ENVEOF
export HYBER_VERSION="${VERSION}"
export HYBER_SHELL="${USER_SHELL}"
export HYBER_OS="${OS}"
ENVEOF
chmod 600 "$ALIAS_HOME/env.sh"
printf "      %b✓%b Saved environment\n" "$GREEN" "$NC"

printf "\n"
printf "%b  ────────────────────────────────────────────────────────────────%b\n" "$DIM" "$NC"
printf "\n"
printf "  %b%b✓ Installation complete%b\n" "$GREEN" "$BOLD" "$NC"
printf "\n"
printf "  %bQuick start%b\n" "$BOLD" "$NC"
printf "\n"
printf "      %balias-help%b     Show all available aliases\n" "$CYAN" "$NC"
printf "      %balias-git%b      Git shortcuts\n" "$CYAN" "$NC"
printf "      %balias-k8s%b      Kubernetes shortcuts\n" "$CYAN" "$NC"
printf "\n"
printf "  %b📚 Docs%b  https://github.com/thinhngotony/alias\n" "$DIM" "$NC"
printf "\n"
printf "%b  ────────────────────────────────────────────────────────────────%b\n" "$DIM" "$NC"
printf "\n"
printf "  %bActivate aliases%b\n" "$BOLD" "$NC"
printf "\n"

# Print activation command based on shell.
# Avoid forcing an interactive shell here because this script is often run
# from non-interactive pipelines (e.g. curl | sh) and in CI.
case "$USER_SHELL" in
    fish)
        printf "      Run: %bsource ~/.config/fish/conf.d/hyper-alias.fish%b\n" "$CYAN" "$NC"
        ;;
    zsh)
        printf "      Run: %bsource ~/.zshrc%b\n" "$CYAN" "$NC"
        ;;
    *)
        printf "      Run: %bsource ~/.bashrc%b\n" "$CYAN" "$NC"
        ;;
esac
printf "      Or open a new terminal.\n"
printf "\n"
