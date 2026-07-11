---
name: diff-nvim
description: Scan backup state and local ~/.config/nvim and report any changes from either side. Shows what's ahead in backup vs live, and what's ahead in live vs backup.
---

Compare the backup repo against the live Neovim config. The backup dir is the current project root — use `$(pwd)` in all commands.

BACKUP_DIR="$(pwd)"
LIVE_DIR="$HOME/.config/nvim"

## 1. Check custom plugin files

List files in both locations:
```bash
ls "$(pwd)/custom-plugins/"*.lua 2>/dev/null
ls "$HOME/.config/nvim/lua/custom/plugins/"*.lua 2>/dev/null
```

For each `.lua` file, diff backup vs live:
```bash
for f in "$(pwd)/custom-plugins/"*.lua; do
  name=$(basename "$f")
  live="$HOME/.config/nvim/lua/custom/plugins/$name"
  if [ ! -f "$live" ]; then
    echo "ONLY IN BACKUP: $name"
  else
    diff --unified=3 "$live" "$f" && echo "IDENTICAL: $name" || echo "DIFFERS: $name"
  fi
done
```

Also check for files in live that aren't in backup:
```bash
for f in "$HOME/.config/nvim/lua/custom/plugins/"*.lua; do
  name=$(basename "$f")
  backup="$(pwd)/custom-plugins/$name"
  if [ ! -f "$backup" ]; then
    echo "ONLY IN LIVE: $name"
  fi
done
```

Show the actual unified diff for any file that differs. Report clearly which direction is ahead: backup newer, live newer, or in sync.

## 1b. Check non-plugin custom modules

`lua/custom/` can also hold plain Lua modules that plugin specs `require()` (e.g. `bookmarks_picker.lua`, required by `custom-plugins/bookmarks.lua`) — these live directly in `lua/custom/`, not `lua/custom/plugins/`, and are backed up under `custom/` in this repo.

```bash
ls "$(pwd)/custom/"*.lua 2>/dev/null
ls "$HOME/.config/nvim/lua/custom/"*.lua 2>/dev/null
```

Use `find` rather than a glob loop — `shopt -s nullglob` is bash-only and won't work under zsh:

```bash
find "$(pwd)/custom" -maxdepth 1 -name "*.lua" -type f | while IFS= read -r f; do
  name=$(basename "$f")
  live="$HOME/.config/nvim/lua/custom/$name"
  if [ ! -f "$live" ]; then
    echo "ONLY IN BACKUP: $name"
  else
    diff --unified=3 "$live" "$f" && echo "IDENTICAL: $name" || echo "DIFFERS: $name"
  fi
done

find "$HOME/.config/nvim/lua/custom" -maxdepth 1 -name "*.lua" -type f | while IFS= read -r f; do
  name=$(basename "$f")
  backup="$(pwd)/custom/$name"
  if [ ! -f "$backup" ]; then
    echo "ONLY IN LIVE: $name"
  fi
done
```

Show the actual unified diff for any file that differs.

## 2. Check lazy-lock.json

```bash
diff --unified=3 "$HOME/.config/nvim/lazy-lock.json" "$(pwd)/lazy-lock.json" \
  && echo "lazy-lock.json: IN SYNC" \
  || echo "lazy-lock.json: DIFFERS (above)"
```

If they differ, summarize which plugins changed (lines added/removed).

## 3. Check init.lua vs stored patch

Generate the current live patch and compare to stored:
```bash
BASE=$(cat "$(pwd)/kickstart-base-commit.txt")
cd "$HOME/.config/nvim"
git diff "$BASE" -- init.lua > /tmp/live-init.patch
diff "$(pwd)/kickstart-customizations.patch" /tmp/live-init.patch \
  && echo "init.lua patch: IN SYNC" \
  || echo "init.lua patch: DIFFERS (above)"
```

If they differ, show what changed between the stored and live patch.

## 4. Summary report

Print a clear summary table:

```
Component                  | Status
---------------------------|------------------
custom-plugins/*.lua       | N files in sync, M differ, K only in live/backup
custom/*.lua               | N files in sync, M differ, K only in live/backup
lazy-lock.json             | IN SYNC / DIFFERS
init.lua (via patch)       | IN SYNC / DIFFERS
```

Then recommend action:
- If live is ahead of backup → run `/backup-nvim` to sync
- If backup is ahead of live → run `/restore-nvim` to apply
- If both sides have changes → flag conflict, user must decide
- If all in sync → nothing to do
