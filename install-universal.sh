#!/bin/sh
# =============================================================================
# Hyber Alias Universal Installer
# Auto-detects shell and installs appropriate aliases
# Works from any shell: bash, zsh, fish, sh
# =============================================================================

REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
ALIAS_HOME="$HOME/.alias"
# Cache-buster to bypass GitHub/CDN caching
_CB="?$(date +%s)"

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

# Detect the user's ACTIVE shell by walking the process tree.
# When run via 'curl | sh', PPID may point to a pipe or subshell,
# so we walk up the ancestor chain to find the first real shell.
detect_active_shell() {
    _pid=$PPID
    _depth=0
    while [ "$_pid" -gt 1 ] && [ "$_depth" -lt 10 ]; do
        _comm=""
        if [ -f "/proc/$_pid/comm" ]; then
            _comm=$(cat "/proc/$_pid/comm" 2>/dev/null)
        elif command -v ps >/dev/null 2>&1; then
            _comm=$(ps -p "$_pid" -o comm= 2>/dev/null)
        fi

        case "$_comm" in
            fish) echo "fish"; return ;;
            zsh)  echo "zsh";  return ;;
            bash) echo "bash"; return ;;
        esac

        # Move to parent: read PPID from /proc/PID/stat (field 4)
        if [ -f "/proc/$_pid/stat" ]; then
            _pid=$(awk '{print $4}' "/proc/$_pid/stat" 2>/dev/null || echo 1)
        elif command -v ps >/dev/null 2>&1; then
            _pid=$(ps -p "$_pid" -o ppid= 2>/dev/null | tr -d ' ')
            [ -z "$_pid" ] && _pid=1
        else
            break
        fi
        _depth=$((_depth + 1))
    done

    # Fallback: $SHELL (login shell)
    _shell_name=$(basename "$SHELL")
    case "$_shell_name" in
        zsh)  echo "zsh" ;;
        fish) echo "fish" ;;
        bash) echo "bash" ;;
        *)    echo "bash" ;;
    esac
}

OS=$(detect_os)
USER_SHELL=$(detect_active_shell)

# Detect which shells are available on this system
HAS_BASH=false
HAS_ZSH=false
HAS_FISH=false
command -v bash >/dev/null 2>&1 && HAS_BASH=true
command -v zsh  >/dev/null 2>&1 && HAS_ZSH=true
command -v fish >/dev/null 2>&1 && HAS_FISH=true

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
            printf "      %b✗%b Failed to create temp file for %s\n" "$RED" "$NC" "$_sd_label"
            return 1
        fi
        DOWNLOAD_FAILURES=$((DOWNLOAD_FAILURES + 1))
        return 1
    }

    if curl -sfS "${_sd_url}${_CB}" -o "$_sd_tmp" 2>/dev/null && [ -s "$_sd_tmp" ]; then
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

# Show which shells we'll configure
_shells_list=""
if [ "$HAS_BASH" = true ]; then _shells_list="bash"; fi
if [ "$HAS_ZSH" = true ]; then
    if [ -n "$_shells_list" ]; then _shells_list="$_shells_list, zsh"; else _shells_list="zsh"; fi
fi
if [ "$HAS_FISH" = true ]; then
    if [ -n "$_shells_list" ]; then _shells_list="$_shells_list, fish"; else _shells_list="fish"; fi
fi
printf "      Configure  %b%s%b\n" "$DIM" "$_shells_list" "$NC"

printf "\n"
printf "%b  ────────────────────────────────────────────────────────────────%b\n" "$DIM" "$NC"
printf "\n"
printf "  %bInstalling%b\n" "$BOLD" "$NC"
printf "\n"

# Create directories
mkdir -p "$ALIAS_HOME/cache" "$ALIAS_HOME/custom"
printf "      %b✓%b Created ~/.alias\n" "$GREEN" "$NC"

