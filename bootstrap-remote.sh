#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${NVIM_CONFIG_REPO_URL:-https://github.com/dgriffin831/nvim-config.git}"
INSTALL_DIR="${NVIM_CONFIG_DIR:-$HOME/.local/src/nvim-config}"
DEFAULT_BRANCH="${NVIM_CONFIG_BRANCH:-main}"
DRY_RUN=0

log() { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*"; }

usage() {
  cat <<USAGE
Usage: bootstrap-remote.sh [--dry-run] [--help]

Bootstraps this Neovim config on a fresh machine by cloning/updating the repo
and running scripts/bootstrap.sh.

Options:
  --dry-run    Preview planned actions without making changes
  -h, --help   Show this help message

Environment overrides:
  NVIM_CONFIG_REPO_URL (default: $REPO_URL)
  NVIM_CONFIG_DIR      (default: $INSTALL_DIR)
  NVIM_CONFIG_BRANCH   (default: $DEFAULT_BRANCH)
USAGE
}

run_cmd() {
  if [ "$DRY_RUN" -eq 1 ]; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing required command: $1"; exit 1; }
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      err "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

require_cmd git
require_cmd bash

if [ "$DRY_RUN" -eq 1 ]; then
  log "Dry-run mode enabled. No changes will be made."
fi

parent_dir="$(dirname "$INSTALL_DIR")"
if [ "$DRY_RUN" -eq 1 ]; then
  log "[dry-run] Would ensure parent directory exists: $parent_dir"
else
  mkdir -p "$parent_dir"
fi

if [ -d "$INSTALL_DIR/.git" ]; then
  log "Existing repo found at $INSTALL_DIR — updating"
  run_cmd git -C "$INSTALL_DIR" fetch origin
  run_cmd git -C "$INSTALL_DIR" checkout "$DEFAULT_BRANCH"
  run_cmd git -C "$INSTALL_DIR" pull --ff-only origin "$DEFAULT_BRANCH"
else
  if [ -e "$INSTALL_DIR" ]; then
    backup="$INSTALL_DIR.backup.$(date +%Y%m%d-%H%M%S)"
    warn "$INSTALL_DIR exists but is not a git repo; moving to $backup"
    run_cmd mv "$INSTALL_DIR" "$backup"
  fi
  log "Cloning $REPO_URL into $INSTALL_DIR"
  run_cmd git clone --branch "$DEFAULT_BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

log "Running bootstrap installer"
if [ "$DRY_RUN" -eq 1 ]; then
  run_cmd "$INSTALL_DIR/scripts/bootstrap.sh" --dry-run
else
  exec "$INSTALL_DIR/scripts/bootstrap.sh"
fi
