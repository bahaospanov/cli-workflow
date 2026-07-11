# tmux config backup

iCloud-synced backup of `~/.config/tmux/tmux.conf`.

## Scripts

Shell equivalents of the `backup-tmux` / `restore-tmux` / `diff-tmux` Claude
skills — use these when you don't have agent access.

```bash
./scripts/backup-tmux.sh   # copy live tmux.conf -> this repo
./scripts/restore-tmux.sh  # copy this repo's tmux.conf -> live, install TPM/plugins, reload tmux
./scripts/diff-tmux.sh     # compare live vs backup, no changes made
```

Run them from anywhere — each resolves the repo root relative to its own
location.

- **backup-tmux.sh**: after editing the live config, run this then
  `git add tmux.conf && git commit` (never `git add -A`) and push.
- **restore-tmux.sh**: on a fresh machine or after pulling changes, run this
  to apply the backup, clone TPM and any missing plugins, and reload a
  running tmux server.
- **diff-tmux.sh**: read-only check — reports `IN SYNC`, `DIFFERS`, `ONLY IN
  BACKUP`, or `ONLY IN LIVE`, and suggests which script to run next.

`plugins/` is intentionally not tracked — it's TPM-managed clones,
reproducible from the `@plugin` lines in `tmux.conf`.
