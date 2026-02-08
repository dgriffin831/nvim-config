#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

safe_symlink_config
post_install_nvim_sync

log "Update complete. To update plugin lockfile after changes:"
log "  nvim --headless '+Lazy! sync' '+Lazy! lock' +qa"
