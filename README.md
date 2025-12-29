<p align="center">
  <img src="https://img.shields.io/badge/platforms-Linux%20%7C%20macOS%20%7C%20Windows-blue" alt="Platforms">
  <img src="https://img.shields.io/badge/shells-Bash%20%7C%20Zsh%20%7C%20PowerShell-green" alt="Shells">
  <img src="https://img.shields.io/github/license/thinhngotony/alias" alt="License">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen" alt="PRs Welcome">
</p>

<h1 align="center">Hyber Alias</h1>

<p align="center">
  <strong>One command. All your shell aliases. Everywhere.</strong>
</p>

<p align="center">
  A cross-platform shell alias manager that installs a curated set of<br>
  productivity aliases for Git, Kubernetes, and system operations.
</p>

---

## Quick Start

**Linux / macOS**

```bash
bash <(curl -s https://raw.githubusercontent.com/thinhngotony/alias/main/install.sh)
```

**Windows PowerShell**

```powershell
iwr -useb https://raw.githubusercontent.com/thinhngotony/alias/main/install.ps1 | iex
```

> Aliases are immediately available. No restart required.

---

## Why Hyber Alias?

| Feature | Description |
|---------|-------------|
| **Zero Config** | Auto-detects OS, shell, and environment |
| **Cross-Platform** | Linux, macOS, Windows, WSL, Docker, Kubernetes |
| **Instant Setup** | Installs in under 5 seconds |
| **Always Fresh** | Auto-updates on each shell start |
| **Customizable** | Add your own aliases that persist across updates |
| **Offline Ready** | Works without internet after first install |

---

## Aliases Reference

### Git

| Alias | Command | Description |
|:------|:--------|:------------|
| `ga` | `git add .` | Stage all changes |
| `gb` | `git branch` | List branches |
| `gc <msg>` | `git commit -m <msg>` | Commit with message (use `gcm` on PowerShell) |
| `gd` | `git diff` | Show unstaged changes |
| `glog` | `git log --oneline -n 20` | Recent commits |
| `gph <branch>` | `git push origin <branch>` | Push to remote |
| `gpl <branch>` | `git pull origin <branch>` | Pull from remote |
| `gs` | `git status` | Working tree status |
| `gsw <branch>` | `git switch <branch>` | Switch branches |
| `gauto` | Stage, commit "Backup", push | Quick backup |

### Kubernetes

| Alias | Command | Description |
|:------|:--------|:------------|
| `k` | `kubectl` | Shorthand |
| `ka <file>` | `kubectl apply -f <file>` | Apply manifest |
| `kd` | `kubectl delete` | Delete resource |
| `kdesc` | `kubectl describe` | Describe resource |
| `ke` | `kubectl exec -it` | Exec into container |
| `kg` | `kubectl get` | Get resources |
| `kgp` | `kubectl get pods` | List pods |
| `kgs` | `kubectl get services` | List services |
| `kl` | `kubectl logs` | View logs |
| `kctx` | `kubectl config current-context` | Current context |
| `kns <ns>` | Set namespace | Switch namespace |

### System

| Alias | Command | Description |
|:------|:--------|:------------|
| `ll` | `ls -lah` | Detailed list |
| `la` | `ls -A` | List all |
| `cls` | `clear` | Clear screen |
| `reload` | Reload shell config | Refresh aliases |
| `home` | `cd ~` | Go home |
| `..` | `cd ..` | Up one level |
| `...` | `cd ../..` | Up two levels |

---

## Custom Aliases

Add your own aliases in `~/.alias/custom/`. They persist across updates.

<details>
<summary><strong>Linux / macOS</strong></summary>

Create a file (no extension):

```bash
cat > ~/.alias/custom/docker << 'EOF'
alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dps='docker ps'
EOF
```

</details>

<details>
<summary><strong>Windows PowerShell</strong></summary>

Create a `.ps1` file:

```powershell
@'
function dc { docker-compose $args }
function dcu { docker-compose up -d $args }
function dcd { docker-compose down $args }
function dps { docker ps $args }
'@ | Out-File ~\.alias\custom\docker.ps1
```

</details>

---

## How It Works

```
┌───────────────────────────────────────────────────────────┐
│  1. Install script downloads loader to ~/.alias/          │
│  2. Adds source line to shell config (.bashrc / $PROFILE) │
│  3. Loader fetches latest aliases on each shell start     │
│  4. Custom aliases in ~/.alias/custom/ are loaded last    │
└───────────────────────────────────────────────────────────┘
```

**Directory structure after install:**

```
~/.alias/
├── load.sh       # Loader (Linux/macOS)
├── load.ps1      # Loader (Windows)
├── env.sh        # Environment config
└── custom/       # Your custom aliases
```

---

## Updating

Aliases auto-update on each new shell session.

**Force update:**

```bash
# Linux/macOS
source ~/.alias/load.sh

# Windows
. ~\.alias\load.ps1
```

---

## Uninstall

**Linux / macOS**

```bash
bash <(curl -s https://raw.githubusercontent.com/thinhngotony/alias/main/uninstall.sh)
```

**Windows PowerShell**

```powershell
iwr -useb https://raw.githubusercontent.com/thinhngotony/alias/main/uninstall.ps1 | iex
```

---

## Troubleshooting

<details>
<summary><strong>Windows: "Running scripts is disabled"</strong></summary>

PowerShell blocks scripts by default. Fix:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

Then reinstall.

</details>

<details>
<summary><strong>Windows: Aliases not working</strong></summary>

Open a new PowerShell window, or run:

```powershell
. ~\.alias\load.ps1
```

</details>

<details>
<summary><strong>Windows: Garbled characters</strong></summary>

Cosmetic issue with UTF-8. Install still works. Latest version uses ASCII-only output.

</details>

<details>
<summary><strong>Linux/macOS: Aliases not working</strong></summary>

```bash
source ~/.bashrc  # or ~/.zshrc
```

Or open a new terminal.

</details>

<details>
<summary><strong>Clean reinstall</strong></summary>

**Linux/macOS:**
```bash
bash <(curl -s https://raw.githubusercontent.com/thinhngotony/alias/main/uninstall.sh)
bash <(curl -s https://raw.githubusercontent.com/thinhngotony/alias/main/install.sh)
```

**Windows:**
```powershell
iwr -useb https://raw.githubusercontent.com/thinhngotony/alias/main/uninstall.ps1 | iex
iwr -useb https://raw.githubusercontent.com/thinhngotony/alias/main/install.ps1 | iex
```

</details>

<details>
<summary><strong>Alias conflicts</strong></summary>

Some aliases (e.g., `gc`) override PowerShell built-ins. Use full command name if needed: `Get-Content` instead of `gc`.

</details>

---

## Requirements

| Platform | Requirement |
|----------|-------------|
| Linux | Bash or Zsh, `curl` |
| macOS | Bash or Zsh, `curl` |
| Windows | PowerShell 5.1+ (built-in on Windows 10/11) |

---

## Contributing

Contributions welcome! Please read our contributing guidelines.

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-alias`)
3. Commit changes (`git commit -m 'Add new alias'`)
4. Push to branch (`git push origin feature/new-alias`)
5. Open a Pull Request

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built with care by <a href="https://hyberorbit.com">Hyber Orbit</a></sub>
</p>

