#!/usr/bin/env bash
# Sync live Neovim config into this backup repo.
# Shell equivalent of the /backup-nvim skill.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LIVE_DIR="$HOME/.config/nvim"

echo "==> Syncing custom plugin files"
cp -v "$LIVE_DIR/lua/custom/plugins/"*.lua "$BACKUP_DIR/custom-plugins/"

echo "==> Syncing non-plugin custom modules"
find "$LIVE_DIR/lua/custom" -maxdepth 1 -name "*.lua" -type f -exec cp -v {} "$BACKUP_DIR/custom/" \;

echo "==> Syncing lazy-lock.json"
cp "$LIVE_DIR/lazy-lock.json" "$BACKUP_DIR/lazy-lock.json"

echo "==> Regenerating kickstart-customizations.patch"
BASE=$(cat "$BACKUP_DIR/kickstart-base-commit.txt")
cd "$LIVE_DIR"
git diff "$BASE" -- init.lua > "$BACKUP_DIR/kickstart-customizations.patch"
if [ ! -s "$BACKUP_DIR/kickstart-customizations.patch" ]; then
  echo "WARNING: patch is empty — either init.lua has no customizations vs base, or base commit is wrong."
fi
cd "$BACKUP_DIR"

echo "==> Done. Review changes:"
git -C "$BACKUP_DIR" status --short

cat <<'EOF'

NOTE: this script does NOT update CHEATSHEET.md or system-deps.txt —
those need human judgment (reading keymaps, spotting new system deps).
Review the diff above and update them by hand if plugin files changed.

Commit manually, e.g.:
  git add lazy-lock.json kickstart-customizations.patch custom-plugins/<file>.lua
  git commit -m "..."
  git push
EOF
