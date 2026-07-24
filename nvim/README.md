# Neovim Config Backup

Base: [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) at commit `4b065ad` + local customizations.

## Files

```
custom-plugins/
  bookmarks.lua
  image.lua
  lazygit.lua
  markview.lua
  neo-tree.lua
  ufo.lua
  vim-tmux-navigator.lua
custom/
  bookmarks_picker.lua
scripts/
  backup-nvim.sh
  restore-nvim.sh
  diff-nvim.sh
kickstart-base-commit.txt
kickstart-customizations.patch
lazy-lock.json
mason-tools.txt
system-deps.txt
CHEATSHEET.md
AGENT.md
```

## Prerequisites (fresh machine)

```bash
brew install neovim tree-sitter-cli lazygit
brew install imagemagick   # required by image.nvim (magick_cli processor) for inline image viewing
```

image.nvim also needs a terminal that speaks the Kitty graphics protocol (Ghostty/Kitty/WezTerm). Inside tmux, set `allow-passthrough on` in `~/.config/tmux/tmux.conf` (not part of this backup).

## What the patch changes

1. Nerd Font enabled (`vim.g.have_nerd_font = true`)
2. Signcolumn `yes:2` (wide enough for diagnostics + bookmarks together)
3. `<leader>yp` — yanks `@relative/path:line` to clipboard
4. gitsigns `current_line_blame` enabled (300ms delay)
5. `<leader>sC` — telescope workspace class search (LSP dynamic symbols)
6. `basedpyright` added to LSP servers
7. `vtsls` (JS/TS/JSX/TSX + `.vue`) and `vue_ls` added to LSP servers — Vue SFCs
   need both: `vue_ls` owns template/style, `vtsls` handles the TypeScript via
   `@vue/typescript-plugin` (Vue LS v3 dropped takeover mode)
8. Custom statusline — git branch + diff stats + line:col; winbar shows file path
9. `require 'kickstart.plugins.gitsigns'` enabled (recommended gitsigns keymaps)
10. Enables `{ import = 'custom.plugins' }` to load custom plugin specs

## Usage

Via Claude Code skills:
- **Backup** (live config → here): `/backup-nvim`
- **Restore** (here → `~/.config/nvim`): `/restore-nvim`
- **Diff** (see what's changed on either side): `/diff-nvim`

Via shell scripts (no Claude Code needed), from repo root:
```bash
./scripts/diff-nvim.sh      # compare backup vs live, no changes made
./scripts/backup-nvim.sh    # sync live config → this repo
./scripts/restore-nvim.sh   # sync this repo → live config
```
Scripts are a mechanical equivalent of the skills — file sync
(`custom-plugins/`, `custom/`, `lazy-lock.json`, `init.lua` patch) and
the system-deps check. They do **not** auto-update `CHEATSHEET.md` or
`system-deps.txt` — that still needs a human/Claude to read new plugin
keymaps and judge what's worth documenting. Run `backup-nvim.sh`, then
review `git diff` and update those two files by hand if plugins changed,
before committing.
