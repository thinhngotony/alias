#!/bin/bash
# Hyber Alias Loader

REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
ALIAS_HOME="${HOME}/.alias"

# Source environment
# shellcheck source=/dev/null
[ -f "$ALIAS_HOME/env.sh" ] && source "$ALIAS_HOME/env.sh"

# Download and cache aliases if online, then source from cache
_alias_download() {
    local name=$1
    local url="$REPO/aliases/${name}.sh"
    local cache="$ALIAS_HOME/cache/${name}.sh"

    mkdir -p "$ALIAS_HOME/cache"

    # Try to download (with 2 second timeout)
    if curl -s --connect-timeout 2 --max-time 2 "$url" -o "$cache.tmp" 2>/dev/null && [ -s "$cache.tmp" ]; then
        mv "$cache.tmp" "$cache" 2>/dev/null || true
    else
        rm -f "$cache.tmp" 2>/dev/null || true
    fi

    # Source from cache if exists
    # shellcheck source=/dev/null
    [ -f "$cache" ] && source "$cache"
}

# Load default aliases
_alias_download "git"
_alias_download "k8s"
_alias_download "system"

# Source user custom aliases (handle empty directory for zsh compatibility)
if [ -d "$ALIAS_HOME/custom" ] && [ -n "$(ls -A "$ALIAS_HOME/custom" 2>/dev/null)" ]; then
    for file in "$ALIAS_HOME/custom"/*; do
        # shellcheck source=/dev/null
        [ -f "$file" ] && source "$file" 2>/dev/null
    done
fi
