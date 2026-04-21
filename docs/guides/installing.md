# Installing and Updating LabMate

> User guide for installing, updating, and verifying LabMate.

## Prerequisites

- Claude Code CLI installed
- Git configured (for marketplace cloning)

## Install

### First time

```
/plugin marketplace add freemty/labmate-marketplace
/plugin install labmate@labmate-marketplace
```

Then in your research project:
```
/init-project
```

### Recommended companions

```
/plugin install superpowers
/plugin install frontend-slides
/plugin install agent-reach
```

## Update

```
/plugin update
```

Then **open a new session** and run:
```
/reload-plugins
```

The current session caches the plugin path at startup. `/reload-plugins` in the same session will re-fetch content but still use the old path. A new session is required.

### Verify

Invoke any labmate skill (e.g. `/labmate:todo list`) and check the `Base directory` line shows the expected version number.

Or check directly:
```
/plugin
```

## Troubleshooting

### Still loading old version after /plugin update

1. **Open a new session** first. This is the most common fix.

2. Check for stale project-scope installs:
```bash
grep -A5 "labmate@labmate-marketplace" ~/.claude/plugins/installed_plugins.json
```
If a `project` scope entry has an old version or installPath, update it manually or reinstall:
```
/plugin uninstall labmate@labmate-marketplace
/plugin install labmate@labmate-marketplace
```

3. Delete stale cache:
```bash
ls ~/.claude/plugins/cache/labmate-marketplace/labmate/
# Should only have the current version. Delete old ones:
rm -rf ~/.claude/plugins/cache/labmate-marketplace/labmate/<old-version>
```

### Skills not showing up

Run `/reload-plugins` in a new session. If skills still don't appear, check that the plugin is enabled:
```bash
grep labmate ~/.claude/settings.json
```
The value should not be `false`.

### "plugin not found" error

Ensure the marketplace is added:
```
/plugin marketplace add freemty/labmate-marketplace
```
Then install again.
