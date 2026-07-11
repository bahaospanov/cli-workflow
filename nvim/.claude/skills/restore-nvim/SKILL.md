---
name: restore-nvim
description: Copy the iCloud backup nvim config into the live ~/.config/nvim. Run on this Mac (or a fresh machine) to apply backed-up plugin files and lockfile.
---

Restore Neovim config from this backup repo into the live config. The backup dir is the current project root — use `$(pwd)` in all commands.

BACKUP_DIR="$(pwd)"  # wherever this repo lives
LIVE_DIR="$HOME/.config/nvim"

## Pre-flight check

Verify `~/.config/nvim` exists:
```bash
ls "$HOME/.config/nvim/init.lua" 2>/dev/null || echo "MISSING"
```

If missing, tell user to clone kickstart first (see README) before running this skill.

Verify custom plugins target dir exists:
```bash
ls "$HOME/.config/nvim/lua/custom/plugins/" 2>/dev/null || echo "MISSING"
```

If missing, create it:
```bash
mkdir -p "$HOME/.config/nvim/lua/custom/plugins/"
```

## Steps

### 1. Mirror custom plugin files

Restore must be **one-to-one**: a plugin dropped from the backup (e.g. harpoon swapped for bookmarks) must also be removed from the live config. Plain `cp` is additive and leaves the stale file behind, so use `rsync --delete` to mirror `lua/custom/plugins/` exactly to the backup.

```bash
rsync -a --delete "$(pwd)/custom-plugins/" "$HOME/.config/nvim/lua/custom/plugins/"
```

`--delete` removes any file in live `plugins/` that is not in the backup. That dir is backup-managed only, so this is intended — but warn the user it wipes any live-only plugin not tracked here. Report which files were copied and which were deleted.

### 2. Copy non-plugin custom modules

`custom/` in this backup repo holds plain Lua modules that plugin specs `require()` (e.g. `bookmarks_picker.lua`, required by `custom-plugins/bookmarks.lua`) — these belong directly in `lua/custom/`, not `lua/custom/plugins/`.

Mirror the top-level `.lua` files one-to-one too. `rsync` with `--include='*.lua' --exclude='*'` deletes only stale top-level modules and leaves the `plugins/` subdir (mirrored in step 1) untouched:

```bash
rsync -a --delete --include='*.lua' --exclude='*' "$(pwd)/custom/" "$HOME/.config/nvim/lua/custom/"
```

Report which files were copied and which were deleted (or none found).

### 3. Copy lazy-lock.json

```bash
cp "$(pwd)/lazy-lock.json" "$HOME/.config/nvim/lazy-lock.json"
```

### 4. Apply init.lua patch (if needed)

Check if patch is already applied:
```bash
cd "$HOME/.config/nvim"
git apply --check "$(pwd)/kickstart-customizations.patch" 2>&1
```

- Exit 0: apply it:
  ```bash
  git apply "$(pwd)/kickstart-customizations.patch"
  ```
- Already applied: skip, tell user.
- Other error: show error, tell user to apply manually.

### 5. Install system dependencies

Plugin specs can rely on **system binaries** that live outside `~/.config/nvim` and are not captured by this backup (not the lua files, not lazy-lock.json). Without them a plugin silently fails at runtime. These are tracked in `system-deps.txt` at the repo root (kept current by the backup skill's step 6).

Parse the manifest (first token per non-comment line = brew package) and check each is installed:

```bash
grep -vE '^\s*(#|$)' "$(pwd)/system-deps.txt" | awk '{print $1}' | while read -r pkg; do
  command -v "$pkg" >/dev/null 2>&1 && echo "OK  $pkg" || echo "MISSING  $pkg"
done
```

Note: the binary name usually matches the brew package, but not always (e.g. `imagemagick` provides `magick`). If a package reports `MISSING` but you suspect the binary is named differently, verify with `brew list <pkg>` before prompting.

For any genuinely missing package, run — or tell the user to run — `brew install <pkg>`. Also check the README's `## Prerequisites (fresh machine)` for any non-brew terminal/environment requirement (Kitty-graphics terminal, tmux passthrough) and relay it.

### 6. Mason tools

Remind user: open `nvim`, run `:Mason` to install tools listed in `$(pwd)/mason-tools.txt`. Not auto-installed — Mason installs interactively.

### 7. Report summary

List all files written to `~/.config/nvim`. Remind user to run `:Lazy restore` inside nvim to pin plugin versions from lockfile.
