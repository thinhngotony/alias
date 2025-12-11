#!/bin/bash
# Hyber Orbit Dotfiles Loader

REPO="https://raw.githubusercontent.com/thinhngotony/alias/main"
ALIAS_HOME="${HOME}/.alias"

# Source environment
[ -f "$ALIAS_HOME/env.sh" ] && source "$ALIAS_HOME/env.sh"

# Source all default aliases (with timeout, fallback to local)
timeout 2 bash -c "source <(curl -s \"$REPO/aliases/git.sh\")" 2>/dev/null || source "$ALIAS_HOME/aliases/git.sh" 2>/dev/null
timeout 2 bash -c "source <(curl -s \"$REPO/aliases/k8s.sh\")" 2>/dev/null || source "$ALIAS_HOME/aliases/k8s.sh" 2>/dev/null
timeout 2 bash -c "source <(curl -s \"$REPO/aliases/system.sh\")" 2>/dev/null || source "$ALIAS_HOME/aliases/system.sh" 2>/dev/null

# Source user custom aliases (SUPER SIMPLE - no special syntax needed)
if [ -d "$ALIAS_HOME/custom" ]; then
    for file in "$ALIAS_HOME/custom"/*; do
        if [ -f "$file" ]; then
            # Just source the file directly - no extensions, no parsing
            source "$file" 2>/dev/null || true
        fi
    done
fi

export PATH="$PATH"
