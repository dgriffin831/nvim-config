# nvim-config

Neovim configuration extracted from the active `coding-agent` setup and packaged for bootstrapping new machines.

## Repo Layout

- `config/nvim/` — source-of-truth Neovim config (`init.lua`, `lazy-lock.json`)
- `scripts/bootstrap.sh` — OS-detecting installer entrypoint
- `scripts/install-ubuntu.sh` — Ubuntu/Debian setup (apt)
- `scripts/install-macos.sh` — macOS setup (Homebrew)
- `scripts/link-config.sh` — symlink config only
- `scripts/update.sh` — re-link + plugin sync

## Quick Start

```bash
git clone https://github.com/dgriffin831/nvim-config.git
cd nvim-config
./scripts/bootstrap.sh
```

This will:

1. Install required dependencies for your platform
2. Safely link `config/nvim` to `~/.config/nvim`
3. Preserve existing config by moving it to a timestamped backup
4. Run plugin sync (`Lazy! sync`)

## One-Command Remote Bootstrap (brand-new machine)

You can bootstrap directly from GitHub without manually cloning first:

```bash
curl -fsSL https://raw.githubusercontent.com/dgriffin831/nvim-config/main/bootstrap-remote.sh | bash
```

Optional environment overrides:

- `NVIM_CONFIG_REPO_URL` (default: `https://github.com/dgriffin831/nvim-config.git`)
- `NVIM_CONFIG_DIR` (default: `$HOME/.local/src/nvim-config`)
- `NVIM_CONFIG_BRANCH` (default: `main`)

The script is idempotent:

- Clones on first run
- Pulls latest changes on re-run
- Then executes `scripts/bootstrap.sh`

## Preview Mode (`--dry-run`)

Use dry-run to preview package installs, clone/update steps, backup/symlink actions,
and plugin sync commands before making changes.

```bash
curl -fsSL https://raw.githubusercontent.com/dgriffin831/nvim-config/main/bootstrap-remote.sh | bash -s -- --dry-run
```

```bash
./scripts/bootstrap.sh --dry-run
```

You can also dry-run individual scripts:

```bash
./scripts/install-ubuntu.sh --dry-run
./scripts/install-macos.sh --dry-run
./scripts/link-config.sh --dry-run
./scripts/update.sh --dry-run
```

## Platform Notes

### Ubuntu/Debian

- Uses `apt-get` and may require `sudo`
- Installs: `neovim`, `git`, `curl`, `unzip`, `ripgrep`, `fd-find`, `npm`, `golang-go`, etc.
- Creates `~/.local/bin/fd` symlink when only `fdfind` exists

### macOS

- Requires Homebrew (`brew`)
- Installs: `neovim`, `ripgrep`, `fd`, `node`, `go`, `lua-language-server`, etc.

## LSP / Tooling

The config expects:

- `gopls`
- `typescript-language-server` (and `typescript`)
- `lua-language-server`

Install scripts try to install these idempotently where possible.

## Idempotency & Safety

- Re-running scripts is safe
- Existing correct symlink is left untouched
- Existing non-symlink config is backed up (timestamped) before linking
- Package installs are skipped when already present

## Update Workflow

After changing config in this repo:

```bash
./scripts/link-config.sh
./scripts/update.sh
```

If you want to refresh lockfile explicitly:

```bash
nvim --headless '+Lazy! sync' '+Lazy! lock' +qa
```

Then commit and push:

```bash
git add .
git commit -m "Update Neovim config"
git push
```
