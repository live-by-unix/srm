# srm (Safe RM)

A cross-platform alternative to `rm` that moves files and directories to the native Trash or Recycle Bin instead of permanently deleting them.

## Quick Start

### macOS

```bash
# Install (user-local)
./scripts/install.sh

# Use like rm
srm document.txt
srm -r old-project/
srm -rf build/
```

### Linux

```bash
# Install (user-local)
./scripts/install.sh

# Use like rm
srm document.txt
srm -r old-project/
srm -rf build/
```

### Windows

```cmd
REM Install (user-local)
scripts\install.bat

REM Use like del or rm
srm.bat document.txt
srm.bat -r old-project\
srm.bat -rf build\
```

## What is srm?

`srm` (Safe RM) is a drop-in replacement for the standard `rm` command that provides a safety layer by moving files to the operating system's native Trash or Recycle Bin rather than permanently deleting them.

**Key difference:**

| Command | Behavior |
|---------|----------|
| `rm file.txt` | Permanently deletes the file |
| `srm file.txt` | Moves the file to Trash (recoverable) |

## Features

- **Native Trash Integration**: Uses the operating system's actual Trash/Recycle Bin
- **Cross-Platform**: Supports macOS, Linux, and Windows
- **rm Compatibility**: Familiar command-line interface with `rm`-compatible options
- **No Silent Fallback**: Never falls back to permanent deletion if Trash is unavailable
- **Safe by Default**: Protects against accidental permanent deletion
- **Transparent**: Accurately reports success, failure, and limitations

## Installation

### macOS

```bash
# Clone the repository
git clone https://github.com/live-by-unix/srm.git
cd srm

# Install to ~/bin (user-local, no sudo required)
./scripts/install.sh

# Add to PATH if needed (add to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/bin:$PATH"
```

### Linux

```bash
# Clone the repository
git clone https://github.com/live-by-unix/srm.git
cd srm

# Install to ~/bin (user-local, no sudo required)
./scripts/install.sh

# Add to PATH if needed (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/bin:$PATH"
```

### Windows

```cmd
REM Clone the repository
git clone https://github.com/live-by-unix/srm.git
cd srm

REM Install to %USERPROFILE%\bin (user-local)
scripts\install.bat

REM Add to PATH if needed (System Properties > Environment Variables)
```

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

## Usage

### Basic Examples

```bash
# Remove a single file
srm document.txt

# Remove multiple files
srm file1.txt file2.txt file3.txt

# Remove a directory recursively
srm -r old-project/

# Force removal (suppress nonexistent file errors)
srm -f missing.txt

# Verbose output
srm -v *.log

# Remove with filenames starting with hyphen
srm -- -strange-filename.txt
```

### Information Command

```bash
# Show help
srmi --help

# Show version
srmi --version

# Show usage summary
srmi --usage

# Show license
srmi --license
```

**Important:** `srm --help` does NOT show help information—it treats `--help` as a filename. Use `srmi --help` for documentation.

## Options

| Option | Description |
|--------|-------------|
| `-f`, `--force` | Ignore nonexistent files and arguments, never prompt |
| `-i`, `--interactive` | Prompt before every removal |
| `-I` | Prompt once before removing more than three files |
| `-r`, `-R`, `--recursive` | Remove directories and their contents recursively |
| `-d`, `--dir` | Remove empty directories |
| `-v`, `--verbose` | Explain what is being done |
| `--preserve-root` | Fail if operating on `/` (default) |
| `--no-preserve-root` | Do not treat `/` specially |
| `--` | End of options |

See [USAGE.md](USAGE.md) for detailed usage documentation.

## Platform-Specific Notes

### macOS

- Uses `NSFileManager` API for native Finder Trash integration
- Directories are moved as recoverable units
- Handles filename collisions automatically
- Requires macOS 10.8+ for Trash API support

See [docs/macos.md](docs/macos.md) for macOS-specific details.

### Linux

- Implements the FreeDesktop.org Trash specification
- Trash location: `$XDG_DATA_HOME/Trash` (typically `~/.local/share/Trash`)
- Handles cross-filesystem operations correctly
- Compatible with GNOME, KDE, XFCE, and other desktop environments

See [docs/linux.md](docs/linux.md) for Linux-specific details.

### Windows

- Uses Windows Shell `IFileOperation` API for actual Recycle Bin integration
- Entry points: `srm.bat` and `srmi.bat`
- Works in Command Prompt (`cmd.exe`) and PowerShell
- Handles spaces, Unicode, and special characters in filenames
- Includes native C++ helper for Recycle Bin operations

See [WINDOWS.md](WINDOWS.md) for Windows-specific details.

## Safety and Limitations

### What srm Guarantees

- Files are moved to native Trash when possible
- No silent fallback to permanent deletion
- Accurate error reporting
- Protection against dangerous operations

### What srm Does NOT Guarantee

- Files are permanently safe (Trash can be emptied)
- Files can be recovered in all scenarios
- Cross-platform identical behavior
- Perfect atomicity on all filesystems

### Known Limitations

- Trash may be unavailable on some mounted volumes
- Network filesystems may not support Trash
- System administrators may have restricted Trash access
- Very long pathnames may fail on Windows
- Filename encoding issues may occur in some environments

See [SECURITY.md](SECURITY.md) for the complete security model and [FAQ.md](FAQ.md) for common questions.

## Comparison with rm

| Feature | rm | srm |
|---------|----|-----|
| Permanently deletes files | Yes | No |
| Moves to Trash | No | Yes |
| Recoverable | No | Yes (until Trash emptied) |
| `-r` recursive | Yes | Yes |
| `-f` force | Yes | Yes |
| `-v` verbose | Yes | Yes |
| Cross-platform | Yes | Yes |
| Requires network | No | No |

## Examples

### Removing Files

```bash
# Single file
srm document.txt

# Multiple files
srm *.log
srm file1.txt file2.txt file3.txt

# Force mode (no error for missing files)
srm -f *.tmp
```

### Removing Directories

```bash
# Empty directory
srm -d empty-dir/

# Non-empty directory (recursive)
srm -r project/

# Force recursive
srm -rf build/
```

### Verbose Output

```bash
srm -v document.txt
# Output: srm: moved 'document.txt' to Trash
```

### Handling Special Filenames

```bash
# Filename starting with hyphen
srm -- -help.txt

# Filename with spaces
srm "file with spaces.txt"

# Filename with special characters
srm 'file@#$%.txt'
```

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md) for development setup, architecture, and contribution guidelines.

## Testing

See [TESTING.md](TESTING.md) for test suite details and running tests.

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the BSD 3-Clause License. See [LICENSE](LICENSE) for details.

## Repository

https://github.com/live-by-unix/srm

## Website

https://live-by-unix.github.io/srm

## Author

live-by-unix

## Copyright

Copyright (c) 2026 live-by-unix
