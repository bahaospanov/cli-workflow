---
name: diff-tmux
description: Compare backup state and local ~/.config/tmux/tmux.conf and report changes from either side. Shows what's ahead in backup vs live, and what's ahead in live vs backup.
---

Compare the backup repo against the live tmux config. The backup dir is the current project root — use `$(pwd)` in all commands.

BACKUP_FILE="$(pwd)/tmux.conf"
LIVE_FILE="$HOME/.config/tmux/tmux.conf"

## 1. Check tmux.conf

```bash
if [ ! -f "$HOME/.config/tmux/tmux.conf" ]; then
  echo "ONLY IN BACKUP: tmux.conf (live file missing)"
elif [ ! -f "$(pwd)/tmux.conf" ]; then
  echo "ONLY IN LIVE: tmux.conf (backup file missing)"
else
  diff --unified=3 "$HOME/.config/tmux/tmux.conf" "$(pwd)/tmux.conf" \
    && echo "tmux.conf: IN SYNC" \
    || echo "tmux.conf: DIFFERS (above)"
fi
```

Show the actual unified diff if they differ.

## 2. Summary report

Print a clear summary:

```
Component   | Status
------------|------------------
tmux.conf   | IN SYNC / DIFFERS / ONLY IN BACKUP / ONLY IN LIVE
```

Then recommend action:
- If live is ahead of backup → run `/backup-tmux` to sync
- If backup is ahead of live → run `/restore-tmux` to apply
- If both sides have changes → flag conflict, user must decide
- If in sync → nothing to do

Note: `plugins/` is not compared — it's TPM-managed clones, reproducible from `@plugin` lines in `tmux.conf`.
