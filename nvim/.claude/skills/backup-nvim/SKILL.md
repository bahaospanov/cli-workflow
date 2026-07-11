---
name: backup-nvim
description: Copy live ~/.config/nvim changes into the iCloud backup repo and regenerate the patch file. Run on this Mac after editing the live nvim config.
---

Sync live Neovim config into this backup repo. The backup dir is the current project root — use `$(pwd)` to reference it in all commands.

LIVE_DIR="$HOME/.config/nvim"
BACKUP_DIR="$(pwd)"  # wherever this repo lives

## Steps

### 1. Sync custom plugin files

```bash
cp "$HOME/.config/nvim/lua/custom/plugins/"*.lua "$(pwd)/custom-plugins/"
```

Report which files were copied.

### 2. Sync non-plugin custom modules

`lua/custom/` can also hold plain Lua modules that plugin specs `require()` (e.g. `bookmarks_picker.lua`, required by `custom-plugins/bookmarks.lua`) — these live directly in `lua/custom/`, not in `lua/custom/plugins/`, so step 1's glob misses them entirely.

Use `find` rather than a glob — `shopt -s nullglob` is bash-only and won't work under zsh:

```bash
find "$HOME/.config/nvim/lua/custom" -maxdepth 1 -name "*.lua" -type f -exec cp -v {} "$(pwd)/custom/" \;
```

Report which files were copied (or none found).

### 3. Sync lazy-lock.json

```bash
cp "$HOME/.config/nvim/lazy-lock.json" "$(pwd)/lazy-lock.json"
```

### 4. Regenerate kickstart-customizations.patch

The live `~/.config/nvim` is a kickstart.nvim git clone. Generate a patch of `init.lua` relative to the pinned base commit:

```bash
BASE=$(cat "$(pwd)/kickstart-base-commit.txt")
cd "$HOME/.config/nvim"
git diff "$BASE" -- init.lua > "$(pwd)/kickstart-customizations.patch"
```

If `git diff` fails (detached HEAD, no git history), warn: patch cannot be regenerated automatically, must update manually.

If patch output is empty, warn: either init.lua has no customizations vs base, or base commit is wrong.

### 5. Update CHEATSHEET.md

Compare the plugin files just synced in step 1 against what `CHEATSHEET.md` documents:

- New plugin file with keymaps (e.g. a new entry in `custom-plugins/`) → add a section documenting its keymaps.
- Plugin file removed or replaced by another (e.g. old plugin's `keys` table gone, superseded by a different plugin) → remove or replace the corresponding stale section, don't leave old keymaps documented that no longer exist.
- Keymap changes within an existing plugin file → update the matching section.

This is a judgment call, not a mechanical diff — read the actual `keys = {...}` tables in the synced `.lua` files to get the leader mappings right.

### 6. Update system dependency manifest

Plugin specs can rely on **system binaries** that live outside `~/.config/nvim` and are therefore captured by nothing else in this backup (not the lua files, not lazy-lock.json). A fresh restore silently fails to work unless those are installed. Examples: image.nvim needs `imagemagick` (the `magick` CLI); other plugins may need `ripgrep`, `fd`, `node`, etc.

Two places track these, keep both current:

- **`system-deps.txt`** (repo root) — machine-readable manifest the restore skill parses and installs. One brew package per line, `# note` optional. Lives at repo root so the plugin-mirror rsync never deletes it.
- **`README.md` `## Prerequisites (fresh machine)`** — human-readable prose, plus any terminal/environment requirement (e.g. Kitty-graphics terminal, tmux passthrough) that isn't a brew package.

For each plugin file synced in step 1, check whether it needs a system binary (look for `processor`/`backend` options, `build` commands, or external CLI calls). If so, make sure it appears in **both** `system-deps.txt` and the README section. Add it if missing.

**Removal is manual** — do not auto-delete a dep line when its plugin is dropped; the binary may be shared by other tools. Only remove after confirming nothing else needs it.

### 7. Report summary

List all files updated, including whether CHEATSHEET.md changed and why. Remind user: commit from this Mac with `git add <files by name>` (never `git add -A`) then push.
