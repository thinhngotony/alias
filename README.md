# Hyber Orbit Dotfiles

One command. Auto-installs all shell aliases.

## Install

```bash
bash <(curl -s https://alias.hyberorbit.com/install)
```

## Add Custom Aliases

Just create files in `~/.hyberorbit/custom/`

```bash
# Example: ~/.hyberorbit/custom/myaliases
# (no extensions, no special syntax)

alias dc=docker-compose
alias ll=ls -lah
alias reload=source ~/.bashrc
```

Done! Next shell reload loads them.

## What Gets Installed

- Git aliases
- Kubernetes aliases
- System aliases
- Your custom aliases (preserved on updates)
