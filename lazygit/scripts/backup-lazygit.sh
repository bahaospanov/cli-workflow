#!/usr/bin/env bash
# Copy the live lazygit config.yml into this backup repo, normalizing the
# delta pager path back to a generic placeholder so the diff stays portable.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_FILE="$SCRIPT_DIR/config.yml"

case "$(uname -s)" in
  Darwin) LIVE_DIR="$HOME/Library/Application Support/lazygit" ;;
  Linux)  LIVE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit" ;;
  *) echo "ERROR: unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
LIVE_FILE="$LIVE_DIR/config.yml"

if [ ! -f "$LIVE_FILE" ]; then
  echo "ERROR: live config.yml not found at $LIVE_FILE" >&2
  exit 1
fi

sed -E "s#[^[:space:]]+/bin/delta#/opt/homebrew/bin/delta#" "$LIVE_FILE" > "$BACKUP_FILE"
echo "Copied $LIVE_FILE -> $BACKUP_FILE (delta path normalized to placeholder)"

if git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo
  echo "git diff --stat:"
  git -C "$SCRIPT_DIR" diff --stat -- config.yml || true
  echo
  echo "Reminder: commit with 'git add lazygit/config.yml' (never 'git add -A'), then push."
fi
