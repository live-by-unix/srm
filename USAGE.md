# Usage Guide

This guide provides detailed usage instructions for srm.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Options](#options)
- [Examples](#examples)
- [Wildcards](#wildcards)
- [Special Filenames](#special-filenames)
- [Recursive Removal](#recursive-removal)
- [Interactive Mode](#interactive-mode)
- [Force Mode](#force-mode)
- [Verbose Mode](#verbose-mode)
- [Safety Features](#safety-features)
- [Exit Codes](#exit-codes)
- [Information Command](#information-command)

## Basic Usage

The basic syntax is:

```bash
srm [OPTION]... FILE...
```

Remove a single file:
```bash
srm document.txt
```

Remove multiple files:
```bash
srm file1.txt file2.txt file3.txt
```

## Options

| Short | Long | Description |
|-------|------|-------------|
| `-f` | `--force` | Ignore nonexistent files and arguments, never prompt |
| `-i` | `--interactive` | Prompt before every removal |
| `-I` | (none) | Prompt once before removing more than three files |
| `-r` | `--recursive` | Remove directories and their contents recursively |
| `-R` | `--recursive` | Same as `-r` |
| `-d` | `--dir` | Remove empty directories |
| `-v` | `--verbose` | Explain what is being done |
| (none) | `--preserve-root` | Fail if operating on `/` (default) |
| (none) | `--no-preserve-root` | Do not treat `/` specially |
| `--` | (none) | End of options |

## Examples

### Removing Files

**Single file:**
```bash
srm document.txt
```

**Multiple files:**
```bash
srm file1.txt file2.txt file3.txt
```

**All .log files:**
```bash
srm *.log
```

**Force mode (no error for missing files):**
```bash
srm -f *.tmp
```

**Verbose output:**
```bash
srm -v document.txt
# Output: srm: moved 'document.txt' to Trash
```

### Removing Directories

**Empty directory:**
```bash
srm -d empty-dir/
```

**Non-empty directory (recursive):**
```bash
srm -r project/
```

**Force recursive:**
```bash
srm -rf build/
```

**Verbose recursive:**
```bash
srm -rv project/
```

### Combining Options

Short options can be combined:
```bash
srm -rf build/
srm -fr build/
srm -rv project/
```

This is equivalent to:
```bash
srm -r -f build/
srm -f -r build/
srm -r -v project/
```

## Wildcards

Wildcards are expanded by the shell before srm sees them. This means:

**Bash/zsh:**
```bash
srm *.log           # Expanded by shell
srm logs/*.log      # Expanded by shell
srm **/*.py         # Requires globstar (bash: shopt -s globstar)
```

**PowerShell:**
```powershell
srm *.log           # PowerShell expands wildcards
srm *.txt
```

**Command Prompt:**
```cmd
srm *.log           # cmd.exe expands wildcards
```

**Important:** Wildcard behavior differs between shells. See your shell's documentation for details.

## Special Filenames

### Filenames Starting with Hyphen

Use `--` to mark the end of options:
```bash
srm -- -help.txt
srm -- -version.txt
srm -- --strange-name.txt
```

### Filenames with Spaces

Quote the filename:
```bash
srm "file with spaces.txt"
srm 'file with spaces.txt'
```

### Filenames with Special Characters

Quote or escape special characters:
```bash
srm "file@#$%.txt"
srm 'file[1].txt'
srm "file?.txt"
```

### Filenames with Quotes

In POSIX shells, escape quotes:
```bash
srm 'file'"'"'with quotes.txt'
```

In PowerShell:
```powershell
srm 'file"with"quotes.txt'
```

## Recursive Removal

Recursive removal moves the entire directory to Trash:

```bash
srm -r project/
```

The directory remains recoverable as a unit in Trash.

**Important:** Unlike `rm -r`, srm does not delete individual files inside the directory. It moves the directory as a whole to Trash.

### Cross-Filesystem Considerations

On Linux, if a directory is on a different filesystem from the Trash location, srm follows the FreeDesktop.org specification and creates a Trash directory on that filesystem.

On macOS, the NSFileManager API handles cross-filesystem operations automatically.

On Windows, the IFileOperation API handles cross-volume operations automatically.

## Interactive Mode

### Prompt Before Every Removal

```bash
srm -i file.txt
# Output: srm: remove regular file 'file.txt'? y
```

Type `y` or `yes` to confirm, anything else to skip.

### Prompt Once for Multiple Files

```bash
srm -I file1.txt file2.txt file3.txt file4.txt
# Output: srm: remove all arguments? y
```

This prompts only once if more than three files are specified.

### Interactive Mode Behavior

- If stdin is not a TTY, interactive mode fails
- EOF on stdin causes the prompt to fail
- Interactive mode respects `--force` (force disables prompts)

## Force Mode

Force mode suppresses errors for nonexistent files:

```bash
srm -f missing.txt
# No error output
```

Without force:
```bash
srm missing.txt
# Output: srm: cannot remove 'missing.txt': No such file or directory
```

**Important:** Force mode does NOT:
- Bypass the Trash-only guarantee
- Enable permanent deletion
- Remove files that cannot be moved to Trash

It only suppresses "file not found" errors.

## Verbose Mode

Verbose mode explains what is being done:

```bash
srm -v document.txt
# Output: srm: moved 'document.txt' to Trash

srm -v file1.txt file2.txt
# Output:
# srm: moved 'file1.txt' to Trash
# srm: moved 'file2.txt' to Trash
```

## Safety Features

### Root Protection

By default, srm protects against operating on dangerous paths:

```bash
srm -rf /
# Output: srm: it is dangerous to operate recursively on '/'
# Output: srm: use --no-preserve-root to override this failsafe
```

**To disable (not recommended):**
```bash
srm --no-preserve-root -rf /
```

**Warning:** `--no-preserve-root` does NOT enable permanent deletion. It only removes the root-path safety check.

### No Silent Permanent Deletion

srm will never silently fall back to permanent deletion:

```bash
srm file.txt
# If Trash is unavailable:
# Output: srm: failed to move 'file.txt' to Trash
# Exit code: 1
```

The file remains in place if Trash is unavailable.

### Error on Failure

All failures are reported with non-zero exit codes:

```bash
srm missing.txt
# Output: srm: cannot remove 'missing.txt': No such file or directory
# Exit code: 1
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (one or more files failed) |
| 2 | Usage error (invalid options) |

Check exit codes in scripts:
```bash
if srm file.txt; then
    echo "Success"
else
    echo "Failed"
fi
```

## Information Command

The `srmi` command provides information about srm:

```bash
# Display help
srmi --help

# Display version
srmi --version

# Display usage summary
srmi --usage

# Display license
srmi --license
```

**Important:** `srm --help` does NOT display help. It treats `--help` as a filename. Use `srmi --help` for documentation.

## Common Workflows

### Clean Build Artifacts

```bash
srm -rf build/
srm -rf dist/
srm *.o
```

### Remove Log Files

```bash
srm -v *.log
```

### Interactive Cleanup

```bash
srm -I *.tmp
```

### Remove with Verification

```bash
srm -v document.txt
```

## Platform-Specific Notes

See platform-specific documentation for details:
- [docs/macos.md](docs/macos.md) - macOS specific behavior
- [docs/linux.md](docs/linux.md) - Linux specific behavior
- [WINDOWS.md](WINDOWS.md) - Windows specific behavior

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

### "No such file or directory"

The file doesn't exist. Use `-f` to suppress this error if intentional:
```bash
srm -f file.txt
```

### "Is a directory"

Use `-r` for recursive removal:
```bash
srm -r directory/
```

## See Also

- [README.md](README.md) - Overview and quick start
- [INSTALL.md](INSTALL.md) - Installation instructions
- [WINDOWS.md](WINDOWS.md) - Windows-specific documentation
- [SECURITY.md](SECURITY.md) - Security model
