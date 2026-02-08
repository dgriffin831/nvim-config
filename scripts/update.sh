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
Usage: scripts/update.sh [--dry-run]
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

safe_symlink_config
post_install_nvim_sync

log "Update complete. To update plugin lockfile after changes:"
log "  nvim --headless '+Lazy! sync' '+Lazy! lock' +qa"
