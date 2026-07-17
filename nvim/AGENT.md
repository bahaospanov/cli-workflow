# AGENT.md — for agents working in this directory

This is **not an app**. It's a backup of Bakhtiyar's Neovim config. No build, no tests, no run step. The work here is editing Lua plugin configs and patch/lock files.

See repo root `AGENT.md` for git layout (iCloud-synced separate-git-dir setup) and commit rules. Fresh-machine restore: `git clone` of `terminal-workflow` to a **non-iCloud** path, then run root `setup.sh` (or `nvim/scripts/restore-nvim.sh` directly). When applying changes (e.g. regenerating `kickstart-customizations.patch`), do it in the vault directory on any machine — commit from the machine that has the remote.

## File map

- `custom-plugins/` — Lua plugin spec files loaded by lazy.nvim.
- `lazy-lock.json` — plugin version lockfile.
- `mason-tools.txt` — list of Mason-installed LSP/linter/formatter tools.
- `kickstart-base-commit.txt` — SHA of the upstream kickstart.nvim commit this config is based on.
- `kickstart-customizations.patch` — diff of local changes on top of kickstart base.
- `README.md` — human-facing overview.
