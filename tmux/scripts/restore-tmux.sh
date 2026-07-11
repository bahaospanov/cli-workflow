#!/usr/bin/env bash
# Copy this backup repo's tmux.conf into the live ~/.config/tmux, install TPM
# and plugins if missing, then reload tmux.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_FILE="$SCRIPT_DIR/tmux.conf"
LIVE_DIR="$HOME/.config/tmux"
LIVE_FILE="$LIVE_DIR/tmux.conf"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "ERROR: backup tmux.conf not found at $BACKUP_FILE" >&2
  exit 1
fi

mkdir -p "$LIVE_DIR"
cp "$BACKUP_FILE" "$LIVE_FILE"
echo "Copied $BACKUP_FILE -> $LIVE_FILE"

# Install TPM if missing
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "TPM missing, cloning..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "TPM already present."
fi

# Install plugins directly from @plugin lines (tpm's own installer can silently no-op)
mkdir -p "$HOME/.tmux/plugins"
cd "$HOME/.tmux/plugins"

echo
echo "Plugins:"
grep -E "^\s*set(-option)?\s+-g\s+@plugin\s" "$LIVE_FILE" \
  | sed -E "s/.*@plugin[[:space:]]+['\"]([^'\"]+)['\"].*/\1/" \
  | grep -v '^tmux-plugins/tpm$' \
  | while read -r plugin; do
      case "$plugin" in
        http*://*|git@*) url="$plugin" ;;
        *) url="https://github.com/$plugin.git" ;;
      esac
      name="$(basename "$plugin" .git)"
      if [ -d "$name" ]; then
        echo "  already present: $name"
      else
        echo "  cloning: $name"
        git clone "$url" "$name"
      fi
    done

# Reload tmux if a server is running
if tmux info >/dev/null 2>&1; then
  tmux source-file "$LIVE_FILE"
  echo
  echo "Reloaded running tmux server."
else
  echo
  echo "No tmux server running — config will apply on next 'tmux' start."
fi

echo
echo "Restore complete: $LIVE_FILE"
