#!/bin/sh
# Basic shell script tests
# Copyright (c) 2026 live-by-unix
# BSD 3-Clause License

set -eu

# Setup - get absolute paths first
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRM="$PROJECT_DIR/srm"
SRMI="$PROJECT_DIR/srmi"

# Make sure scripts are executable
chmod +x "$SRM" "$SRMI"

# Test directory
TEST_DIR=$(mktemp -d)
trap "rm -rf '$TEST_DIR'" EXIT

cd "$TEST_DIR"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test functions
run_test() {
    name="$1"
    TESTS_RUN=$((TESTS_RUN + 1))
    echo "Running: $name"
    if shift && "$@"; then
        echo "  PASS"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  FAIL"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test: Single file removal
run_test "Single file removal" bash -c "
    echo 'test' > file.txt
    $SRM file.txt
    [ ! -e file.txt ]
"

# Test: Missing file (should fail)
run_test "Missing file (should fail)" bash -c "
    $SRM nonexistent.txt 2>/dev/null
    [ \$? -ne 0 ]
"

# Test: Missing file with -f (should succeed)
run_test "Missing file with -f (should succeed)" bash -c "
    $SRM -f nonexistent.txt 2>/dev/null
    [ \$? -eq 0 ]
"

# Test: srmi --version
run_test "srmi --version" bash -c "
    $SRMI --version | grep -q 'srm'
"

# Test: srmi --help
run_test "srmi --help" bash -c "
    $SRMI --help | grep -q 'Safe RM'
"

# Test: srmi --usage
run_test "srmi --usage" bash -c "
    $SRMI --usage | grep -q 'Usage'
"

# Test: srmi --license
run_test "srmi --license" bash -c "
    $SRMI --license | grep -q 'BSD'
"

# Test: srmi invalid option
run_test "srmi invalid option" bash -c "
    $SRMI --invalid 2>/dev/null
    [ \$? -ne 0 ]
"

# Summary
echo ""
echo "Test Summary:"
echo "  Run: $TESTS_RUN"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi
