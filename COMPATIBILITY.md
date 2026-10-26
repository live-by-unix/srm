# Compatibility Guide

This document covers compatibility details across platforms and shells.

## Table of Contents

- [Platform Compatibility](#platform-compatibility)
- [rm Compatibility](#rm-compatibility)
- [Shell Compatibility](#shell-compatibility)
- [Option Compatibility](#option-compatibility)
- [Trash Specification Compatibility](#trash-specification-compatibility)
- [Known Limitations](#known-limitations)

## Platform Compatibility

### macOS

| Feature | Status | Notes |
|---------|--------|-------|
| Trash Integration | ✓ Full | NSFileManager API |
| Required Version | macOS 10.8+ | For NSFileManager Trash API |
| Finder Integration | ✓ Full | Items appear in Finder Trash |
| Recursive Removal | ✓ Full | Directories moved as units |
| Cross-Volume | ✓ Full | Handled by NSFileManager |
| Filename Collisions | ✓ Full | Automatic renaming |
| Symlinks | ✓ Full | Treated correctly |
| Unicode Filenames | ✓ Full | Native support |

### Linux

| Feature | Status | Notes |
|---------|--------|-------|
| Trash Integration | ✓ Full | FreeDesktop.org spec |
| Required Specs | XDG Base Directory, Trash 1.0 | Standard specs |
| Desktop Integration | ✓ Partial | Depends on DE |
| GNOME | ✓ Full | Native support |
| KDE | ✓ Full | Native support |
| XFCE | ✓ Full | Native support |
| Other DEs | ✓ Most | If spec compliant |
| Recursive Removal | ✓ Full | Directories moved as units |
| Cross-Filesystem | ✓ Full | Per spec |
| Filename Collisions | ✓ Full | Automatic numbering |
| Symlinks | ✓ Full | Follows spec |
| Unicode Filenames | ✓ Full | UTF-8 paths |

### Windows

| Feature | Status | Notes |
|---------|--------|-------|
| Recycle Bin Integration | ✓ Full | IFileOperation API |
| Required Version | Windows Vista+ | For IFileOperation |
| Windows 7+ | ✓ Full | Tested |
| Windows 10+ | ✓ Full | Tested |
| Windows 11 | ✓ Full | Expected to work |
| Command Prompt | ✓ Full | Native support |
| PowerShell | ✓ Full | Native support |
| Git Bash | ✓ Via POSIX | Use srm script |
| Cross-Volume | ✓ Full | Handled by API |
| Filename Collisions | ✓ Full | Automatic |
| Unicode Filenames | ✓ Full | UTF-16 paths |
| MAX_PATH | ⚠ Limited | 260 char limit |

## rm Compatibility

### GNU rm (Linux)

| Option | srm Support | Notes |
|--------|-------------|-------|
| `-f`, `--force` | ✓ | Identical behavior |
| `-i`, `--interactive` | ✓ | Identical behavior |
| `-I` | ✓ | Identical behavior |
| `-r`, `-R`, `--recursive` | ✓ | Trash semantics differ |
| `-d`, `--dir` | ✓ | Trash semantics differ |
| `-v`, `--verbose` | ✓ | Different message format |
| `--preserve-root` | ✓ | Identical behavior |
| `--no-preserve-root` | ✓ | No permanent deletion |
| `--` | ✓ | Identical behavior |
| `--help` | ✗ | Treated as filename |
| `--version` | ✗ | Treated as filename |
| `--one-file-system` | ✗ | Not implemented |
| `--no-preserve-root` | ✓ | Does not enable permanent deletion |

### BSD/macOS rm

| Option | srm Support | Notes |
|--------|-------------|-------|
| `-f`, `--force` | ✓ | Identical behavior |
| `-i`, `--interactive` | ✓ | Identical behavior |
| `-I` | ✓ | Identical behavior |
| `-r`, `-R`, `--recursive` | ✓ | Trash semantics differ |
| `-d`, `--dir` | ✓ | Trash semantics differ |
| `-v`, `--verbose` | ✓ | Different message format |
| `-P` | ✗ | Not implemented (permanent deletion) |
| `-W` | ✗ | Not implemented (undeleter) |
| `--` | ✓ | Identical behavior |
| `--help` | ✗ | Treated as filename |
| `--version` | ✗ | Treated as filename |

### Windows del

| Option | srm Support | Notes |
|--------|-------------|-------|
| `/P` (prompt) | ✓ | Via `-i` |
| `/F` (force) | ✓ | Via `-f` |
| `/S` (recursive) | ✓ | Via `-r` |
| `/Q` (quiet) | ✓ | Inverse of `-v` |
| `/A` (attributes) | ✗ | Not implemented |
| Wildcards | ✓ | Shell-dependent |

### Windows PowerShell Remove-Item

| Option | srm Support | Notes |
|--------|-------------|-------|
| `-Force` | ✓ | Via `-f` |
| `-Recurse` | ✓ | Via `-r` |
| `-Confirm` | ✓ | Via `-i` |
| `-Verbose` | ✓ | Via `-v` |
| `-WhatIf` | ✗ | Not implemented |
| `-LiteralPath` | ✓ | Default behavior |

## Shell Compatibility

### POSIX Shells (bash, zsh, dash, etc.)

| Feature | Support | Notes |
|---------|---------|-------|
| Option parsing | ✓ Full | Standard getopt style |
| Wildcard expansion | ✓ Full | Shell-native |
| Quoting | ✓ Full | Standard rules |
| Pipes | ✓ Full | Exit codes preserved |
| Redirection | ✓ Full | Works normally |
| Scripts | ✓ Full | Can be used in scripts |
| Backticks | ✓ Full | Can capture output |
| $() | ✓ Full | Can capture output |

### Command Prompt (cmd.exe)

| Feature | Support | Notes |
|---------|---------|-------|
| Option parsing | ✓ Full | Via native helper |
| Wildcard expansion | ✓ Full | cmd.exe native |
| Quoting | ✓ Full | With quotes |
| Pipes | ✓ Full | Exit codes preserved |
| Redirection | ✓ Full | Works normally |
| Scripts | ✓ Full | Batch files |
| Special characters | ⚠ Limited | Quote them |

### PowerShell

| Feature | Support | Notes |
|---------|---------|-------|
| Option parsing | ✓ Full | Via native helper |
| Wildcard expansion | ✓ Full | PowerShell native |
| Quoting | ✓ Full | Both ' and " |
| Pipes | ✓ Full | Exit codes preserved |
| Redirection | ✓ Full | Works normally |
| Scripts | ✓ Full | PS1 files |
| Variables | ✓ Full | In arguments |

### Git Bash / MSYS2

| Feature | Support | Notes |
|---------|---------|-------|
| Option parsing | ✓ Full | POSIX style |
| Wildcard expansion | ✓ Full | Bash native |
| Quoting | ✓ Full | Bash rules |
| Paths | ✓ Full | Handles / and \ |
| Scripts | ✓ Full | Shell scripts |

## Option Compatibility

### Short Option Combinations

Supported across all platforms:

```bash
srm -rf dir/
srm -fr dir/
srm -rv dir/
srm -fiv file.txt
```

### Long Options

POSIX platforms support long options:

```bash
srm --force file.txt
srm --recursive dir/
srm --verbose file.txt
```

Windows batch scripts also support long options:

```cmd
srm.bat --force file.txt
srm.bat --recursive dir\
```

### Option Termination

`--` marks end of options:

```bash
srm -- -help.txt
srm -- --version.txt
```

Works on all platforms.

## Trash Specification Compatibility

### FreeDesktop.org Trash Specification

| Feature | Implementation | Status |
|---------|----------------|--------|
| Home Trash | `$XDG_DATA_HOME/Trash` | ✓ Full |
| Volume Trash | `$mount/.Trash-$uid` | ✓ Full |
| .trashinfo files | ✓ Full | ✓ Full |
| Deletion date | ✓ Full | ✓ Full |
| Original path | ✓ Full | ✓ Full |
| Collision handling | ✓ Full | ✓ Full |
| Top directory info | ✓ Full | ✓ Full |
| UID safety | ✓ Full | ✓ Full |

### macOS Trash Integration

| Feature | Implementation | Status |
|---------|----------------|--------|
| NSFileManager API | ✓ Full | ✓ Full |
| Finder visible | ✓ Full | ✓ Full |
| Collision handling | ✓ Full | ✓ Full |
| Cross-volume | ✓ Full | ✓ Full |
| Symlinks | ✓ Full | ✓ Full |

### Windows Recycle Bin

| Feature | Implementation | Status |
|---------|----------------|--------|
| IFileOperation API | ✓ Full | ✓ Full |
| Shell visible | ✓ Full | ✓ Full |
| Collision handling | ✓ Full | ✓ Full |
| Cross-volume | ✓ Full | ✓ Full |
| Per-drive bins | ✓ Full | ✓ Full |

## Known Limitations

### macOS

- Volume Trash on network drives may not work
- Very old macOS versions (< 10.8) not supported
- Some network filesystems may not support Trash

### Linux

- Desktop environments must support FreeDesktop spec
- Some lightweight WMs may not have Trash UI
- Network filesystems may not support Trash
- Container environments may have limited Trash

### Windows

- MAX_PATH limitation (260 characters)
- Subst drives may not have Recycle Bin
- Network drives may not support Recycle Bin
- Requires native helper compilation
- Windows XP not supported (no IFileOperation)

### Cross-Platform

- Identical wildcard syntax ≠ identical semantics
- Path separators differ (/ vs \)
- Filename encoding differs (UTF-8 vs UTF-16)
- Permission models differ
- Case sensitivity differs

## Testing Status

| Platform | Tests Run | Status |
|----------|-----------|--------|
| macOS 12+ | Unit, Integration | ✓ Pass |
| Ubuntu 20.04 | Unit, Integration | ✓ Pass |
| Ubuntu 22.04 | Unit, Integration | ✓ Pass |
| Fedora 36 | Unit, Integration | ✓ Pass |
| Windows 10 | Unit, Integration | ✓ Pass |
| Windows 11 | Unit, Integration | ⚠ Unverified |

## Feature Matrix

| Feature | macOS | Linux | Windows |
|---------|-------|-------|---------|
| Native Trash | ✓ | ✓ | ✓ |
| Shell Scripts | ✓ | ✓ | ✓ |
| Batch Scripts | ✗ | ✗ | ✓ |
| Native Helper | ✓ | ✗ | ✓ |
| Recursive | ✓ | ✓ | ✓ |
| Force | ✓ | ✓ | ✓ |
| Interactive | ✓ | ✓ | ✓ |
| Verbose | ✓ | ✓ | ✓ |
| Preserve Root | ✓ | ✓ | ✓ |
| Wildcards | ✓ | ✓ | ✓ |
| Unicode | ✓ | ✓ | ✓ |
| Cross-Volume | ✓ | ✓ | ✓ |

## See Also

- [README.md](README.md) - Project overview
- [USAGE.md](USAGE.md) - Usage guide
- [WINDOWS.md](WINDOWS.md) - Windows details
- [docs/macos.md](docs/macos.md) - macOS details
- [docs/linux.md](docs/linux.md) - Linux details
