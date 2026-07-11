---
name: restore-tmux
description: Copy the iCloud backup tmux.conf into the live ~/.config/tmux. Run on this Mac (or a fresh machine) to apply the backed-up config.
---

Restore tmux config from this backup repo into the live config. The backup dir is the current project root — use `$(pwd)` in all commands.

BACKUP_FILE="$(pwd)/tmux.conf"
LIVE_DIR="$HOME/.config/tmux"

## Pre-flight check

Verify `~/.config/tmux` exists:
```bash
mkdir -p "$HOME/.config/tmux"
```

## Steps

### 1. Copy tmux.conf

```bash
cp "$(pwd)/tmux.conf" "$HOME/.config/tmux/tmux.conf"
```

### 2. Install TPM if missing

`tmux.conf` ends with `run '~/.tmux/plugins/tpm/tpm'`, which expects TPM cloned at `~/.tmux/plugins/tpm`.

```bash
ls "$HOME/.tmux/plugins/tpm" 2>/dev/null || echo "MISSING"
```

If missing, clone it:
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 3. Install plugins directly (don't rely on `prefix + I`)

`tpm`'s own installer (`~/.tmux/plugins/tpm/bin/install_plugins`) has been observed to silently no-op — reports "Already installed" for plugins that are NOT cloned yet. Do not trust it alone. Instead parse `@plugin` lines out of `tmux.conf` itself and clone each one directly, skipping ones already present. This stays correct automatically if plugins are added/removed later — no hardcoded list:

```bash
cd ~/.tmux/plugins
grep -E "^\s*set(-option)?\s+-g\s+@plugin\s" "$HOME/.config/tmux/tmux.conf" \
  | sed -E "s/.*@plugin[[:space:]]+['\"]([^'\"]+)['\"].*/\1/" \
  | grep -v '^tmux-plugins/tpm$' \
  | while read -r plugin; do
      case "$plugin" in
        http*://*|git@*) url="$plugin" ;;
        *) url="https://github.com/$plugin.git" ;;
      esac
      name="$(basename "$plugin" .git)"
      [ -d "$name" ] || git clone "$url" "$name"
    done
```

### 4. Reload tmux

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

If a tmux server was already running before the restore (stale session), status bar may still look wrong until reload — this step is required, not optional.

### 5. Report summary

Confirm `tmux.conf` written to `~/.config/tmux/tmux.conf`, list which plugins were freshly cloned vs already present, and confirm config was reloaded.

## Known issue: command prompt overwrites the status line (macOS 26)

Symptom: after restore, pressing `prefix + :` and typing a command makes the
typed text overwrite the window-name status line instead of filling a clean
prompt bar (`:killconfig` shows as `killonfigs 📝/tmux …`).

Root cause: `catppuccin-tmux` sets a custom `message-style` /
`message-command-style`. On **macOS 26 + tmux 3.7**, ANY custom `message-style`
stops tmux from filling/clearing the status line during the command prompt, so
the window list stays and typed input overwrites it. Only the built-in default
`message-style` clears correctly. It is terminal-independent (reproduced in
Ghostty and iTerm2) and macOS-version-specific — a machine on older macOS shows
no problem with the exact same config.

Fix (already baked into `tmux.conf` as a post-tpm override — keep it):

```tmux
# after `run '~/.tmux/plugins/tpm/tpm'`
set -gu message-style
set -gu message-command-style
```

`set -gu` reverts the theme's message styling back to the tmux default so the
prompt clears. The message bar loses catppuccin's gray tint (transient only);
everything else stays themed.

Do NOT "fix" this by re-adding a custom `message-style` value — even a
different color or `fg`-only value re-triggers it. Verified by bisection:
default = clean, any custom value = broken. NOT caused by: the emoji in the
backup path, Nerd Font, the terminal, tmux version, sync/flicker, status
lengths, `status-left`, or `align=centre` (that's a separate cosmetic quirk
that centers the `:` but is not the overwrite cause).

Because the restore clones the *latest* plugin versions, a future catppuccin
update could reintroduce or change this. If the prompt misbehaves after a
restore, verify the two `set -gu` override lines are present and AFTER the tpm
`run` line, and that `tmux show-options -g message-style` reports the default
(not a custom value) once loaded.
