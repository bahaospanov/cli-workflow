# lazygit config backup

Backup of the lazygit config (run `lazygit --print-config-dir` to find its
live location on your machine — macOS default shown below).

## Dependency

Syntax-highlighted diffs come from [`git-delta`](https://github.com/dandavison/delta),
not lazygit itself — lazygit just pipes diffs through it as a pager.

```sh
brew install git-delta
```

The `pager` line hardcodes `/opt/homebrew/bin/delta` (absolute path so it
works regardless of how lazygit is launched). Adjust if brew lives elsewhere.

## Scripts

macOS and Linux. Each resolves the live config dir for its OS and rewrites
the delta pager path to whatever's on `$PATH`.

```bash
./scripts/backup-lazygit.sh   # copy live config.yml -> this repo
./scripts/restore-lazygit.sh  # copy this repo's config.yml -> live
./scripts/diff-lazygit.sh     # compare live vs backup, no changes made
```

Run them from anywhere — each resolves the repo root relative to its own
location.

- **restore-lazygit.sh**: on a fresh machine or after pulling changes, run
  this to apply the backup (requires `git-delta` installed first). Restart
  lazygit afterward — config is not hot-reloaded.
- **backup-lazygit.sh**: after editing the live config, run this then
  `git add lazygit/config.yml && git commit` (never `git add -A`) and push.
- **diff-lazygit.sh**: read-only check, ignores delta-path differences since
  those are machine-specific.

## delta flags in use

- `--dark` — dark-terminal theme (swap for `--light` on a light theme)
- `--paging=never` — let lazygit own paging; without it delta's internal
  pager garbles the panel
- `--line-numbers` — show old/new line numbers

Optional: add `--side-by-side` for a two-column old-vs-new diff (needs a
wide terminal). Highlighting is by file extension — `delta --list-languages`
shows what's supported.
