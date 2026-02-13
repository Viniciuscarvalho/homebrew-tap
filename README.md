# Homebrew Tap for Vinicius Carvalho

This is my personal Homebrew tap containing formulas for my open-source projects.

## Installation

```bash
brew tap viniciuscarvalho/tap
```

## Available Formulas

### feature-marker

AI-powered feature development workflow automation for Claude Code.

```bash
# Install
brew install viniciuscarvalho/tap/feature-marker

# Complete installation to ~/.claude
feature-marker-install

# Optional: Install with TUI (requires Rust)
brew install viniciuscarvalho/tap/feature-marker --with-tui
```

**Usage in Claude Code:**
```bash
/feature-marker prd-user-authentication
```

## Updating Formulas

After creating a new release on GitHub:

1. Get the SHA256 of the release tarball:
   ```bash
   curl -sL https://github.com/Viniciuscarvalho/Feature-marker/archive/refs/tags/vX.X.X.tar.gz | shasum -a 256
   ```

2. Update the formula with the new version and SHA256

3. Push changes to this repository

## More Information

- [feature-marker Repository](https://github.com/Viniciuscarvalho/Feature-marker)
- [Homebrew Documentation](https://docs.brew.sh/)

## License

MIT
