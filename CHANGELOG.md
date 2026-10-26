# Changelog

All notable changes to srm will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of srm (Safe RM)
- POSIX shell script implementation (srm, srmi)
- Windows batch script implementation (srm.bat, srmi.bat)
- macOS native helper (srm-macos) using NSFileManager
- Windows native helper (srm-windows) using IFileOperation
- Linux implementation using FreeDesktop.org Trash specification
- Comprehensive documentation suite
- Test suite structure
- Installation scripts for all platforms
- Website with interactive terminal simulator

## [1.0.0] - 2026-10-26

### Added
- Core srm functionality for macOS, Linux, and Windows
- rm-compatible options: -f, -i, -I, -r, -R, -d, -v
- Root protection with --preserve-root
- Option termination with --
- Wildcard support (shell-native)
- Special filename handling
- Recursive directory removal
- Verbose mode
- Force mode
- Interactive mode
- Cross-platform Trash integration
- BSD 3-Clause License
- Complete documentation
- Installation procedures
- GitHub Actions workflows
- Website with interactive demo

### Security
- No silent permanent deletion fallback
- Root path protection
- Safe argument handling
- Shell injection prevention
- Path traversal protection
- Symlink safety

### Documentation
- README.md
- INSTALL.md
- USAGE.md
- WINDOWS.md
- COMPATIBILITY.md
- DEVELOPMENT.md
- TESTING.md
- CONTRIBUTING.md
- SECURITY.md
- CHANGELOG.md
- FAQ.md
- Platform-specific docs in docs/

## [0.0.0] - Project Init

### Planned
- Initial project planning
- Architecture design
- Platform research
