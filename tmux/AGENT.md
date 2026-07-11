# AGENT.md — for agents working in this directory

This is **not an app**. It's a backup of Bakhtiyar's tmux config. No build, no tests, no run step.

## Unusual git layout — read before touching git

The working tree lives **inside an iCloud-synced Obsidian vault**. To stop iCloud from corrupting the repo, git was set up with `--separate-git-dir`:

- `.git` here is a **pointer file**, not a directory: it contains `gitdir: /Users/baha/artifacts/git-storage/tmux-config`.
- The real git database lives at `~/artifacts/git-storage/tmux-config` (off iCloud).

Implications:
- **Don't "fix" the `.git` file by re-running `git init`** — it's correct as-is. The pointer is intentional.
- The pointer path is **machine-specific** — commits only work on this Mac.
- iCloud occasionally creates `filename 2.md` conflict copies. They're harmless noise — `rm` them; don't commit them.

### Editing from another machine

The `.git` pointer syncs via iCloud but is machine-specific. Don't run git on a second machine.

Edit freely anywhere; commit only on the machine with `~/artifacts/git-storage/tmux-config`.

## Committing

- **Stage by name, never `git add -A` / `git add .`.**
- **Never commit secrets.**
- Don't commit/push without an explicit authorizing word (`commit | push | ship | deploy | merge | pr`) in the user's recent message. Conventional Commits format.

## File map

- `CHEATSHEET tmux.md` — tmux keybindings and commands reference.
- `MINDMAP.excalidraw` — visual mindmap (Excalidraw format).
