#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if ! command -v brew >/dev/null 2>&1; then
  err "Homebrew is required. Install from https://brew.sh"
  exit 1
fi

log "Updating Homebrew"
brew update

BREW_PKGS=(
  neovim
  git
  curl
  unzip
  ripgrep
  fd
  lua
  luarocks
  node
  go
  lua-language-server
)

for p in "${BREW_PKGS[@]}"; do
  if brew list "$p" >/dev/null 2>&1; then
    log "Homebrew package already installed: $p"
  else
    log "Installing Homebrew package: $p"
    brew install "$p"
  fi
done

safe_symlink_config
install_lsp_servers
post_install_nvim_sync

log "macOS setup complete"
