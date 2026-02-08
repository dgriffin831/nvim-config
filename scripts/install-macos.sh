#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      cat <<USAGE
Usage: scripts/install-macos.sh [--dry-run]
USAGE
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

source "$SCRIPT_DIR/common.sh"

if [ "$DRY_RUN" -eq 1 ]; then
  log "Dry-run mode enabled. No changes will be made."
fi

if ! command -v brew >/dev/null 2>&1; then
  err "Homebrew is required. Install from https://brew.sh"
  exit 1
fi

log "Updating Homebrew"
run_cmd brew update

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
    run_cmd brew install "$p"
  fi
done

safe_symlink_config
install_lsp_servers
post_install_nvim_sync

log "macOS setup complete"
