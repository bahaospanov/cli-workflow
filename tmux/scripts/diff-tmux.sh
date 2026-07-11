#!/usr/bin/env bash
# Compare this backup repo's tmux.conf against the live ~/.config/tmux/tmux.conf.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_FILE="$SCRIPT_DIR/tmux.conf"
LIVE_FILE="$HOME/.config/tmux/tmux.conf"

status=""

if [ ! -f "$LIVE_FILE" ]; then
  echo "ONLY IN BACKUP: tmux.conf (live file missing)"
  status="ONLY IN BACKUP"
elif [ ! -f "$BACKUP_FILE" ]; then
  echo "ONLY IN LIVE: tmux.conf (backup file missing)"
  status="ONLY IN LIVE"
else
  if diff --unified=3 "$LIVE_FILE" "$BACKUP_FILE"; then
    echo "tmux.conf: IN SYNC"
    status="IN SYNC"
  else
    echo "tmux.conf: DIFFERS (above)"
    status="DIFFERS"
  fi
fi

echo
echo "Component   | Status"
echo "------------|------------------"
printf "%-11s | %s\n" "tmux.conf" "$status"

echo
case "$status" in
  "IN SYNC")
    echo "Nothing to do." ;;
  "DIFFERS")
    echo "Both sides may have changes — inspect diff above and decide: backup-tmux.sh (live->backup) or restore-tmux.sh (backup->live)." ;;
  "ONLY IN LIVE")
    echo "Run backup-tmux.sh to sync live -> backup." ;;
  "ONLY IN BACKUP")
    echo "Run restore-tmux.sh to apply backup -> live." ;;
esac

echo
echo "Note: plugins/ is not compared — it's TPM-managed clones, reproducible from @plugin lines in tmux.conf."
