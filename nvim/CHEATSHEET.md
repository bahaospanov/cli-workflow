# Neovim

Modal text editor. Mode = what keys do.

## Modes
- **Normal** — navigate/commands. Default. `Esc` returns here.
- **Insert** — type text. Enter via `i`.
- **Append** - append text. Enter via `A`.
- **Visual** — select. Enter via `v`.
- **Command** — `:` prefix, runs commands.

## Move (Normal)
- `h j k l` — left/down/up/right
- `w` / `b` — next/prev word
- `0` / `$` — line start/end
- `gg` / `G` — file top/bottom
- `{n}G` — line n
- `/text` — search forward, `n` next, `N` prev
Jump back in jump list - `Ctrl+o`
Jump forward - `Ctrl+i`
Center view on selected line - `zz`

---
## Edit (Normal)
- `i` insert before, `a` after, `o` new line below, `O` above
- `x` delete char, `dd` delete line, `yy` copy line, `p` paste
- `dw` delete word, `d$` to line end
- `u` undo,  `U` undo line,`Ctrl+r` redo
- `r{char}` replace char, `cw` change word
---
## Change
- `ce` change till the end of the word, same as `cw`
- `c$` discard till the end of line and type in changes
---
## Go commands `g`
- `gg` — go to file top
- `G` — go to file bottom
- `grd` — go to definition (default `gd`, remapped in this layout)
- `gD` — go to declaration
- `grr` — go to references (default `gr`, remapped in this layout)
- `gri` — go to implementation (default `gi`, remapped in this layout)
- `grn` — rename
- `gt` / `gT` — next/prev tab
- `gf` — open file under cursor
- `gu` — lowercase (e.g. `guw` lowercases word)
- `gU` — uppercase (e.g. `gUw` uppercases word)
- `g;` / `g,` — jump back/forward in change list

## Visual `v`
- `v` char, `V` line, `Ctrl+v` block
- Then `d` cut, `y` copy, `c` change

## Substitute Command `s`
- `:s/old/new` — replace first match on current line
- `:s/old/new/g` — replace all matches on current line
- `:%s/old/new/g` — replace all matches in file
- `:%s/old/new/gc` — replace all, confirm each (`y`/`n`/`a`/`q`)
- `:{n,m}s/old/new/g` — replace in line range n to m
- `:'<,'>s/old/new/g` — replace in visual selection (auto-filled after `V` then `:`)

Flags: `g` = all on line, `c` = confirm, `i` = case-insensitive, `I` = case-sensitive

## Files (Command)
- `:w` save, `:q` quit, `:wq` save+quit, `:q!` force quit
- `:e file` open file
-  `:e!` - reload file, discard all changes

## Windows
- `:split` / `:vsplit` — horizontal/vertical
- `:split | term` - open Terminal in split
- `Ctrl+w` + `h/j/k/l` — switch
- `Ctrl+w` + `q` — close
- `Ctrl+h/j/k/l` — switch window/pane (vim-tmux-navigator; also crosses into tmux panes seamlessly)

## Tabs
- `:tabnew` — open new empty tab
- `:tabnew file` — open file in new tab
- `gt` / `gT` — next/prev tab
- `{n}gt` — go to tab n
- `:tabclose` — close current tab
- `:tabonly` — close all other tabs
- `:tabs` — list all tabs

## Folds
- `zo` -- open folds under cursor
- `zO` -- open All folds under cursor
- `zc` - close folds under cursor
- `zR` — open all folds in file (nvim-ufo)
- `zM` — close all folds in file (nvim-ufo)

## Help
- `:help {topic}` — built-in docs
- `vimtutor` — interactive tutorial (run in shell)

---

# Gitsigns (inline git info)

Gutter signs for changed lines + inline blame. `current_line_blame` is enabled in `init.lua` (customization, not stock kickstart) — shows the commit that last touched the current line, inline at end of line, after a 300ms delay.

## Navigation
- `]c` / `[c` — jump to next/prev git change (hunk)

## Hunk Actions
- `<leader>hs` — stage hunk (`v` visual mode: stage selected lines)
- `<leader>hr` — reset hunk (`v` visual mode: reset selected lines)
- `<leader>hS` — stage whole buffer
- `<leader>hR` — reset whole buffer
- `<leader>hp` — preview hunk (floating diff)
- `<leader>hi` — preview hunk inline
- `<leader>hb` — blame current line (full commit message popup)
- `<leader>hd` — diff buffer against index
- `<leader>hD` — diff buffer against last commit (`@`)
- `<leader>hq` — hunks quickfix list (current file)
- `<leader>hQ` — hunks quickfix list (all files in repo)

## Toggles
- `<leader>tb` — toggle inline current-line blame on/off
- `<leader>tw` — toggle intra-line word diff

## Text Object
- `ih` — select hunk (e.g. `dih` deletes the hunk under cursor)

---

# NeoTree

File explorer sidebar plugin.

## Navigation

- `j` / `k` — move up/down
- `Enter` / `o` — open file or folder

## File Operations

- `a` add, `d` delete, `r` rename
- `c` copy, `x` cut, `p` paste

## View

- `R` refresh
- `H` toggle hidden files
- `Backspace` — zoom out (go to parent dir)
- `.` — set current dir as root
- P — preview file
- `<Leader e>` — show/hide sidebar

## Help

- `?` — show all keys
- `<C-d>` / `<C-u>` — scroll help window

---

# Buffers

Open files in memory. Multiple buffers = multiple open files.

## Open / Close

- `:e file` — open file into buffer
- `:bd` — delete (close) current buffer
- `:bd!` — force close (discard unsaved changes)

## Navigate

- `:bn` / `:bp` — next/prev buffer
- `:b {name}` — jump to buffer by name (tab-complete works)
- `:b {n}` — jump to buffer by number

## List

- `:ls` — list all open buffers
  - `%` = current, `#` = alternate, `+` = unsaved

## Open Buffer in New Window

- `:sb {n}` — open buffer n in horizontal split
- `:vert sb {n}` — open buffer n in vertical split
- `:tab sb {n}` — open buffer n in new tab

Split = divides current window, both visible at same time. Tab = full separate screen, only one visible at a time (`gt`/`gT` to switch).

## Alternate Buffer

- `Ctrl+^` — toggle between current and last used buffer

## Save

- `:w` — save current buffer
- `:wa` — save all buffers

## Close All

- `:%bd` — delete all buffers
- `:%bd|e#` — delete all, reopen current file

---

# Telescope
Fuzzy finder plugin. Opens a floating popup: search input + results list + preview pane.

## Common Pickers
- Find file by name in project - `<leader> sf`, `:Telescope find_files`
- Search text inside files - `<leader> sg`, `:Telescope live_grep`
- `:Telescope buffers` — switch between open buffers
- `:Telescope oldfiles` — recently opened files
- `:Telescope help_tags` — search Neovim help docs
- `:Telescope keymaps` — browse all keymaps
- `:Telescope git_commits` — browse git commit history
- `:Telescope git_branches` — list and checkout branches
- `:Telescope git_status` — changed files (like git status)

## Inside the Popup

- Type to filter results
- `↑` / `↓` or `Ctrl+k` / `Ctrl+j` — move through results
- `Enter` — open selected
- `Ctrl+v` — open in vertical split
- `Ctrl+x` — open in horizontal split
- `Ctrl+t` — open in new tab (use instead of Enter to open without closing Telescope)
- `Esc` / `Ctrl+c` — close

## Multi-select

- `Tab` — toggle select item
- `Shift+Tab` — deselect
- `Enter` — open all selected

---

# Marks

## Vim Marks (positions within files)

- `ma`–`mz` — set local mark (per-buffer, lost on quit)
- `mA`–`mZ` — set global mark (persists across sessions, works across files)
- `` `a `` — jump to exact position of mark `a`
- `'a` — jump to line of mark `a`
- `:marks` — list all marks
- `:delm a` — delete mark `a`
- `:delm!` — delete all lowercase marks

### Special marks (automatic)

- `` `` ` `` `` — position before last jump
- `'.` — last edit position
- `'^` — last insert position
- `'0`–`'9` — cursor positions from previous sessions (set automatically on exit)

## Bookmarks (bookmarks.nvim)
Persistent, annotatable line bookmarks (replaces Harpoon/Grapple).

- `<leader>bm` — toggle bookmark on current line
- `<leader>ba` — annotate bookmark
- `<leader>bn` — next bookmark
- `<leader>bp` — prev bookmark
- `<leader>bc` — clean bookmarks (current buffer)
- `<leader>bl` — list all bookmarks (telescope picker)
  - `<C-d>` (in picker) — delete bookmark under cursor

---

# LazyGit (lazygit.nvim)

Git UI in Neovim. Invokes the external `lazygit` command in a floating window.

- `<leader>lg` — open LazyGit
