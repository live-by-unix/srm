# Windows Detailed Documentation

This document provides detailed Windows-specific information for srm.

## Architecture

### Component Stack

```
User
  │
  ├─► srm.bat (Batch Script)
  │       │
  │       └─► srm-windows.exe (C++ Helper)
  │               │
  │               └─► IFileOperation API (Windows Shell)
  │                       │
  │                       └─► Recycle Bin
```

### Batch Script Responsibilities

- Check for native helper
- Forward arguments to helper
- Propagate exit codes
- Report missing helper

### Native Helper Responsibilities

- Parse command-line arguments
- Initialize COM
- Create IFileOperation object
- Set operation flags
- Declare delete operations
- Perform operations
- Report results

## Windows Shell API

### IFileOperation

srm uses the IFileOperation interface introduced in Windows Vista.

**Key Features:**
- Delete with recycle semantics
- Progress feedback
- Error handling
- Cross-volume support
- No UI mode available

### Operation Flags

srm uses these flags:

```cpp
FOF_NO_UI | FOF_NOCONFIRMATION | FOFX_RECYCLEONDELETE
```

- `FOF_NO_UI`: No user interface
- `FOF_NOCONFIRMATION`: No confirmation dialogs
- `FOFX_RECYCLEONDELETE`: Recycle instead of permanent delete

### COM Initialization

The helper initializes COM as:

```cpp
CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
```

This provides:
- Single-threaded apartment
- OLE1 DDE disabled (security)

## Path Handling

### Path Types

| Type | Example | Notes |
|------|---------|-------|
| Absolute | `C:\temp\file.txt` | Full path |
| Relative | `file.txt` | Relative to current directory |
| UNC | `\\server\share\file.txt` | Network path |
| Drive root | `C:\` | Protected |
| Subst | `X:\file.txt` | May not support Recycle Bin |

### Path Conversion

The helper converts UTF-8 arguments to UTF-16 for Windows API:

```cpp
wchar_t* path = UTF8ToUTF16(argv[i]);
```

### Long Paths

Windows has a MAX_PATH limitation of 260 characters. Windows 10 version 1607+ supports long paths with:

- Registry configuration
- Application manifest

srm does not currently enable long path support.

## Recycle Bin Behavior

### Per-Drive Recycle Bins

Windows maintains separate Recycle Bins for each drive:

- `C:\$Recycle.Bin\`
- `D:\$Recycle.Bin\`
- etc.

IFileOperation automatically routes files to the correct Recycle Bin.

### Filename Collisions

Windows handles filename collisions in the Recycle Bin automatically by appending information.

### Volume Information

The Recycle Bin tracks:
- Original location
- Deletion time
- File size
- Original name

## Special Cases

### Subst Drives

Subst drives (created with `subst`) are virtual drives that may not have a Recycle Bin.

**Detection:**
```cpp
QueryDosDeviceW(drive, target, MAX_PATH);
```

Subst drives return a target starting with `\??\`.

**Behavior:** srm reports failure for subst drives rather than permanently deleting.

### Network Drives

Network drives may or may not support Recycle Bin operations.

**Behavior:** IFileOperation reports failure if Recycle Bin is unavailable.

### System Files

Some system files require elevated privileges.

**Behavior:** srm reports failure if permissions are insufficient.

### Locked Files

Files locked by other processes cannot be recycled.

**Behavior:** IFileOperation reports failure.

## Building

### Prerequisites

- Visual Studio 2015 or later
- Windows SDK
- Developer Command Prompt

### Build Process

```cmd
cl.exe /EHsc /O2 /Fe:srm-windows.exe srm-windows.cpp shell32.lib shlwapi.lib
```

**Compiler Options:**
- `/EHsc`: Exception handling
- `/O2`: Optimization
- `/Fe`: Output filename

**Libraries:**
- `shell32.lib`: Shell API
- `shlwapi.lib`: Shell lightweight utilities

### Build Troubleshooting

**"cl.exe not found"**
- Open Developer Command Prompt, not regular cmd.exe
- Install Visual Studio Build Tools

**"Cannot open shell32.lib"**
- Ensure Windows SDK is installed
- Check INCLUDE and LIB environment variables

## Installation

### User-Local Installation

```cmd
scripts\install.bat
```

Installs to:
- `%USERPROFILE%\bin\srm.bat`
- `%USERPROFILE%\bin\srmi.bat`
- `%USERPROFILE%\bin\srm-windows.exe`

### System-Wide Installation

```cmd
scripts\install.bat --system
```

Installs to:
- `C:\Program Files\srm\srm.bat`
- `C:\Program Files\srm\srmi.bat`
- `C:\Program Files\srm\srm-windows.exe`

Adds to system PATH.

### PATH Configuration

The installation script can optionally add to PATH. Manual configuration:

1. Win key → "Environment Variables"
2. Edit system or user PATH
3. Add installation directory

## Shell Compatibility

### Command Prompt (cmd.exe)

**Wildcards:** Expanded by cmd.exe

```cmd
srm.bat *.log
```

**Quoting:** Required for spaces

```cmd
srm.bat "file with spaces.txt"
```

**Special Characters:** Quote them

```cmd
srm.bat "file&name.txt"
```

### PowerShell

**Wildcards:** Expanded by PowerShell

```powershell
srm.bat *.log
```

**Quoting:** Both ' and " work

```powershell
srm.bat "file with spaces.txt"
srm.bat 'file with spaces.txt'
```

**Special Characters:** Quote them

```powershell
srm.bat "file`$name.txt"
```

### Git Bash

**Recommendation:** Use POSIX `srm` script instead of `srm.bat`

```bash
srm document.txt
```

## Security

### COM Security

COM is initialized with:
- No OLE1 DDE (security)
- Single-threaded apartment (stable)

### Path Validation

Paths are validated before operations:
- Absolute vs relative
- Symlink resolution (where applicable)
- Drive type detection

### No Elevation

srm does not request elevation. It operates at user privileges.

## Performance

IFileOperation is efficient:

- Single file: Fast
- Directory: Depends on size
- Cross-volume: May be slower
- Network: Depends on network speed

## Debugging

### Enable Debug Output

Add logging to `srm-windows.cpp`:

```cpp
fwprintf(stderr, L"Debug: %s\n", message);
```

### Visual Studio Debugger

1. Open project in Visual Studio
2. Set breakpoints
3. F5 to debug

## Error Codes

| HRESULT | Meaning |
|---------|---------|
| S_OK | Success |
| E_FAIL | General failure |
| HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND) | File not found |
| HRESULT_FROM_WIN32(ERROR_ACCESS_DENIED) | Access denied |
| Other | Various Windows errors |

## See Also

- [README.md](../README.md) - Project overview
- [WINDOWS.md](../WINDOWS.md) - Windows overview
- [INSTALL.md](../INSTALL.md) - Installation instructions
- [SECURITY.md](../SECURITY.md) - Security model
- [IFileOperation Documentation](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nn-shobjidl_core-ifileoperation)
