# Hyber Alias - Feature Tracking

## Category-Based Alias Discovery

### Overview
Users can discover aliases by typing `alias-` followed by TAB for autocomplete.

### Commands

| Command | Description |
|---------|-------------|
| `alias-help` | Master help - shows all categories |
| `alias-git` | Git aliases reference |
| `alias-k8s` | Kubernetes aliases reference |
| `alias-system` | System aliases reference |

### How It Works

1. Each category file (`aliases/*.sh`) defines its own `alias-<category>` function
2. `load.sh` defines the master `alias-help` function
3. Shell tab completion automatically discovers `alias-*` functions
4. PowerShell version mirrors the same pattern in `load.ps1`

### Files Modified

```
aliases/git.sh      - Added alias-git() help function
aliases/k8s.sh      - Added alias-k8s() help function
aliases/system.sh   - Added alias-system() help function
load.sh             - Added alias-help() master function
load.ps1            - Added all alias-* functions for Windows
README.md           - Added Quick Reference section
```

### Usage Example

```bash
# See all categories
alias-help

# See git aliases
alias-git

# Tab completion
alias-<TAB>
# Shows: alias-git  alias-help  alias-k8s  alias-system
```

### Adding Custom Categories

Users can add custom categories in `~/.alias/custom/`:

```bash
# ~/.alias/custom/docker
alias dc='docker-compose'
alias dps='docker ps'

alias-docker() {
    cat << 'EOF'
Docker Aliases
═══════════════════════════════════════════════════════════════════════════════
  dc           docker-compose                 Shorthand
  dps          docker ps                      List containers
═══════════════════════════════════════════════════════════════════════════════
EOF
}
```