# =============================================================================
# Always install bash/zsh loader + alias cache (works for both bash and zsh)
# =============================================================================
if [ "$HAS_BASH" = true ] || [ "$HAS_ZSH" = true ]; then
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
fi

# =============================================================================
# Configure bash
# =============================================================================
if [ "$HAS_BASH" = true ] && [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "/.alias/load.sh" "$HOME/.bashrc" 2>/dev/null; then
        printf "\n# Hyber Alias - https://github.com/thinhngotony/alias\n" >> "$HOME/.bashrc"
        printf "[ -f ~/.alias/load.sh ] && source ~/.alias/load.sh\n" >> "$HOME/.bashrc"
        printf "      %b✓%b Configured %b~/.bashrc%b\n" "$GREEN" "$NC" "$DIM" "$NC"
    else
        printf "      %b✓%b Already configured %b~/.bashrc%b\n" "$GREEN" "$NC" "$DIM" "$NC"
    fi
fi

# =============================================================================
# Configure zsh
# =============================================================================
if [ "$HAS_ZSH" = true ] && [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "/.alias/load.sh" "$HOME/.zshrc" 2>/dev/null; then
        printf "\n# Hyber Alias - https://github.com/thinhngotony/alias\n" >> "$HOME/.zshrc"
        printf "[ -f ~/.alias/load.sh ] && source ~/.alias/load.sh\n" >> "$HOME/.zshrc"
        printf "      %b✓%b Configured %b~/.zshrc%b\n" "$GREEN" "$NC" "$DIM" "$NC"
    else
        printf "      %b✓%b Already configured %b~/.zshrc%b\n" "$GREEN" "$NC" "$DIM" "$NC"
    fi
fi

# =============================================================================
# Configure fish (install even if not the primary shell, as long as fish exists)
# =============================================================================
if [ "$HAS_FISH" = true ]; then
    mkdir -p "$HOME/.config/fish/conf.d"
    if safe_download "$REPO/aliases/fish.fish" "$HOME/.config/fish/conf.d/hyper-alias.fish" "fish aliases"; then
        printf "      %b✓%b Configured %bfish (conf.d)%b\n" "$GREEN" "$NC" "$DIM" "$NC"
    fi
fi

# =============================================================================
# Save environment
# =============================================================================
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

# Print activation for ALL configured shells so the user always sees the right one
_printed=0
if [ "$HAS_FISH" = true ]; then
    if [ "$USER_SHELL" = "fish" ]; then
        printf "      Run: %bsource ~/.config/fish/conf.d/hyper-alias.fish%b  %b← your shell%b\n" "$CYAN" "$NC" "$GREEN" "$NC"
    else
        printf "      fish:  %bsource ~/.config/fish/conf.d/hyper-alias.fish%b\n" "$DIM" "$NC"
    fi
    _printed=1
fi
if [ "$HAS_BASH" = true ] && [ -f "$HOME/.bashrc" ]; then
    if [ "$USER_SHELL" = "bash" ]; then
        printf "      Run: %bsource ~/.bashrc%b  %b← your shell%b\n" "$CYAN" "$NC" "$GREEN" "$NC"
    else
        printf "      bash:  %bsource ~/.bashrc%b\n" "$DIM" "$NC"
    fi
    _printed=1
fi
if [ "$HAS_ZSH" = true ] && [ -f "$HOME/.zshrc" ]; then
    if [ "$USER_SHELL" = "zsh" ]; then
        printf "      Run: %bsource ~/.zshrc%b  %b← your shell%b\n" "$CYAN" "$NC" "$GREEN" "$NC"
    else
        printf "      zsh:   %bsource ~/.zshrc%b\n" "$DIM" "$NC"
    fi
    _printed=1
fi
if [ "$_printed" -eq 0 ]; then
    printf "      Run: %bsource ~/.bashrc%b\n" "$CYAN" "$NC"
fi

printf "\n"
printf "      Or open a new terminal.\n"
printf "\n"
