#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_SRC="$REPO_ROOT/config/nvim"
CONFIG_DST="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
DRY_RUN="${DRY_RUN:-0}"

log() { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*"; }

is_dry_run() {
  [ "$DRY_RUN" -eq 1 ]
}

run_cmd() {
  if is_dry_run; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

run_sudo_cmd() {
  if command -v sudo >/dev/null 2>&1; then
    run_cmd sudo "$@"
  else
    run_cmd "$@"
  fi
}

ensure_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "Required command not found: $cmd"
    return 1
  fi
}

safe_symlink_config() {
  local parent
  parent="$(dirname "$CONFIG_DST")"

  if is_dry_run; then
    log "[dry-run] Would ensure directory exists: $parent"
  else
    mkdir -p "$parent"
  fi

  if [ -L "$CONFIG_DST" ]; then
    local current
    current="$(readlink "$CONFIG_DST" || true)"
    if [ "$current" = "$CONFIG_SRC" ]; then
      log "Config symlink already points to $CONFIG_SRC"
      return 0
    fi
    warn "Replacing existing symlink at $CONFIG_DST -> $current"
    run_cmd rm -f "$CONFIG_DST"
  elif [ -e "$CONFIG_DST" ]; then
    local backup="$CONFIG_DST.backup.$(date +%Y%m%d-%H%M%S)"
    warn "Existing config found at $CONFIG_DST; moving to $backup"
    run_cmd mv "$CONFIG_DST" "$backup"
  fi

  if is_dry_run; then
    log "[dry-run] Would link $CONFIG_DST -> $CONFIG_SRC"
  else
    ln -s "$CONFIG_SRC" "$CONFIG_DST"
    log "Linked $CONFIG_DST -> $CONFIG_SRC"
  fi
}

install_lsp_servers() {
  if command -v go >/dev/null 2>&1; then
    if ! command -v gopls >/dev/null 2>&1; then
      log "Installing gopls via go install"
      run_cmd env GO111MODULE=on go install golang.org/x/tools/gopls@latest || warn "Failed to install gopls"
    else
      log "gopls already installed"
    fi
  else
    warn "Go not found; skipping gopls install"
  fi

  if command -v npm >/dev/null 2>&1; then
    if ! command -v typescript-language-server >/dev/null 2>&1; then
      log "Installing TypeScript language server via npm"
      run_cmd npm install -g typescript typescript-language-server || warn "Failed to install typescript-language-server"
    else
      log "typescript-language-server already installed"
    fi
  else
    warn "npm not found; skipping TypeScript language server install"
  fi

  if ! command -v lua-language-server >/dev/null 2>&1; then
    warn "lua-language-server not found. Install via package manager or Mason (:Mason)"
  else
    log "lua-language-server already installed"
  fi
}

post_install_nvim_sync() {
  if command -v nvim >/dev/null 2>&1; then
    if is_dry_run; then
      log "[dry-run] nvim --headless '+Lazy! sync' +qa"
    else
      log "Running lazy.nvim sync (idempotent)"
      nvim --headless '+Lazy! sync' +qa || warn "Neovim plugin sync returned non-zero status"
    fi
  else
    warn "nvim not found; skipping plugin sync"
  fi
}
