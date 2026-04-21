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

if [ -n "$(git status --porcelain)" ]; then
  echo "ERROR: working tree not clean, commit first"
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
git commit -m "chore: bump labmate version to v${VERSION}"
git push origin main

# 5. Done
echo "[4/4] Done!"
echo ""
echo "  labmate v${VERSION} released."
echo "  Run '/plugin update' + '/reload-plugins' to verify."
