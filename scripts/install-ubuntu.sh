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
Usage: scripts/install-ubuntu.sh [--dry-run]
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

if ! command -v apt-get >/dev/null 2>&1; then
  err "apt-get not found. This script is for Ubuntu/Debian systems."
  exit 1
fi

log "Updating apt package index"
run_sudo_cmd apt-get update -y

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
    run_sudo_cmd apt-get install -y "$p"
  fi
done

if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  mkdir_target="$HOME/.local/bin"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "[dry-run] mkdir -p $mkdir_target"
    log "[dry-run] ln -sf $(command -v fdfind) $HOME/.local/bin/fd"
  else
    mkdir -p "$mkdir_target"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    log "Linked fdfind -> ~/.local/bin/fd"
  fi
fi

if ! command -v lua-language-server >/dev/null 2>&1; then
  if apt-cache show lua-language-server >/dev/null 2>&1; then
    log "Installing lua-language-server"
    run_sudo_cmd apt-get install -y lua-language-server || true
  fi
fi

safe_symlink_config
install_lsp_servers
post_install_nvim_sync

log "Ubuntu setup complete"
