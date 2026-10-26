# Security Policy

This document covers the security model and responsible disclosure.

## Security Model

### Core Principle

srm is designed to be a **safe** alternative to `rm`. The fundamental security principle is:

**Never silently fall back to permanent deletion.**

### Safety Guarantees

1. **Trash-Only Behavior**: Files are only moved to Trash, never permanently deleted
2. **No Silent Fallback**: If Trash is unavailable, the operation fails
3. **Root Protection**: Dangerous paths are protected by default
4. **Transparent Errors**: All failures are reported
5. **No Shell Injection**: Arguments are safely handled
6. **No Path Traversal**: Paths are validated
7. **Symlink Safety**: Symlinks are handled correctly

### Threat Model

srm protects against:

- Accidental permanent deletion
- Argument injection attacks
- Path traversal attacks
- Symlink confusion
- Time-of-check/time-of-use races
- Unsafe temporary files
- Malicious environment variables

srm does NOT protect against:

- Malicious root user
- Compromised Trash system
- Malicious operating system
- Physical access to the machine
- Compromised shell environment

## Security Considerations

### Shell Script Safety

The POSIX shell script:

- Uses `set -eu` for error detection
- Quotes all variable expansions
- Avoids `eval` for untrusted input
- Uses safe argument parsing
- Validates paths before operations

### macOS Helper Safety

The macOS native helper:

- Uses NSFileManager API (safe by design)
- Proper error handling
- No privilege escalation
- No network operations

### Windows Helper Safety

The Windows native helper:

- Uses IFileOperation API (safe by design)
- Proper COM handling
- No privilege escalation
- No network operations
- Validates paths

### Path Validation

srm validates:

- Absolute vs relative paths
- Dangerous root paths
- Symlink targets
- Path normalization
- Cross-filesystem operations

### Root Protection

By default, srm protects:

- `/` (root filesystem)
- Drive roots (Windows)
- Home directory root
- Other dangerous paths

This can be disabled with `--no-preserve-root`, but this does NOT enable permanent deletion.

## Known Security Limitations

### Trash Is Not Permanent Storage

Files in Trash can be:
- Emptied by the user
- Emptied by system cleanup
- Lost if Trash is corrupted
- Deleted if filesystem fails

### Platform Limitations

- Network filesystems may not support Trash
- Some volumes may not have Trash
- Recycle Bin may be disabled
- Trash may be full

### Attack Surface

- Shell script execution environment
- Native helper execution
- Trash directory permissions
- Path handling complexity

## Responsible Disclosure

### Reporting Security Issues

To report a security issue:

1. Do NOT open a public issue
2. Email: security@github.com (for the repository)
3. Include:
   - Description of the issue
   - Steps to reproduce
   - Impact assessment
   - Proposed fix (if known)

### Response Timeline

- Initial response: Within 48 hours
- Investigation: Within 1 week
- Fix: Within 2 weeks (depending on severity)
- Disclosure: After fix is released

### Security Updates

Security updates will be:
- Released as patches
- Documented in CHANGELOG.md
- Announced via GitHub releases
- Tagged with security advisory

## Best Practices for Users

1. **Understand the Limitations**: Trash is not permanent storage
2. **Regular Backups**: Important files should be backed up
3. **Review Trash Contents**: Before emptying Trash
4. **Check Permissions**: Ensure Trash directory is accessible
5. **Use Interactive Mode**: For important deletions: `srm -i`
6. **Verify Deletions**: Use verbose mode: `srm -v`

## Security Audit

The codebase has been reviewed for:

- Shell injection vulnerabilities
- Path traversal attacks
- Symlink attacks
- Race conditions
- Unsafe temporary files
- Incorrect permissions
- Environment variable attacks
- Buffer overflows (native helpers)
- Memory leaks (native helpers)
- COM errors (Windows)

## Compliance

srm follows:

- Principle of least privilege
- Secure by design principles
- Defense in depth
- Fail-safe defaults
- Transparent behavior

## Third-Party Dependencies

### macOS

- Foundation Framework (system framework)
- No external dependencies

### Linux

- No external dependencies
- Pure shell implementation

### Windows

- Shell32.lib (system library)
- Shlwapi.lib (system library)
- No external dependencies

## Contact

For security questions or concerns:
- Email: security@github.com
- Repository: https://github.com/live-by-unix/srm

## License

This project is licensed under the BSD 3-Clause License. See [LICENSE](LICENSE) for details.
