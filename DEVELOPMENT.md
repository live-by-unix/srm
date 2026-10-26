# Development Guide

This guide covers development setup, architecture, and contribution guidelines.

## Table of Contents

- [Development Setup](#development-setup)
- [Architecture](#architecture)
- [Code Organization](#code-organization)
- [Building](#building)
- [Testing](#testing)
- [Coding Standards](#coding-standards)
- [Contributing](#contributing)

## Development Setup

### Prerequisites

**For macOS:**
- Xcode Command Line Tools
- clang (Objective-C compiler)

**For Linux:**
- POSIX-compliant shell
- Standard shell utilities

**For Windows:**
- Visual Studio 2015 or later
- Developer Command Prompt

### Repository Structure

```
srm/
├── srm                  # POSIX shell script (removal)
├── srmi                 # POSIX shell script (information)
├── srm.bat              # Windows batch script (removal)
├── srmi.bat             # Windows batch script (information)
├── srm-macos            # macOS native helper (compiled)
├── srm-windows.exe      # Windows native helper (compiled)
├── src/
│   ├── srm-macos.m      # macOS helper source
│   ├── srm-windows.cpp  # Windows helper source
│   ├── build-macos.sh   # macOS build script
│   ├── build-windows.bat # Windows build script
│   └── build-linux.sh   # Linux build stub
├── scripts/
│   ├── install.sh       # POSIX install script
│   ├── install.bat      # Windows install script
│   ├── uninstall.sh     # POSIX uninstall script
│   └── uninstall.bat    # Windows uninstall script
├── tests/
│   ├── unit/            # Unit tests
│   ├── integration/     # Integration tests
│   ├── shell/           # Shell script tests
│   └── windows/         # Windows tests
├── docs/                # Documentation
├── website/             # Website source
└── .github/             # GitHub configuration
```

### Cloning the Repository

```bash
git clone https://github.com/live-by-unix/srm.git
cd srm
```

## Architecture

### Design Principles

1. **Thin Entry Points**: Public scripts are minimal, delegating to platform-specific implementations
2. **Native Integration**: Use platform APIs for Trash/Recycle Bin
3. **No Silent Fallback**: Never switch to permanent deletion
4. **Safe by Default**: Protect against dangerous operations
5. **Transparent**: Report all errors accurately

### Component Diagram

```
User Command
    │
    ├─► srm (POSIX)
    │       │
    │       ├─► Platform Detection
    │       │
    │       ├─► macOS ──► srm-macos (NSFileManager)
    │       │
    │       ├─► Linux ──► Shell implementation (FreeDesktop)
    │       │
    │       └─► Windows ──► Error (use srm.bat)
    │
    └─► srm.bat (Windows)
            │
            └─► srm-windows.exe (IFileOperation)
```

### POSIX Shell Script (srm)

The POSIX shell script:

1. Parses command-line options
2. Detects the platform
3. Validates arguments (root protection, etc.)
4. Delegates to platform-specific Trash implementation
5. Reports results

**Key Features:**
- POSIX-compliant (no Bashisms)
- Safe argument handling
- Proper quoting
- Explicit error handling

### macOS Native Helper (srm-macos)

Written in Objective-C using NSFileManager:

```objective-c
[NSFileManager trashItemAtURL:resultingItemURL:error:]
```

**Responsibilities:**
- Move files to Finder Trash
- Handle filename collisions
- Report errors

### Linux Implementation

Implemented directly in the shell script using FreeDesktop.org Trash specification:

**Responsibilities:**
- Create Trash directory structure
- Generate .trashinfo metadata
- Handle cross-filesystem operations
- Handle filename collisions

### Windows Batch Script (srm.bat)

The batch script:

1. Checks for native helper
2. Delegates to srm-windows.exe
3. Propagates exit codes

**Responsibilities:**
- Minimal argument forwarding
- Dependency checking
- Error reporting

### Windows Native Helper (srm-windows)

Written in C++ using IFileOperation API:

```cpp
IFileOperation::DeleteItem()
IFileOperation::PerformOperations()
```

**Responsibilities:**
- Move files to Recycle Bin
- Handle cross-volume operations
- Detect subst drives
- Report errors

## Code Organization

### Shell Scripts

**Naming:**
- Functions use `snake_case`
- Variables use `snake_case`
- Constants use `UPPER_SNAKE_CASE`

**Error Handling:**
- Check exit codes explicitly
- Use `set -eu` for error detection
- Print errors to stderr

**Option Parsing:**
- Manual parsing for portability
- Support short option combinations
- Treat `--help` and `--version` as filenames

### Objective-C (macOS)

**Style:**
- Follow Apple coding guidelines
- Use ARC (Automatic Reference Counting)
- Proper error handling with NSError

**Memory Management:**
- ARC handles memory
- Use @autoreleasepool for operations

### C++ (Windows)

**Style:**
- Follow Microsoft coding guidelines
- Use RAII where applicable
- Proper COM reference counting

**COM Handling:**
- Initialize COM on startup
- Release all interfaces
- Uninitialize COM on shutdown

## Building

### macOS

```bash
cd src
./build-macos.sh
```

This compiles `srm-macos.m` to `srm-macos`.

### Linux

No compilation needed. The shell script implements Trash directly.

### Windows

```cmd
cd src
build-windows.bat
```

This compiles `srm-windows.cpp` to `srm-windows.exe`.

Requires Visual Studio or Build Tools for Visual Studio.

## Testing

See [TESTING.md](TESTING.md) for detailed testing instructions.

## Coding Standards

### Shell Scripts

- Use POSIX sh, not bash-specific features
- Quote all variable expansions: `"$var"`
- Use `printf` instead of `echo` for portability
- Explicit error checking after every command
- Functions at the top, main at the bottom
- Comments for non-obvious logic

### Objective-C

- Follow Apple's naming conventions
- Use descriptive variable names
- Handle all possible error conditions
- Document non-obvious behavior

### C++

- Follow Microsoft's naming conventions
- Use descriptive variable names
- Handle all HRESULT returns
- Document COM interface usage

### Documentation

- Update README.md for user-facing changes
- Update USAGE.md for behavior changes
- Update platform-specific docs for platform changes
- Update CHANGELOG.md for releases

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

### Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Update documentation
6. Submit a pull request

### Code Review

- All changes require review
- Address review feedback
- Ensure tests pass
- Ensure documentation is updated

### Release Process

1. Update version in all files
2. Update CHANGELOG.md
3. Tag the release
4. Create GitHub release
5. Build and upload artifacts

## Platform-Specific Notes

### macOS Development

- Test on multiple macOS versions if possible
- Test with various filesystem types (APFS, HFS+, external drives)
- Verify Finder Trash integration

### Linux Development

- Test on multiple distributions (Ubuntu, Fedora, etc.)
- Test with multiple desktop environments (GNOME, KDE, XFCE)
- Verify FreeDesktop Trash compliance

### Windows Development

- Test on Windows 10 and 11
- Test in Command Prompt and PowerShell
- Verify Recycle Bin integration
- Test with various path types (local, network, subst)

## Debugging

### Shell Script Debugging

Enable debug output:
```bash
sh -x srm file.txt
```

### macOS Helper Debugging

Enable logging in the Objective-C code:
```objective-c
NSLog(@"Debug: %@", message);
```

### Windows Helper Debugging

Use Visual Studio debugger or add logging:
```cpp
fwprintf(stderr, L"Debug: %s\n", message);
```

## Performance Considerations

### Shell Script

- Minimize external command calls
- Use shell built-ins where possible
- Avoid unnecessary stat calls

### macOS Helper

- NSFileManager is efficient
- Batch operations if possible
- Cache repeated lookups

### Windows Helper

- IFileOperation is efficient
- Declare all operations before performing
- Use progress sink for feedback

## Security Considerations

See [SECURITY.md](SECURITY.md) for security guidelines.

Key points:
- No shell injection
- No unsafe eval
- Validate all inputs
- Follow principle of least privilege

## See Also

- [README.md](README.md) - Project overview
- [TESTING.md](TESTING.md) - Testing guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [SECURITY.md](SECURITY.md) - Security model
