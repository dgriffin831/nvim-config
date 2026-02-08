#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${NVIM_CONFIG_REPO_URL:-https://github.com/dgriffin831/nvim-config.git}"
INSTALL_DIR="${NVIM_CONFIG_DIR:-$HOME/.local/src/nvim-config}"
DEFAULT_BRANCH="${NVIM_CONFIG_BRANCH:-main}"

log() { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing required command: $1"; exit 1; }
}

require_cmd git
require_cmd bash

mkdir -p "$(dirname "$INSTALL_DIR")"

if [ -d "$INSTALL_DIR/.git" ]; then
  log "Existing repo found at $INSTALL_DIR — updating"
  git -C "$INSTALL_DIR" fetch origin
  git -C "$INSTALL_DIR" checkout "$DEFAULT_BRANCH"
  git -C "$INSTALL_DIR" pull --ff-only origin "$DEFAULT_BRANCH"
else
  if [ -e "$INSTALL_DIR" ]; then
    backup="$INSTALL_DIR.backup.$(date +%Y%m%d-%H%M%S)"
    warn "$INSTALL_DIR exists but is not a git repo; moving to $backup"
    mv "$INSTALL_DIR" "$backup"
  fi
  log "Cloning $REPO_URL into $INSTALL_DIR"
  git clone --branch "$DEFAULT_BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

log "Running bootstrap installer"
exec "$INSTALL_DIR/scripts/bootstrap.sh"
