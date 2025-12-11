#!/bin/bash
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
