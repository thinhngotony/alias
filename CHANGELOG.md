# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - 2025-12-29

### Fixed
- Fixed installation failing due to Cloudflare bot protection blocking curl requests
- Changed default installation URLs from Cloudflare worker to GitHub raw URLs for reliability

## [1.0.1] - 2025-12-16

### Fixed
- Fixed shell detection to use user's login shell (`$SHELL`) instead of current script shell
- Fixed zsh glob pattern error when `~/.alias/custom/` directory is empty
- Installation now correctly detects zsh on macOS when run via `bash <(curl ...)`

## [1.0.0] - 2025-12-11

### Changed
- Renamed `gc` to `gcm` on PowerShell to avoid conflict with `Get-Content` built-in alias
- Made `reload` alias dynamic (detects zsh vs bash)
- Disabled Cloudflare edge caching for instant updates

### Fixed
- Fixed `gauto` alias to not depend on alias expansion
- Fixed PowerShell functions to pass-through additional arguments
- Fixed loader to handle download failures gracefully
- Fixed CI pipeline (PowerShell syntax check, cross-platform tests)

### Added
- GitHub Actions CI/CD pipeline with cross-platform testing
- Issue templates (bug report, feature request)
- Pull request template
- CONTRIBUTING.md with development guidelines
- SECURITY.md with vulnerability reporting policy

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

[Unreleased]: https://github.com/thinhngotony/alias/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/thinhngotony/alias/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/thinhngotony/alias/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/thinhngotony/alias/compare/v1.0.0-rc.1...v1.0.0
[1.0.0-rc.1]: https://github.com/thinhngotony/alias/releases/tag/v1.0.0-rc.1
