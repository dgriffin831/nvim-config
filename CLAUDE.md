# CLAUDE.md

This repo contains Dennis’s Neovim config plus bootstrap scripts for macOS and Ubuntu.

## Recommended workflow

1. Clone the repo
2. Run the bootstrap script (installs deps + links config)
3. Launch Neovim once (lazy.nvim will install plugins)

### Local bootstrap

```bash
git clone https://github.com/dgriffin831/nvim-config.git
cd nvim-config
./scripts/bootstrap.sh
```

### Remote bootstrap

```bash
curl -fsSL https://raw.githubusercontent.com/dgriffin831/nvim-config/main/bootstrap-remote.sh | bash
```

## Headless plugin sync (optional)

```bash
nvim --headless "+Lazy! sync" +qa
```

## Troubleshooting

- **Telescope fzf-native build fails**: install `make` + a compiler toolchain.
- **Ubuntu `fd`**: the package provides `fdfind`; the scripts create a `fd` symlink.

