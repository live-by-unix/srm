# Contributing Guide

This guide covers how to contribute to srm.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Submitting Changes](#submitting-changes)
- [Review Process](#review-process)

## Getting Started

1. Fork the repository
2. Clone your fork
3. Build the project
4. Run tests
5. Make your changes

```bash
git clone https://github.com/YOUR_USERNAME/srm.git
cd srm
# Build native helpers
cd src
./build-macos.sh  # or build-windows.bat on Windows
cd ..
# Run tests
./tests/run-all.sh
```

## Development Workflow

1. Create a branch for your changes
2. Make your changes
3. Add tests for new functionality
4. Update documentation
5. Run tests
6. Commit your changes
7. Push to your fork
8. Create a pull request

```bash
git checkout -b feature/my-feature
# Make changes
git add .
git commit -m "Add my feature"
git push origin feature/my-feature
```

## Code Style

### Shell Scripts

- Use POSIX sh, not bash-specific features
- 4-space indentation
- Quote all variable expansions
- Use `printf` instead of `echo`
- Check exit codes explicitly

### Objective-C

- Follow Apple's coding guidelines
- Use ARC
- Proper error handling

### C++

- Follow Microsoft's coding guidelines
- RAII where applicable
- Proper COM handling

### Documentation

- Clear, concise language
- Examples for user-facing docs
- Technical accuracy for dev docs

## Submitting Changes

### Pull Request Checklist

- [ ] Tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Commit messages are clear
- [ ] No unrelated changes

### Commit Messages

Use clear, descriptive commit messages:

```
Add support for option -I

Implement the -I (interactive once) option to prompt
before removing more than three files, matching GNU rm behavior.
```

## Review Process

1. Automated checks must pass
2. Code review by maintainers
3. Address feedback
4. Final approval
5. Merge

## Getting Help

- Open an issue for questions
- Check existing documentation
- Review similar changes

## License

By contributing, you agree that your contributions will be licensed under the BSD 3-Clause License.
