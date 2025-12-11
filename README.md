# Hyber Orbit Dotfiles

A cross-platform shell alias manager that works on Linux, macOS, and Windows. One command installs a curated set of productivity aliases for Git, Kubernetes, and system operations.

## Quick Start

### Linux / macOS

```bash
bash <(curl -s https://alias.hyberorbit.com/install)
```

### Windows PowerShell

```powershell
iwr -useb https://alias.hyberorbit.com/install.ps1 | iex
```

That's it. Aliases are immediately available in your current shell.

## Features

- **Zero Configuration** - Auto-detects OS, shell type, and environment
- **Cross-Platform** - Works on Linux, macOS, Windows, WSL, Docker containers, and Kubernetes pods
- **Shell Support** - Bash, Zsh, Fish, and PowerShell
- **Instant Setup** - Installs in under 5 seconds
- **Custom Aliases** - Add your own aliases that persist across updates
- **Offline Fallback** - Caches aliases locally for offline use

## Included Aliases

### Git

| Alias | Command | Description |
|-------|---------|-------------|
| `ga` | `git add .` | Stage all changes |
| `gb` | `git branch` | List branches |
| `gc <msg>` | `git commit -m` | Commit with message |
| `gd` | `git diff` | Show unstaged changes |
| `glog` | `git log --oneline -n 20` | Show recent commits |
| `gph <branch>` | `git push origin` | Push to remote |
| `gpl <branch>` | `git pull origin` | Pull from remote |
| `gs` | `git status` | Show working tree status |
| `gsw <branch>` | `git switch` | Switch branches |
| `gauto` | `git add . && commit && push` | Quick backup |

### Kubernetes

| Alias | Command | Description |
|-------|---------|-------------|
| `k` | `kubectl` | Kubectl shorthand |
| `ka <file>` | `kubectl apply -f` | Apply manifest |
| `kd` | `kubectl delete` | Delete resource |
| `kdesc` | `kubectl describe` | Describe resource |
| `ke` | `kubectl exec -it` | Execute in container |
| `kg` | `kubectl get` | Get resources |
| `kgp` | `kubectl get pods` | List pods |
| `kgs` | `kubectl get services` | List services |
| `kl` | `kubectl logs` | View logs |
| `kctx` | `kubectl config current-context` | Show current context |
| `kns <ns>` | `kubectl config set-context --current --namespace` | Set namespace |

### System

| Alias | Command | Description |
|-------|---------|-------------|
| `ll` | `ls -lah` | Detailed file list |
| `la` | `ls -A` | List all files |
| `cls` | `clear` | Clear terminal |
| `reload` | `source ~/.bashrc` | Reload shell config |
| `home` | `cd ~` | Go to home directory |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |

## Custom Aliases

Add your own aliases that persist across updates.

### Linux / macOS

Create files in `~/.hyberorbit/custom/` (no file extension needed):

```bash
# Create custom alias file
cat > ~/.hyberorbit/custom/docker << 'EOF'
alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dps='docker ps'
alias dlog='docker logs -f'
EOF
```

### Windows PowerShell

Create `.ps1` files in `~\.hyberorbit\custom\`:

```powershell
# Create custom alias file
@'
function dc { docker-compose $args }
function dcu { docker-compose up -d $args }
function dcd { docker-compose down $args }
function dps { docker ps $args }
function dlog { docker logs -f $args }
'@ | Out-File ~\.hyberorbit\custom\docker.ps1
```

Custom aliases load automatically on shell startup.

## Directory Structure

After installation:

```
~/.hyberorbit/
├── load.sh          # Main loader script (Linux/macOS)
├── load.ps1         # Main loader script (Windows)
├── env.sh           # Environment variables
└── custom/          # Your custom aliases (preserved on updates)
    └── myaliases    # Example custom file
```

## How It Works

1. **Install script** downloads the loader to `~/.hyberorbit/`
2. **Shell RC file** (`.bashrc`, `.zshrc`, or PowerShell `$PROFILE`) is updated to source the loader
3. **Loader** fetches latest aliases from GitHub on each shell start (with local cache fallback)
4. **Custom aliases** in `~/.hyberorbit/custom/` are loaded after default aliases

## Updating

Aliases update automatically on each new shell session. The loader fetches the latest version from GitHub.

To force update:

```bash
# Linux/macOS
source ~/.hyberorbit/load.sh

# Windows PowerShell
. ~\.hyberorbit\load.ps1
```

## Uninstall

### Linux / macOS

```bash
# Remove hyberorbit directory
rm -rf ~/.hyberorbit

# Remove source line from shell RC
# Edit ~/.bashrc or ~/.zshrc and remove the "Hyber Orbit Dotfiles" section
```

### Windows PowerShell

```powershell
# Remove hyberorbit directory
Remove-Item -Recurse -Force ~\.hyberorbit

# Edit $PROFILE and remove the "Hyber Orbit Dotfiles" section
notepad $PROFILE
```

## Troubleshooting

### Aliases not working after install

```bash
# Linux/macOS - Reload shell
source ~/.bashrc  # or ~/.zshrc

# Windows - Reload profile
. $PROFILE
```

### Check installation

```bash
# Linux/macOS
cat ~/.hyberorbit/load.sh
grep hyberorbit ~/.bashrc

# Windows
Get-Content ~\.hyberorbit\load.ps1
Get-Content $PROFILE | Select-String hyberorbit
```

### Custom aliases not loading

- **Linux/macOS**: Files in `~/.hyberorbit/custom/` should have no extension
- **Windows**: Files must have `.ps1` extension

## Requirements

- **Linux/macOS**: Bash, Zsh, or Fish shell with `curl`
- **Windows**: PowerShell 5.1+ (included in Windows 10/11)

## License

MIT

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/new-alias`)
3. Commit your changes (`git commit -m 'Add new alias'`)
4. Push to the branch (`git push origin feature/new-alias`)
5. Open a Pull Request
