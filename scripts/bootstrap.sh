#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0

usage() {
  cat <<USAGE
Usage: scripts/bootstrap.sh [--dry-run] [--help]

Options:
  --dry-run    Preview actions without making changes
  -h, --help   Show this help message
USAGE
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
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

bootstrap_args=()
if [ "$DRY_RUN" -eq 1 ]; then
  echo "[INFO] Dry-run mode enabled."
  bootstrap_args+=(--dry-run)
fi

case "$(uname -s)" in
  Darwin)
    exec "$SCRIPT_DIR/install-macos.sh" "${bootstrap_args[@]}"
    ;;
  Linux)
    exec "$SCRIPT_DIR/install-ubuntu.sh" "${bootstrap_args[@]}"
    ;;
  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac
