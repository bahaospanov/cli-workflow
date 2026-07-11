# AGENT.md — for agents working in this directory

This is **not an app**. It's a backup of Bakhtiyar's Neovim config. No build, no tests, no run step. The work here is editing Lua plugin configs and patch/lock files.

## Unusual git layout — read before touching git

The working tree lives **inside an iCloud-synced Obsidian vault**. To stop iCloud from corrupting the repo, git was set up with `--separate-git-dir`:

- `.git` here is a **pointer file**, not a directory: it contains `gitdir: /Users/baha/artifacts/git-storage/nvim-config`.
- The real git database lives at `~/artifacts/git-storage/nvim-config` (off iCloud).
- Remote: `github.com/bahaospanov/nvim-config` (**private**). This is the backup + the thing a fresh machine clones.

Implications:
- **Don't "fix" the `.git` file by re-running `git init`** — it's correct as-is. The pointer is intentional.
- The pointer path is **machine-specific** — commits only work on this Mac. See "Editing from another machine" below.
- iCloud occasionally creates `filename 2.md` conflict copies. They're harmless noise — `rm` them; don't commit them.
- A fresh-machine restore is a plain `git clone` to a **non-iCloud** path (e.g. `~/code/nvim-config`), then copy files into `~/.config/nvim/`.

### Editing from another machine

The `.git` pointer is a file *inside* the working tree, so iCloud syncs it to every machine — but each machine would need it to name a *different* local git-dir path. One synced file can't hold two values, so git only works on this Mac. Don't try to run git on a second machine; it would rewrite the synced pointer and break this Mac too.

The working flow — **edit anywhere, commit only on the machine with the remote**:

1. Edit freely in Obsidian, Neovim, or via Claude Code on any machine. iCloud syncs files across.
2. On the machine with the bare repo (`~/artifacts/git-storage/nvim-config`), wait for iCloud to pull those edits.
3. Commit/push from there as normal (`git add <files by name>` → commit → push).

When using Claude Code to apply changes (e.g. regenerating `kickstart-customizations.patch`), do it in the vault directory on any machine — then commit from the machine that has the remote.

Git here is for versioning + backup, not commit-where-you-edited.

## Committing

- **Stage by name, never `git add -A` / `git add .`.**
- **Never commit secrets.**
- Don't commit/push without an explicit authorizing word (`commit | push | ship | deploy | merge | pr`) in the user's recent message. Conventional Commits format.

## File map

- `custom-plugins/` — Lua plugin spec files loaded by lazy.nvim.
- `lazy-lock.json` — plugin version lockfile.
- `mason-tools.txt` — list of Mason-installed LSP/linter/formatter tools.
- `kickstart-base-commit.txt` — SHA of the upstream kickstart.nvim commit this config is based on.
- `kickstart-customizations.patch` — diff of local changes on top of kickstart base.
- `README.md` — human-facing overview.
