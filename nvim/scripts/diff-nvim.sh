#!/usr/bin/env bash
# Compare the backup repo against the live Neovim config.
# Shell equivalent of the /diff-nvim skill.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LIVE_DIR="$HOME/.config/nvim"

plugins_status="in sync"
custom_status="in sync"
lock_status="IN SYNC"
init_status="IN SYNC"

echo "### custom-plugins/*.lua ###"
for f in "$BACKUP_DIR/custom-plugins/"*.lua; do
  name=$(basename "$f")
  live="$LIVE_DIR/lua/custom/plugins/$name"
  if [ ! -f "$live" ]; then
    echo "ONLY IN BACKUP: $name"
    plugins_status="differs"
  else
    if diff --unified=3 "$live" "$f" > /tmp/diffnvim_$$.diff; then
      echo "IDENTICAL: $name"
    else
      echo "DIFFERS: $name"
      cat /tmp/diffnvim_$$.diff
      plugins_status="differs"
    fi
    rm -f /tmp/diffnvim_$$.diff
  fi
done
for f in "$LIVE_DIR/lua/custom/plugins/"*.lua; do
  name=$(basename "$f")
  backup="$BACKUP_DIR/custom-plugins/$name"
  if [ ! -f "$backup" ]; then
    echo "ONLY IN LIVE: $name"
    plugins_status="differs"
  fi
done

echo
echo "### custom/*.lua (non-plugin modules) ###"
find "$BACKUP_DIR/custom" -maxdepth 1 -name "*.lua" -type f | while IFS= read -r f; do
  name=$(basename "$f")
  live="$LIVE_DIR/lua/custom/$name"
  if [ ! -f "$live" ]; then
    echo "ONLY IN BACKUP: $name"
  else
    if diff --unified=3 "$live" "$f" > /tmp/diffnvim_c_$$.diff; then
      echo "IDENTICAL: $name"
    else
      echo "DIFFERS: $name"
      cat /tmp/diffnvim_c_$$.diff
    fi
    rm -f /tmp/diffnvim_c_$$.diff
  fi
done
find "$LIVE_DIR/lua/custom" -maxdepth 1 -name "*.lua" -type f | while IFS= read -r f; do
  name=$(basename "$f")
  backup="$BACKUP_DIR/custom/$name"
  [ ! -f "$backup" ] && echo "ONLY IN LIVE: $name"
done

echo
echo "### lazy-lock.json ###"
if diff --unified=3 "$LIVE_DIR/lazy-lock.json" "$BACKUP_DIR/lazy-lock.json" > /tmp/diffnvim_lock_$$.diff; then
  echo "IN SYNC"
else
  cat /tmp/diffnvim_lock_$$.diff
  lock_status="DIFFERS"
fi
rm -f /tmp/diffnvim_lock_$$.diff

echo
echo "### init.lua (via patch) ###"
BASE=$(cat "$BACKUP_DIR/kickstart-base-commit.txt")
(cd "$LIVE_DIR" && git diff "$BASE" -- init.lua) > /tmp/diffnvim_live-init_$$.patch
if diff "$BACKUP_DIR/kickstart-customizations.patch" /tmp/diffnvim_live-init_$$.patch > /tmp/diffnvim_init_$$.diff; then
  echo "IN SYNC"
else
  cat /tmp/diffnvim_init_$$.diff
  init_status="DIFFERS"
fi
rm -f /tmp/diffnvim_live-init_$$.patch /tmp/diffnvim_init_$$.diff

echo
echo "### Summary ###"
printf "%-28s| %s\n" "Component" "Status"
printf "%-28s|%s\n" "----------------------------" "------------------"
printf "%-28s| %s\n" "custom-plugins/*.lua" "$plugins_status (see above)"
printf "%-28s| %s\n" "custom/*.lua" "see above"
printf "%-28s| %s\n" "lazy-lock.json" "$lock_status"
printf "%-28s| %s\n" "init.lua (via patch)" "$init_status"

echo
if [ "$lock_status" = "DIFFERS" ] || [ "$init_status" = "DIFFERS" ] || [ "$plugins_status" = "differs" ]; then
  echo "=> Changes found. Inspect above, then run scripts/backup-nvim.sh (live ahead) or scripts/restore-nvim.sh (backup ahead)."
else
  echo "=> All in sync. Nothing to do."
fi
