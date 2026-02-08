#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if ! command -v apt-get >/dev/null 2>&1; then
  err "apt-get not found. This script is for Ubuntu/Debian systems."
  exit 1
fi

log "Updating apt package index"
sudo apt-get update -y

# Base dependencies for this Neovim setup
PKGS=(
  neovim
  git
  curl
  unzip
  ripgrep
  fd-find
  xclip
  lua5.4
  luarocks
  npm
  golang-go
)

for p in "${PKGS[@]}"; do
  if dpkg -s "$p" >/dev/null 2>&1; then
    log "Package already installed: $p"
  else
    log "Installing package: $p"
    sudo apt-get install -y "$p"
  fi
done

# Ensure fd command exists (Ubuntu package provides fdfind)
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  log "Linked fdfind -> ~/.local/bin/fd"
fi

# Optional LSP package (if available on distro)
if ! command -v lua-language-server >/dev/null 2>&1; then
  if apt-cache show lua-language-server >/dev/null 2>&1; then
    log "Installing lua-language-server"
    sudo apt-get install -y lua-language-server || true
  fi
fi

safe_symlink_config
install_lsp_servers
post_install_nvim_sync

log "Ubuntu setup complete"
