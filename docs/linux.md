# Linux Documentation

This document covers Linux-specific aspects of srm.

## Overview

srm on Linux implements the FreeDesktop.org Trash specification. This provides compatibility with GNOME, KDE, XFCE, and other desktop environments that support the spec.

## Implementation

### Trash Specification

srm implements version 1.0 of the FreeDesktop.org Trash specification:

https://specifications.freedesktop.org/trash/latest/

### Pure Shell Implementation

The Linux implementation is pure shell script—no native helper is required. The shell script:

- Creates Trash directory structure
- Generates .trashinfo metadata files
- Handles cross-filesystem operations
- Handles filename collisions

## Trash Location

### Home Trash

**Default location:** `~/.local/share/Trash`

**Structure:**
```
~/.local/share/Trash/
├── files/        # Actual trashed files
└── info/         # .trashinfo metadata files
```

**XDG Compliance:**
- Respects `$XDG_DATA_HOME` if set
- Falls back to `~/.local/share` if not set

### Volume Trash

For external filesystems, Trash may be created at:
```
/mountpoint/.Trash-$uid/
├── files/
└── info/
```

Where `$uid` is the user's numeric user ID.

## .trashinfo Format

Each trashed file has a corresponding .trashinfo file:

```ini
[Trash Info]
Path=/absolute/path/to/original/file
DeletionDate=2026-10-26T15:30:00
```

### Path Encoding

The original path is stored as an absolute path with URL encoding for special characters.

### Deletion Date

Format: ISO 8601 (`YYYY-MM-DDTHH:MM:SS`)

## Behavior

### File Removal

When you run:

```bash
srm document.txt
```

srm:
1. Determines Trash location
2. Creates Trash structure if needed
3. Generates unique filename in Trash/files
4. Creates .trashinfo metadata
5. Moves file to Trash
6. Reports success

### Directory Removal

When you run:

```bash
srm -r project/
```

srm:
1. Determines Trash location
2. Creates Trash structure if needed
3. Generates unique directory name in Trash/files
4. Creates .trashinfo metadata
5. Moves directory to Trash as a unit
6. Reports success

**Important:** The directory is moved as a whole, not as individual files.

### Filename Collisions

srm handles collisions by appending a counter:

- Original: `document.txt`
- Collision 1: `document.txt.1`
- Collision 2: `document.txt.2`
- And so on...

### Cross-Filesystem Operations

If a file is on a different filesystem from the home Trash, srm follows the spec and creates a Trash directory on that filesystem at `.Trash-$uid`.

## Desktop Environment Compatibility

### GNOME

**Status:** ✓ Full support

GNOME implements the FreeDesktop Trash spec. Files moved by srm appear in GNOME Files (Nautilus) Trash.

### KDE

**Status:** ✓ Full support

KDE implements the FreeDesktop Trash spec. Files moved by srm appear in Dolphin Trash.

### XFCE

**Status:** ✓ Full support

XFCE implements the FreeDesktop Trash spec. Files moved by srm appear in Thunar Trash.

### Other Desktop Environments

Any desktop environment that implements the FreeDesktop Trash spec will show files moved by srm.

### Window Managers

Window managers (i3, Openbox, etc.) may not have a Trash UI, but the Trash directory structure is still created and files can be recovered manually.

## Compatibility

### Distributions

| Distribution | Status | Notes |
|--------------|--------|-------|
| Ubuntu | ✓ Full | Full spec support |
| Debian | ✓ Full | Full spec support |
| Fedora | ✓ Full | Full spec support |
| Arch Linux | ✓ Full | Full spec support |
| openSUSE | ✓ Full | Full spec support |
| RHEL/CentOS | ✓ Full | Full spec support |

### Filesystems

| Filesystem | Status | Notes |
|------------|--------|-------|
| ext4 | ✓ Full | Native support |
| ext3 | ✓ Full | Native support |
| xfs | ✓ Full | Native support |
| btrfs | ✓ Full | Native support |
| NTFS | ✓ Full | With driver |
| FAT32 | ✓ Full | With driver |
| exFAT | ✓ Full | With driver |
| Network drives | ⚠ Partial | Depends on mount |

## Troubleshooting

### "Failed to create Trash directory"

**Cause:** No write permission to `~/.local/share`

**Solution:**
```bash
mkdir -p ~/.local/share/Trash/files
mkdir -p ~/.local/share/Trash/info
```

### Trash not appearing in desktop environment

**Possible causes:**
- Desktop environment doesn't support FreeDesktop spec
- Trash location is non-standard
- Desktop environment needs restart

**Solutions:**
- Verify Trash structure: `ls -la ~/.local/share/Trash`
- Check desktop environment documentation
- Restart desktop environment

### Cross-filesystem files not going to correct Trash

**Cause:** Volume Trash creation failed

**Solution:**
- Check mount point permissions
- Verify filesystem supports Trash
- Check user ID on volume

## Manual Recovery

You can manually recover files from Trash:

```bash
# List Trash contents
ls -la ~/.local/share/Trash/files

# View .trashinfo for a file
cat ~/.local/share/Trash/info/filename.txt.trashinfo

# Restore a file
mv ~/.local/share/Trash/files/filename.txt /original/path/
```

## Performance

Shell implementation performance:

- Single file: Fast (file system move)
- Directory: Depends on size
- Large files: May take time to move
- Cross-filesystem: Slower than same-filesystem

## Security

The shell implementation is safe:

- No privilege escalation
- User permissions only
- No network operations
- Safe path handling

## Integration

### Terminal Integration

srm works seamlessly in all terminal emulators.

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

### Desktop Integration

Files moved by srm appear in desktop environment Trash if the environment supports the FreeDesktop spec.

## Environment Variables

### XDG_DATA_HOME

Overrides the base directory for user data:

```bash
export XDG_DATA_HOME=/custom/path
```

Trash will be at `$XDG_DATA_HOME/Trash`.

### HOME

Standard home directory. Trash is at `$HOME/.local/share/Trash` unless `$XDG_DATA_HOME` is set.

## See Also

- [README.md](../README.md) - Project overview
- [INSTALL.md](../INSTALL.md) - Installation instructions
- [USAGE.md](../USAGE.md) - General usage
- [FreeDesktop Trash Spec](https://specifications.freedesktop.org/trash/latest/)
- [SECURITY.md](../SECURITY.md) - Security model
