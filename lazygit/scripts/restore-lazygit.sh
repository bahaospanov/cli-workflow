#!/usr/bin/env bash
# Copy this backup repo's lazygit config.yml into the live lazygit config dir,
# with the delta pager path rewritten to whatever's on $PATH on this machine.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_FILE="$SCRIPT_DIR/config.yml"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "ERROR: backup config.yml not found at $BACKUP_FILE" >&2
  exit 1
fi

case "$(uname -s)" in
  Darwin) LIVE_DIR="$HOME/Library/Application Support/lazygit" ;;
  Linux)  LIVE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit" ;;
  *) echo "ERROR: unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
LIVE_FILE="$LIVE_DIR/config.yml"

DELTA_BIN="$(command -v delta || true)"
if [ -z "$DELTA_BIN" ]; then
  echo "ERROR: delta not found on PATH. Install it first: brew install git-delta" >&2
  exit 1
fi

mkdir -p "$LIVE_DIR"
sed -E "s#[^[:space:]]+/bin/delta#$DELTA_BIN#" "$BACKUP_FILE" > "$LIVE_FILE"
echo "Copied $BACKUP_FILE -> $LIVE_FILE (pager path: $DELTA_BIN)"
echo
echo "Restart lazygit — config is not hot-reloaded."
