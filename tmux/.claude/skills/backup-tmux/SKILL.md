---
name: backup-tmux
description: Copy live ~/.config/tmux/tmux.conf into the iCloud backup repo. Run on this Mac after editing the live tmux config.
---

Sync live tmux config into this backup repo. The backup dir is the current project root — use `$(pwd)` to reference it in all commands.

LIVE_FILE="$HOME/.config/tmux/tmux.conf"
BACKUP_FILE="$(pwd)/tmux.conf"

## Steps

### 1. Copy tmux.conf

```bash
cp "$HOME/.config/tmux/tmux.conf" "$(pwd)/tmux.conf"
```

### 2. Report summary

Show whether the file changed (`git diff --stat -- tmux.conf` if inside a working git repo). Remind user: commit from this Mac with `git add tmux.conf` (never `git add -A`) then push.

Note: `plugins/` (TPM clones) is intentionally not backed up — it's reproducible from the `@plugin` lines in `tmux.conf` via `prefix + I`.
