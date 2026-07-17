#!/usr/bin/env bash
# Compare this backup repo's config.yml against the live lazygit config,
# ignoring the delta pager path (machine-specific, not a real difference).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_FILE="$SCRIPT_DIR/config.yml"

case "$(uname -s)" in
  Darwin) LIVE_DIR="$HOME/Library/Application Support/lazygit" ;;
  Linux)  LIVE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit" ;;
  *) echo "ERROR: unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
LIVE_FILE="$LIVE_DIR/config.yml"

status=""

if [ ! -f "$LIVE_FILE" ]; then
  echo "ONLY IN BACKUP: config.yml (live file missing)"
  status="ONLY IN BACKUP"
elif [ ! -f "$BACKUP_FILE" ]; then
  echo "ONLY IN LIVE: config.yml (backup file missing)"
  status="ONLY IN LIVE"
else
  NORM_LIVE="$(sed -E "s#[^[:space:]]+/bin/delta#DELTA_BIN#" "$LIVE_FILE")"
  NORM_BACKUP="$(sed -E "s#[^[:space:]]+/bin/delta#DELTA_BIN#" "$BACKUP_FILE")"
  if diff --unified=3 <(echo "$NORM_LIVE") <(echo "$NORM_BACKUP"); then
    echo "config.yml: IN SYNC (delta path differences ignored)"
    status="IN SYNC"
  else
    echo "config.yml: DIFFERS (above)"
    status="DIFFERS"
  fi
fi

echo
echo "Component   | Status"
echo "------------|------------------"
printf "%-11s | %s\n" "config.yml" "$status"

echo
case "$status" in
  "IN SYNC")
    echo "Nothing to do." ;;
  "DIFFERS")
    echo "Both sides may have changes — inspect diff above and decide: backup-lazygit.sh (live->backup) or restore-lazygit.sh (backup->live)." ;;
  "ONLY IN LIVE")
    echo "Run backup-lazygit.sh to sync live -> backup." ;;
  "ONLY IN BACKUP")
    echo "Run restore-lazygit.sh to apply backup -> live." ;;
esac
