# Frequently Asked Questions

## General

### What is srm?

srm (Safe RM) is a cross-platform alternative to `rm` that moves files to the native Trash or Recycle Bin instead of permanently deleting them.

### Why not just use rm?

`rm` permanently deletes files, which cannot be recovered. srm provides a safety layer by moving files to Trash, where they can be recovered if needed.

### Is srm a drop-in replacement for rm?

For most common use cases, yes. srm supports the same options and behaves similarly. However, srm moves files to Trash instead of permanently deleting them.

### Does srm guarantee files are recoverable?

No. Trash can be emptied, storage can fail, filesystems can become unavailable, and platform restrictions may prevent recovery. srm provides a safety layer, not a guarantee.

### Is srm secure?

srm is designed with security in mind. It never silently falls back to permanent deletion, protects against dangerous operations, and handles arguments safely. See [SECURITY.md](SECURITY.md) for details.

## Usage

### How do I use srm?

Use it like `rm`:

```bash
srm file.txt
srm -r directory/
srm -rf build/
```

### Why doesn't `srm --help` show help?

`--help` and `--version` are NOT reserved options in srm. They are treated as ordinary filenames. Use `srmi --help` for documentation.

### How do I get help?

Use the information command:

```bash
srmi --help
```

### How do I see the version?

```bash
srmi --version
```

### Can I remove multiple files at once?

Yes:

```bash
srm file1.txt file2.txt file3.txt
```

### Can I use wildcards?

Yes, wildcards are expanded by your shell:

```bash
srm *.log
srm *.tmp
```

### How do I remove a directory?

Use `-r` for recursive removal:

```bash
srm -r directory/
```

### How do I suppress errors for missing files?

Use `-f` (force):

```bash
srm -f missing.txt
```

This does NOT enable permanent deletion; it only suppresses "file not found" errors.

### How do I see what's being done?

Use `-v` (verbose):

```bash
srm -v file.txt
```

### How do I prompt before removing?

Use `-i` (interactive):

```bash
srm -i file.txt
```

### How do I remove a file named `-help`?

Use `--` to mark the end of options:

```bash
srm -- -help
```

## Platform-Specific

### macOS

#### Does srm work with Finder Trash?

Yes, srm uses the NSFileManager API to move files to the actual Finder Trash.

#### What macOS version is required?

macOS 10.8 or later, for NSFileManager Trash API support.

#### Do I need to build anything?

Yes, you need to build the macOS native helper:

```bash
cd src
./build-macos.sh
```

#### Can I recover files from Trash?

Yes, through Finder or the standard Trash interface.

### Linux

#### Does srm work with GNOME/KDE/XFCE?

Yes, srm implements the FreeDesktop.org Trash specification, which is supported by GNOME, KDE, XFCE, and most modern desktop environments.

#### Where is Trash located?

By default: `~/.local/share/Trash`

This respects `$XDG_DATA_HOME` if set.

#### Do I need to build anything?

No, the Linux implementation is pure shell script.

#### Can I recover files from Trash?

Yes, through your desktop environment's Trash interface or manually from `~/.local/share/Trash/files`.

### Windows

#### Do I use srm or srm.bat?

On Windows, use `srm.bat` (and `srmi.bat` for information).

#### Does srm work with PowerShell?

Yes, `srm.bat` works in PowerShell.

#### Does srm work in Git Bash?

In Git Bash, use the POSIX `srm` script instead of `srm.bat`.

#### Do I need to build anything?

Yes, you need to build the Windows native helper:

```cmd
cd src
build-windows.bat
```

This requires Visual Studio or Build Tools for Visual Studio.

#### Do files appear in the Recycle Bin?

Yes, srm uses the IFileOperation API to move files to the actual Windows Recycle Bin.

#### What Windows version is required?

Windows Vista or later, for IFileOperation API support.

## Installation

### How do I install srm?

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

**macOS/Linux:**
```bash
./scripts/install.sh
```

**Windows:**
```cmd
scripts\install.bat
```

### Do I need administrator privileges?

For user-local installation, no. For system-wide installation, yes.

### How do I uninstall?

**macOS/Linux:**
```bash
./scripts/uninstall.sh
```

**Windows:**
```cmd
scripts\uninstall.bat
```

### Does uninstallation empty Trash?

No. Uninstallation removes only srm files. Your Trash contents remain intact.

## Troubleshooting

### "Failed to move to Trash"

**Possible causes:**
- Trash directory doesn't exist or is inaccessible
- Insufficient permissions
- Filesystem doesn't support Trash
- File is locked by another process

**Solutions:**
- Check Trash directory permissions
- Ensure you have write access
- Check if file is in use
- See platform-specific documentation

### "Windows helper not found"

**Cause:** The native helper (`srm-windows.exe`) is not built or not in the correct location.

**Solution:** Build the helper:
```cmd
cd src
build-windows.bat
```

### Build fails on Windows

**Cause:** Visual Studio compiler not in PATH.

**Solution:**
1. Install Visual Studio or Build Tools for Visual Studio
2. Open a Developer Command Prompt
3. Run the build script

### Files not appearing in Trash/Recycle Bin

**Possible causes:**
- Helper not built correctly
- File on network drive without Trash support
- File on subst drive (Windows)
- Insufficient permissions

**Solutions:**
- Verify helper was built successfully
- Check file location
- Check permissions

### "Permission denied"

**Cause:** The script is not executable.

**Solution:**
```bash
chmod +x srm srmi
```

### "Command not found"

**Cause:** srm is not in your PATH.

**Solution:** Add the installation directory to your PATH, or use the full path:
```bash
~/bin/srm file.txt
```

## Limitations

### What are the limitations?

- Trash may be unavailable on some mounted volumes
- Network filesystems may not support Trash
- System administrators may have restricted Trash access
- Very long pathnames may fail on Windows (MAX_PATH)
- Filename encoding issues may occur in some environments
- Files in Trash can be emptied (not permanent storage)

### Does srm work on network drives?

It depends on the platform and filesystem. Some network drives may not support Trash. srm will fail appropriately rather than permanently deleting.

### Does srm work on subst drives (Windows)?

Subst drives may not have a Recycle Bin. srm will detect this and report failure.

### Can srm recover deleted files?

No, srm only moves files to Trash. It cannot recover files that were permanently deleted by other means.

## Development

### How can I contribute?

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

### How do I report a bug?

Open an issue on GitHub: https://github.com/live-by-unix/srm/issues

### How do I request a feature?

Open an issue on GitHub with the "enhancement" label.

### Is srm open source?

Yes, srm is open source under the BSD 3-Clause License.

## License

### What license is srm under?

BSD 3-Clause License. See [LICENSE](LICENSE) for details.

### Can I use srm in commercial projects?

Yes, the BSD 3-Clause License permits commercial use.

### Can I modify srm?

Yes, the BSD 3-Clause License permits modification.

### Do I have to credit the authors?

Yes, the BSD 3-Clause License requires preserving the copyright notice.

## Other

### Where can I get more information?

- [README.md](README.md) - Overview and quick start
- [INSTALL.md](INSTALL.md) - Installation instructions
- [USAGE.md](USAGE.md) - Detailed usage guide
- [WINDOWS.md](WINDOWS.md) - Windows-specific documentation
- [docs/](docs/) - Platform-specific documentation

### Is there a website?

Yes: https://live-by-unix.github.io/srm

### Who is the author?

live-by-unix

### What is the copyright year?

2026
