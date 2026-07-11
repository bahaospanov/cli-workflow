#!/usr/bin/env bash
# Restore Neovim config from this backup repo into the live config.
# Shell equivalent of the /restore-nvim skill.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LIVE_DIR="$HOME/.config/nvim"

if [ ! -f "$LIVE_DIR/init.lua" ]; then
  echo "ERROR: $LIVE_DIR/init.lua not found. Clone kickstart.nvim first (see README)." >&2
  exit 1
fi

mkdir -p "$LIVE_DIR/lua/custom/plugins"

echo "==> Mirroring custom plugin files (deletes stale live-only files)"
rsync -av --delete "$BACKUP_DIR/custom-plugins/" "$LIVE_DIR/lua/custom/plugins/"

echo "==> Mirroring non-plugin custom modules"
rsync -av --delete --include='*.lua' --exclude='*' "$BACKUP_DIR/custom/" "$LIVE_DIR/lua/custom/"

echo "==> Copying lazy-lock.json"
cp "$BACKUP_DIR/lazy-lock.json" "$LIVE_DIR/lazy-lock.json"

echo "==> Applying init.lua patch"
cd "$LIVE_DIR"
if git apply --check "$BACKUP_DIR/kickstart-customizations.patch" 2>/dev/null; then
  git apply "$BACKUP_DIR/kickstart-customizations.patch"
  echo "    applied."
elif git diff --quiet "$(cat "$BACKUP_DIR/kickstart-base-commit.txt")" -- init.lua 2>/dev/null; then
  echo "    already applied, skipping."
else
  echo "    WARNING: patch does not apply cleanly — init.lua has diverged from the stored patch."
  echo "    Resolve manually, e.g.:"
  echo "      cd $LIVE_DIR"
  echo "      git checkout \$(cat $BACKUP_DIR/kickstart-base-commit.txt) -- init.lua"
  echo "      git apply $BACKUP_DIR/kickstart-customizations.patch"
  echo "    (this discards any live-only init.lua edits not captured in the backup patch)"
fi
cd "$BACKUP_DIR"

echo "==> Checking system dependencies"
if [ -f "$BACKUP_DIR/system-deps.txt" ]; then
  grep -vE '^\s*(#|$)' "$BACKUP_DIR/system-deps.txt" | awk '{print $1}' | while read -r pkg; do
    if command -v "$pkg" >/dev/null 2>&1; then
      echo "    OK       $pkg"
    else
      echo "    MISSING  $pkg  (try: brew install $pkg)"
    fi
  done
fi

cat <<EOF

==> Restore complete. Remaining manual steps:
  1. Open nvim and run :Lazy restore to pin plugin versions from lazy-lock.json
  2. Run :Mason and install tools listed in $BACKUP_DIR/mason-tools.txt
  3. Check README.md "Prerequisites (fresh machine)" for any non-brew requirement
     (Kitty-graphics terminal, tmux allow-passthrough, etc.)
EOF
