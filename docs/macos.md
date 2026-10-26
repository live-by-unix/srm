# macOS Documentation

This document covers macOS-specific aspects of srm.

## Overview

srm on macOS uses the NSFileManager API to move files to the Finder Trash. This provides native integration with the macOS Trash system.

## Implementation

### Native Helper

The macOS implementation uses a native Objective-C helper (`srm-macos`) compiled from `src/srm-macos.m`.

**API Used:**
```objective-c
[NSFileManager trashItemAtURL:resultingItemURL:error:]
```

This API:
- Moves items to the actual Finder Trash
- Handles filename collisions automatically
- Returns the resulting Trash URL
- Reports errors appropriately

### Building the Helper

```bash
cd src
./build-macos.sh
```

This compiles the Objective-C source using clang and the Foundation framework.

## Trash Location

### Standard Location

- **Path:** `~/.Trash`
- **Visibility:** Finder Trash
- **Format:** Standard macOS Trash

### Multiple Volumes

For external drives, macOS may create a Trash directory on the volume itself. The NSFileManager API handles this automatically.

## Behavior

### File Removal

When you run:

```bash
srm document.txt
```

srm:
1. Calls the native helper
2. Helper uses NSFileManager to move the file to Trash
3. File appears in Finder Trash
4. Success is reported

### Directory Removal

When you run:

```bash
srm -r project/
```

srm:
1. Calls the native helper
2. Helper uses NSFileManager to move the directory to Trash
3. Directory appears in Finder Trash as a unit
4. Success is reported

**Important:** The directory is moved as a whole, not as individual files.

### Filename Collisions

If a file with the same name already exists in Trash, NSFileManager automatically renames the new file to avoid collisions. The API returns the resulting Trash URL with the new name.

### Cross-Volume Operations

NSFileManager handles cross-volume operations automatically. Files on external drives are moved to the appropriate Trash location for that drive.

## Compatibility

### macOS Versions

| Version | Status | Notes |
|---------|--------|-------|
| macOS 10.8+ | ✓ Full | NSFileManager Trash API available |
| macOS 10.7 and earlier | ✗ Not supported | Trash API not available |

### Filesystems

| Filesystem | Status | Notes |
|------------|--------|-------|
| APFS | ✓ Full | Native support |
| HFS+ | ✓ Full | Native support |
| ExFAT | ✓ Full | Native support |
| FAT32 | ✓ Full | Native support |
| NTFS | ✓ Full | With drivers |
| Network drives | ⚠ Partial | Depends on mount |

## Troubleshooting

### "Trash directory not found"

This is unusual on macOS. Verify:

```bash
ls -la ~/.Trash
```

If it doesn't exist, macOS will create it automatically when needed.

### "Failed to move to Trash"

**Possible causes:**
- File is locked
- Insufficient permissions
- Filesystem doesn't support Trash
- File is in use

**Solutions:**
- Check file permissions: `ls -l file.txt`
- Check if file is locked in Finder (Get Info)
- Close applications that may be using the file
- Check filesystem type

### Helper not found

**Cause:** The native helper wasn't built or installed.

**Solution:**
```bash
cd src
./build-macos.sh
cd ..
./scripts/install.sh
```

## Performance

NSFileManager is efficient for Trash operations. Performance characteristics:

- Single file: Instantaneous
- Directory: Depends on size (typically fast)
- Large files: May take time to move
- External drives: Slower than internal

## Security

The NSFileManager API is safe by design:

- No privilege escalation
- System-managed permissions
- Sandboxed behavior where applicable
- No network operations

## Integration

### Finder Integration

Files moved by srm appear in Finder Trash exactly like files deleted via Finder.

### Terminal Integration

srm works seamlessly in Terminal and other terminal emulators.

### Script Integration

srm can be used in shell scripts:

```bash
#!/bin/sh
if srm old_logs/*.log; then
    echo "Logs cleaned successfully"
else
    echo "Failed to clean logs"
fi
```

## See Also

- [README.md](../README.md) - Project overview
- [INSTALL.md](../INSTALL.md) - Installation instructions
- [USAGE.md](../USAGE.md) - General usage
- [SECURITY.md](../SECURITY.md) - Security model
