# Windows Documentation

This document covers Windows-specific aspects of srm.

## Table of Contents

- [Overview](#overview)
- [Entry Points](#entry-points)
- [Supported Shells](#supported-shells)
- [Installation](#installation)
- [Building the Native Helper](#building-the-native-helper)
- [Recycle Bin Integration](#recycle-bin-integration)
- [Path Handling](#path-handling)
- [Special Characters](#special-characters)
- [Limitations](#limitations)
- [Troubleshooting](#troubleshooting)

## Overview

srm on Windows uses the Windows Shell `IFileOperation` API to move files to the actual Windows Recycle Bin. This provides:

- True Recycle Bin integration
- Files appear in the standard Recycle Bin
- Directory preservation
- Cross-volume support
- Filename collision handling

## Entry Points

Windows uses batch-script entry points:

- `srm.bat` - Removal command
- `srmi.bat` - Information command

These batch files delegate to a native C++ helper (`srm-windows.exe`) that performs the actual Recycle Bin operations.

## Supported Shells

### Command Prompt (cmd.exe)

Full support. Wildcards are expanded by cmd.exe before reaching srm.

```cmd
srm.bat document.txt
srm.bat *.log
srm.bat -r project\
```

### PowerShell

Full support. PowerShell has its own wildcard expansion.

```powershell
srm.bat document.txt
srm.bat *.log
srm.bat -r project\
```

**Note:** PowerShell also has a native `Remove-Item` cmdlet. Use `srm.bat` explicitly to avoid confusion.

### Git Bash / MSYS2

Git Bash provides a Unix-like environment. Use the POSIX `srm` script instead of `srm.bat`:

```bash
srm document.txt
srm -r project/
```

The POSIX script will detect the Windows environment and handle appropriately.

### Windows Terminal

Windows Terminal is a terminal host, not a shell. It can host:
- Command Prompt
- PowerShell
- Git Bash
- WSL

Use the appropriate entry point for your shell.

## Installation

### Prerequisites

- Windows 7 or later
- Visual Studio 2015 or later (for building the native helper)

### Building the Native Helper

1. Install Visual Studio or Build Tools for Visual Studio
2. Open a Developer Command Prompt
3. Navigate to the srm source directory
4. Build the helper:

```cmd
cd src
build-windows.bat
```

This compiles `srm-windows.cpp` using the Visual Studio compiler.

### User-Local Installation

```cmd
scripts\install.bat
```

This installs to `%USERPROFILE%\bin` and optionally adds to PATH.

### System-Wide Installation

```cmd
scripts\uninstall.bat --system
```

This installs to `C:\Program Files\srm` and adds to system PATH.

### PATH Configuration

Manual PATH configuration:

1. Press Win key, search for "Environment Variables"
2. Click "Edit the system environment variables"
3. Click "Environment Variables"
4. Under "User variables", find "Path" and click "Edit"
5. Click "New" and add: `%USERPROFILE%\bin`
6. Click OK on all dialogs

## Recycle Bin Integration

srm uses the Windows Shell `IFileOperation` API:

- **API**: IFileOperation with `FOFX_RECYCLEONDELETE` flag
- **Supported**: Windows Vista and later
- **Behavior**: Files appear in the actual Windows Recycle Bin
- **UI**: No confirmation dialogs (FOF_NO_UI flag)
- **Safety**: Pre-delete checks ensure files can be recycled

### How It Works

1. The batch script invokes `srm-windows.exe` with arguments
2. The native helper initializes COM
3. Creates an IFileOperation object
4. Sets operation flags (no UI, recycle on delete)
5. Declares delete operations for each file
6. Performs operations
7. Reports success/failure

### Cross-Volume Behavior

The IFileOperation API handles cross-volume operations automatically. Files on different drives are moved to the appropriate Recycle Bin for that drive.

### Subst Drives

Subst drives (virtual drives created with `subst`) may not have a Recycle Bin. The helper detects subst drives and reports failure appropriately.

## Path Handling

### Spaces in Paths

Paths with spaces must be quoted:

```cmd
srm.bat "file with spaces.txt"
srm.bat "C:\Program Files\temp\file.txt"
```

### Backslashes vs Forward Slashes

Windows uses backslashes, but forward slashes are often accepted:

```cmd
srm.bat C:\temp\file.txt
srm.bat C:/temp/file.txt
```

However, backslashes are preferred for consistency.

### Long Paths

Windows has a MAX_PATH limitation (260 characters). Very long paths may fail. Windows 10 version 1607 and later supports long paths with registry configuration.

### UNC Paths

UNC paths (network paths) are supported if the network drive has a Recycle Bin:

```cmd
srm.bat \\server\share\file.txt
```

Network drives may not support Recycle Bin operations.

## Special Characters

### Characters with Special Meaning in cmd.exe

These characters require careful handling:

- `&` - Command separator
- `|` - Pipe
- `>` - Redirect output
- `<` - Redirect input
- `^` - Escape character
- `%` - Variable expansion
- `!` - Delayed expansion (when enabled)
- `(` and `)` - Grouping

**Best practice:** Always quote filenames with special characters:

```cmd
srm.bat "file&name.txt"
srm.bat "file|name.txt"
srm.bat "file%name.txt"
```

### Parentheses

Parentheses require quoting:

```cmd
srm.bat "file(1).txt"
```

### Percent Signs

Percent signs require quoting:

```cmd
srm.bat "file%name.txt"
```

### Exclamation Marks

When delayed expansion is enabled, exclamation marks are special. Quote them:

```cmd
srm.bat "file!name.txt"
```

### Quotation Marks

Filenames with quotes require escaping:

```cmd
srm.bat file^"name.txt
```

Or use batch escaping:

```cmd
srm.bat "file""name.txt"
```

## Options

Windows supports the same options as POSIX:

```cmd
srm.bat -f document.txt
srm.bat -r project\
srm.bat -rf build\
srm.bat -v *.log
srm.bat -- -help.txt
```

### Option Combinations

Short options can be combined:

```cmd
srm.bat -rf build\
srm.bat -fr build\
srm.bat -rv project\
```

### Long Options

Long options are supported:

```cmd
srm.bat --force document.txt
srm.bat --recursive project\
srm.bat --verbose *.log
```

## Limitations

### No Native Helper

If `srm-windows.exe` is not found, srm.bat will fail with an error:

```
srm: error: Windows helper not found: srm-windows.exe
srm: Please run the installation script to set up the complete system.
```

**Solution:** Build the native helper using `src\build-windows.bat`.

### Network Drives

Network drives may not support Recycle Bin operations. srm will fail appropriately rather than permanently deleting.

### Subst Drives

Subst drives (virtual drives) may not have a Recycle Bin. The helper detects this and reports failure.

### MAX_PATH Limitation

Very long paths (over 260 characters) may fail. This is a Windows limitation.

### Locked Files

Files locked by other processes cannot be moved to the Recycle Bin. srm will report failure.

### Administrative Privileges

Some system files may require administrative privileges to delete. srm will report failure if permissions are insufficient.

## Troubleshooting

### "Windows helper not found"

**Cause:** `srm-windows.exe` is not in the same directory as `srm.bat`.

**Solution:** Build the native helper:
```cmd
cd src
build-windows.bat
```

### Build fails with "cl.exe not found"

**Cause:** Visual Studio compiler is not in PATH.

**Solution:**
1. Install Visual Studio or Build Tools for Visual Studio
2. Open a Developer Command Prompt (not a regular cmd.exe)
3. Run the build script

### Files not appearing in Recycle Bin

**Possible causes:**
- Helper not built correctly
- File on network drive without Recycle Bin
- File on subst drive
- Insufficient permissions
- File locked by another process

**Solution:**
- Verify helper was built successfully
- Check file location
- Check permissions
- Close other applications that may be using the file

### "operation was aborted"

**Cause:** The IFileOperation aborted the operation, typically because the file cannot be recycled.

**Solution:** Check the file location and permissions. Network drives and subst drives may not support Recycle Bin.

### Path with spaces not working

**Cause:** Unquoted path with spaces.

**Solution:** Quote the path:
```cmd
srm.bat "file with spaces.txt"
```

### Batch script not recognizing arguments

**Cause:** Complex argument combinations or special characters.

**Solution:** Quote arguments and use `--` for filenames starting with hyphens:
```cmd
srm.bat -- -help.txt
srm.bat "file&name.txt"
```

## Testing

Test your installation:

```cmd
REM Create a test file
echo test > %TEMP%\testfile.txt

REM Remove it
srm.bat %TEMP%\testfile.txt

REM Check Recycle Bin
start shell:RecycleBinFolder
```

The file should appear in the Recycle Bin.

## Comparison with Other Tools

| Tool | Recycle Bin | Cross-Platform | Native API |
|------|-------------|----------------|------------|
| srm.bat | Yes | Yes | IFileOperation |
| del | No | N/A | Win32 API |
| Remove-Item | No | N/A | .NET |
| recycle-bin (npm) | Yes | No | IFileOperation |

## See Also

- [README.md](README.md) - Project overview
- [INSTALL.md](INSTALL.md) - Installation instructions
- [USAGE.md](USAGE.md) - General usage
- [docs/windows.md](docs/windows.md) - Detailed Windows documentation
- [SECURITY.md](SECURITY.md) - Security model
