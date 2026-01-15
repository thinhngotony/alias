#!/bin/bash
# =============================================================================
# System Aliases
# =============================================================================

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
# Dynamic reload based on current shell
if [ -n "$ZSH_VERSION" ]; then
    alias reload='source ~/.zshrc'
else
    alias reload='source ~/.bashrc'
fi
alias home='cd ~'
alias ..='cd ..'
alias ...='cd ../..'

# =============================================================================
# Help Function
# =============================================================================

alias-system() {
    cat << 'EOF'
System Aliases
═══════════════════════════════════════════════════════════════════════════════
  ll           ls -lah                        Detailed list with hidden
  la           ls -A                          List all except . and ..
  l            ls -CF                         Compact list
  cls          clear                          Clear screen
  reload       source ~/.bashrc|~/.zshrc      Reload shell config
  home         cd ~                           Go to home directory
  ..           cd ..                          Up one level
  ...          cd ../..                       Up two levels
═══════════════════════════════════════════════════════════════════════════════
EOF
}
