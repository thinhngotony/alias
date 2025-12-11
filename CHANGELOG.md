# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0-rc.1] - 2024-12-11

### Added
- Initial release candidate
- One-command install for Linux, macOS, and Windows
- Git aliases: `ga`, `gb`, `gc`, `gd`, `gs`, `gph`, `gpl`, `gsw`, `glog`, `gauto`
- Kubernetes aliases: `k`, `ka`, `kd`, `kg`, `kgp`, `kgs`, `kl`, `ke`, `kctx`, `kns`
- System aliases: `ll`, `la`, `cls`, `reload`, `home`, `..`, `...`
- Custom alias support via `~/.alias/custom/`
- Auto-update on shell start
- Offline fallback with local cache
- One-command uninstall
- Cross-platform support (Linux, macOS, Windows, WSL, Docker, Kubernetes)
- Bash, Zsh, and PowerShell support

### Technical
- Cloudflare Worker for install script delivery
- GitHub Actions CI/CD pipeline
- ShellCheck linting for bash scripts
- PowerShell syntax validation

## Installation

```bash
# Linux/macOS
bash <(curl -s https://alias.hyberorbit.com/install)

# Windows PowerShell
iwr -useb https://alias.hyberorbit.com/install.ps1 | iex
```

[Unreleased]: https://github.com/thinhngotony/alias/compare/v1.0.0-rc.1...HEAD
[1.0.0-rc.1]: https://github.com/thinhngotony/alias/releases/tag/v1.0.0-rc.1
