#!/bin/bash
# Hyber Orbit Aliases Loader

REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
ALIAS_HOME="${HOME}/.alias"

# Source environment
[ -f "$ALIAS_HOME/env.sh" ] && source "$ALIAS_HOME/env.sh"

# Download and cache aliases if online, then source from cache
_alias_download() {
    local name=$1
    local url="$REPO/aliases/${name}.sh"
    local cache="$ALIAS_HOME/cache/${name}.sh"

    mkdir -p "$ALIAS_HOME/cache"

    # Try to download (with 2 second timeout)
    if curl -s --connect-timeout 2 --max-time 2 "$url" -o "$cache.tmp" 2>/dev/null; then
        mv "$cache.tmp" "$cache"
    fi

    # Source from cache if exists
    [ -f "$cache" ] && source "$cache"
}

# Load default aliases
_alias_download "git"
_alias_download "k8s"
_alias_download "system"

# Source user custom aliases
if [ -d "$ALIAS_HOME/custom" ]; then
    for file in "$ALIAS_HOME/custom"/*; do
        [ -f "$file" ] && source "$file" 2>/dev/null
    done
fi
