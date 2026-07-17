# term config backup

Backup + one-command restore for terminal configs: ghostty, lazygit, nvim, tmux.
Each module has its own `README.md` / `AGENT.md` with per-tool detail.

## One-command setup

```bash
./setup.sh
```

Installs brew deps and restores live configs for the modules you pick.
Works on macOS and Linux.

### Module selection

```bash
./setup.sh                       # interactive terminal: numbered toggle menu, all pre-checked
./setup.sh --all                 # all modules, no prompt
./setup.sh --only nvim,tmux      # just these
./setup.sh --except ghostty      # everything but this
./setup.sh --help                # usage
```

Resolution order:
1. `--only` / `--except` (mutually exclusive) — for scripted/CI runs
2. `--all` — all modules, no prompt
3. no flags + interactive terminal — numbered toggle menu
4. no flags + non-interactive (piped/CI, no TTY) — defaults to all modules

Modules: `ghostty`, `lazygit`, `tmux`, `nvim`

## Modules

- `ghostty/` — terminal emulator config (manual paste step, no CLI install path)
- `lazygit/` — lazygit config, wired to `git-delta` as pager
- `tmux/` — tmux.conf, TPM + plugins auto-installed
- `nvim/` — kickstart.nvim base + local customizations
