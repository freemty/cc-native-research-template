#!/bin/bash
set -euo pipefail

MARKETPLACE_DIR="$HOME/.claude/plugins/marketplaces/labmate-marketplace"
MARKETPLACE_JSON="$MARKETPLACE_DIR/.claude-plugin/marketplace.json"
PLUGIN_JSON=".claude-plugin/plugin.json"

VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['version'])")

echo "=== Releasing labmate v${VERSION} ==="

# 1. Verify on dev branch with clean state
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "dev" ]; then
  echo "ERROR: must be on dev branch (currently on $BRANCH)"
  exit 1
fi

if [ -n "$(git diff --name-only HEAD)" ] || [ -n "$(git diff --cached --name-only)" ]; then
  echo "ERROR: uncommitted changes, commit first"
  exit 1
fi

# 2. Merge dev → main
echo "[1/4] Merging dev → main..."
git checkout main
git merge dev --no-ff -m "release: v${VERSION}"

# 3. Push both branches
echo "[2/4] Pushing main + dev..."
git push origin main
git checkout dev
git push origin dev

# 4. Sync marketplace.json version
echo "[3/4] Syncing marketplace.json → v${VERSION}..."
if [ ! -f "$MARKETPLACE_JSON" ]; then
  echo "ERROR: marketplace.json not found at $MARKETPLACE_JSON"
  exit 1
fi

python3 -c "
import json, pathlib
p = pathlib.Path('$MARKETPLACE_JSON')
data = json.loads(p.read_text())
data['plugins'][0]['version'] = '$VERSION'
p.write_text(json.dumps(data, indent=2) + '\n')
"

cd "$MARKETPLACE_DIR"
git add .claude-plugin/marketplace.json
if git diff --cached --quiet; then
  echo "  marketplace.json already at v${VERSION}, skipping"
else
  git commit -m "chore: bump labmate version to v${VERSION}"
  git push origin main
fi

# 5. Fix installed_plugins.json — update all labmate entries to new version + correct SHA
echo "[4/4] Fixing installed_plugins.json..."
INSTALLED="$HOME/.claude/plugins/installed_plugins.json"
CACHE_PATH="$HOME/.claude/plugins/cache/labmate-marketplace/labmate/${VERSION}"
MARKETPLACE_SHA=$(cd "$MARKETPLACE_DIR" && git rev-parse HEAD)
if [ -f "$INSTALLED" ]; then
  python3 -c "
import json, pathlib
p = pathlib.Path('$INSTALLED')
data = json.loads(p.read_text())
entries = data.get('plugins', {}).get('labmate@labmate-marketplace', [])
changed = False
for e in entries:
    needs_update = (
        e.get('version') != '$VERSION'
        or e.get('installPath') != '$CACHE_PATH'
        or e.get('gitCommitSha') != '$MARKETPLACE_SHA'
    )
    if needs_update:
        e['version'] = '$VERSION'
        e['installPath'] = '$CACHE_PATH'
        e['gitCommitSha'] = '$MARKETPLACE_SHA'
        changed = True
if changed:
    p.write_text(json.dumps(data, indent=2) + '\n')
    print(f'  Updated {len(entries)} entries to v$VERSION (sha: $MARKETPLACE_SHA)')
else:
    print('  All entries already at v$VERSION')
"
fi

# 6. Clean up stale cache versions
echo "[5/5] Cleaning stale cache..."
CACHE_BASE="$HOME/.claude/plugins/cache/labmate-marketplace/labmate"
for dir in "$CACHE_BASE"/*/; do
  dir_version=$(basename "$dir")
  if [ "$dir_version" != "$VERSION" ]; then
    rm -rf "$dir"
    echo "  Removed stale cache: $dir_version"
  fi
done

# 7. Done
echo ""
echo "  labmate v${VERSION} released."
echo "  Run '/reload-plugins' in a new session to verify."
