# Releasing a New Version

> Developer guide for publishing a new labmate release.

## Prerequisites

- On `dev` branch with all changes committed
- `scripts/release.sh` present in repo
- Marketplace repo cloned at `~/.claude/plugins/marketplaces/labmate-marketplace/`

## Steps

### 1. Bump version in plugin.json

Edit `.claude-plugin/plugin.json` and update the `version` field:

```json
{
  "version": "X.Y.Z"
}
```

Also update `README.md` version badge if present. Commit these changes on `dev`.

### 2. Run release script

```bash
./scripts/release.sh
```

The script automatically:
1. Verifies you're on `dev` with clean working tree
2. Merges `dev` into `main` (no-ff) and pushes both branches
3. Updates `marketplace.json` version and pushes marketplace repo
4. Fixes `installed_plugins.json` (all scopes: version, installPath, gitCommitSha)
5. Cleans up stale cache directories

### 3. Verify in a new session

**You must exit the current session.** The plugin loader locks the cache path at session start.

In a new session:
```
/reload-plugins
```

Then invoke any labmate skill and check the `Base directory` line in the output matches the new version.

## Troubleshooting

### release.sh fails: "uncommitted changes"

The script checks tracked files only (not untracked). If you see this, run `git status` and commit or stash the changes.

### /reload-plugins still shows old version

1. Check `installed_plugins.json` has correct version, installPath, and gitCommitSha for all scopes
2. Verify gitCommitSha belongs to the **marketplace repo**, not the source repo
3. Delete stale cache: `rm -rf ~/.claude/plugins/cache/labmate-marketplace/labmate/<old-version>`
4. Open a **new session** and run `/reload-plugins`

### marketplace.json not updating

Check that the marketplace repo is on `main` and has the latest commit:
```bash
cd ~/.claude/plugins/marketplaces/labmate-marketplace
git log --oneline -3
cat .claude-plugin/marketplace.json
```
