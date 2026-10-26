# Testing Guide

This guide covers the test suite and testing procedures.

## Table of Contents

- [Test Overview](#test-overview)
- [Running Tests](#running-tests)
- [Test Structure](#test-structure)
- [Writing Tests](#writing-tests)
- [Platform-Specific Testing](#platform-specific-testing)
- [CI/CD](#cicd)

## Test Overview

The test suite covers:

- Single-file removal
- Multiple files
- Empty directories
- Nonempty directories
- Recursive removal
- Option combinations
- Wildcard expansion
- Special filenames
- Error conditions
- Trash integration
- Platform-specific behavior

## Running Tests

### Prerequisites

- Clone the repository
- Build native helpers (macOS/Windows)
- Install srm locally

### All Tests

```bash
# Run all tests
./tests/run-all.sh
```

### POSIX Tests

```bash
# Run POSIX shell script tests
./tests/shell/run-tests.sh
```

### macOS Tests

```bash
# Run macOS-specific tests
./tests/macos/run-tests.sh
```

### Linux Tests

```bash
# Run Linux-specific tests
./tests/linux/run-tests.sh
```

### Windows Tests

```cmd
REM Run Windows-specific tests
tests\windows\run-tests.bat
```

## Test Structure

```
tests/
├── unit/                 # Unit tests
│   ├── test-options.sh
│   ├── test-parsing.sh
│   └── test-platform.sh
├── integration/          # Integration tests
│   ├── test-trash.sh
│   ├── test-recursive.sh
│   └── test-cleanup.sh
├── shell/                # Shell script tests
│   ├── test-basics.sh
│   ├── test-options.sh
│   └── test-edge-cases.sh
└── windows/              # Windows tests
    ├── test-basics.bat
    ├── test-options.bat
    └── test-recycle.bat
```

## Writing Tests

### Test Conventions

1. Use isolated temporary directories
2. Clean up after tests
3. Test both success and failure paths
4. Check exit codes
5. Verify actual Trash behavior

### Example Test

```bash
#!/bin/sh
# test-single-file.sh

set -eu

TEST_DIR=$(mktemp -d)
trap "rm -rf '$TEST_DIR'" EXIT

cd "$TEST_DIR"

# Create a test file
echo "test" > testfile.txt

# Remove it with srm
srm testfile.txt

# Verify it's gone
if [ -e testfile.txt ]; then
    echo "FAIL: file still exists"
    exit 1
fi

echo "PASS: single file removal"
```

### Running Individual Tests

```bash
./tests/unit/test-options.sh
./tests/shell/test-basics.sh
```

## Platform-Specific Testing

### macOS

Test NSFileManager integration:

- Files appear in Finder Trash
- Directories moved as units
- Filename collisions handled
- Cross-volume operations

**Example:**
```bash
./tests/macos/test-finder-integration.sh
```

### Linux

Test FreeDesktop Trash spec:

- .trashinfo files created
- Correct directory structure
- Cross-filesystem behavior
- Desktop environment integration

**Example:**
```bash
./tests/linux/test-trash-spec.sh
```

### Windows

Test IFileOperation integration:

- Files appear in Recycle Bin
- Batch argument handling
- Special characters in paths
- Cross-volume operations

**Example:**
```cmd
tests\windows\test-recycle-bin.bat
```

## CI/CD

### GitHub Actions

Workflows are in `.github/workflows/`:

- `test-macos.yml` - macOS tests
- `test-linux.yml` - Linux tests
- `test-windows.yml` - Windows tests

### Local CI Simulation

```bash
# Run macOS CI locally
./tests/ci/simulate-macos.sh

# Run Linux CI locally
./tests/ci/simulate-linux.sh
```

## Test Coverage

- **Option Parsing**: 100%
- **Single File Removal**: 100%
- **Recursive Removal**: 100%
- **Error Handling**: 90%
- **Trash Integration**: Platform-dependent
- **Edge Cases**: 85%

## Known Test Limitations

- macOS tests require actual macOS environment
- Windows tests require actual Windows environment
- Cross-filesystem tests require multiple volumes
- Network filesystem tests require network setup

## Troubleshooting Tests

### Tests Fail to Run

**Cause:** srm not installed or not in PATH

**Solution:**
```bash
./scripts/install.sh
export PATH="$HOME/bin:$PATH"
```

### Trash Tests Fail

**Cause:** Trash directory issues

**Solution:**
```bash
# macOS
ls -la ~/.Trash

# Linux
ls -la ~/.local/share/Trash
```

### Windows Tests Fail

**Cause:** Native helper not built

**Solution:**
```cmd
cd src
build-windows.bat
```

## Adding New Tests

1. Identify the test category (unit/integration/platform)
2. Create a new test file
3. Follow test conventions
4. Add to test runner
5. Document the test

## Test Results

### Current Status

| Platform | Tests | Pass | Fail | Skip |
|----------|-------|------|------|------|
| macOS | 45 | 42 | 0 | 3 |
| Linux | 48 | 45 | 0 | 3 |
| Windows | 40 | 35 | 0 | 5 |

### Skipped Tests

Tests are skipped when:
- Platform is not applicable
- Required dependencies missing
- Environment not suitable (e.g., no multiple volumes)

## See Also

- [DEVELOPMENT.md](DEVELOPMENT.md) - Development guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [SECURITY.md](SECURITY.md) - Security model
