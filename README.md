# Hyber Orbit Dotfiles

One command. Auto-installs all shell aliases.

## Install

**Linux / Mac:**
```bash
bash <(curl -s https://alias.hyberorbit.com/install)
```

**Windows PowerShell:**
```powershell
iwr -useb https://alias.hyberorbit.com/install.ps1 | iex
```

## Add Custom Aliases

**Linux/Mac:** Create files in `~/.hyberorbit/custom/`

```bash
# Example: ~/.hyberorbit/custom/myaliases
alias dc=docker-compose
alias ll=ls -lah
```

**Windows:** Create `.ps1` files in `~\.hyberorbit\custom\`

```powershell
# Example: ~\.hyberorbit\custom\myaliases.ps1
function dc { docker-compose $args }
```

Done! Next shell reload loads them.

## What Gets Installed

- Git aliases (ga, gb, gc, gph, gpl, gs, gsw, gd, glog)
- Kubernetes aliases (k, ka, kd, kg, kgp, kgs, kl, ke, kctx, kns)
- System aliases (ll, la, cls, reload, home, .., ...)
- Your custom aliases (preserved on updates)
