# AGENT.md — for agents working in this repo

This is **not an app**. It's a backup of terminal configs (ghostty, lazygit, nvim, tmux). No build, no tests, no run step — see each module's `README.md` for its own restore/backup instructions, or run root `setup.sh` to bootstrap everything.

## Unusual git layout — read before touching git

The working tree lives **inside an iCloud-synced Obsidian vault**. To stop iCloud from corrupting the repo, git was set up with `--separate-git-dir`:

- `.git` here is a **pointer file**, not a directory: it contains `gitdir: /Users/baha/artifacts/git-storage/term`.
- The real git database lives at `~/artifacts/git-storage/term` (off iCloud).
- Remote: `github.com/bahaospanov/terminal-workflow`. Covers all modules (ghostty, lazygit, nvim, tmux) in one repo.

Implications:
- **Don't "fix" the `.git` file by re-running `git init`** — it's correct as-is. The pointer is intentional.
- The pointer path is **machine-specific** — commits only work on this Mac.
- iCloud occasionally creates `filename 2.md` conflict copies. They're harmless noise — `rm` them; don't commit them.

### Editing from another machine

The `.git` pointer is a file *inside* the working tree, so iCloud syncs it to every machine — but each machine would need it to name a *different* local git-dir path. One synced file can't hold two values, so git only works on the machine that owns the pointer. Don't try to run git on a second machine; it would rewrite the synced pointer and break the original machine too.

The working flow — **edit anywhere, commit only on the machine with the remote**:

1. Edit freely (Obsidian, editor, or an agent) on any machine. iCloud syncs files across.
2. On the machine with the bare repo (`~/artifacts/git-storage/term`), wait for iCloud to pull those edits.
3. Commit/push from there as normal.

Git here is for versioning + backup, not commit-where-you-edited.

## Committing

- **Stage by name, never `git add -A` / `git add .`.**
- **Never commit secrets.**
- Don't commit/push without an explicit authorizing word (`commit | push | ship | deploy | merge | pr`) in the user's recent message. Conventional Commits format.
