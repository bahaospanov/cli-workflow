#!/usr/bin/env bash
# Copy live ~/.config/tmux/tmux.conf into this backup repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIVE_FILE="$HOME/.config/tmux/tmux.conf"
BACKUP_FILE="$SCRIPT_DIR/tmux.conf"

if [ ! -f "$LIVE_FILE" ]; then
  echo "ERROR: live tmux.conf not found at $LIVE_FILE" >&2
  exit 1
fi

cp "$LIVE_FILE" "$BACKUP_FILE"
echo "Copied $LIVE_FILE -> $BACKUP_FILE"

if git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo
  echo "git diff --stat:"
  git -C "$SCRIPT_DIR" diff --stat -- tmux.conf || true
  echo
  echo "Reminder: commit with 'git add tmux.conf' (never 'git add -A'), then push."
fi

echo
echo "Note: plugins/ (TPM clones) is not backed up — reproducible from @plugin lines in tmux.conf."
