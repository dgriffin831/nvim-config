#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Darwin)
    exec "$SCRIPT_DIR/install-macos.sh"
    ;;
  Linux)
    exec "$SCRIPT_DIR/install-ubuntu.sh"
    ;;
  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac
