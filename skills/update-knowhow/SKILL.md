---
name: update-knowhow
description: "Use when user says '记下来', '归档', 'save this', or after a knowhow-hint prompt. Archives environment knowledge into docs/knowhow/."
disable-model-invocation: true
---

# Update Knowhow

Archive environment knowledge (infrastructure issues, toolchain tips, debug solutions, runbooks) into structured docs.

## Pre-check

1. Verify `docs/knowhow/` exists with 4 subdirectories:
   - `docs/knowhow/infrastructure/`
   - `docs/knowhow/toolchain/`
   - `docs/knowhow/debug-solutions/`
   - `docs/knowhow/runbooks/`

   If missing, tell user: "docs/knowhow/ 不存在，请先运行 /init-project" and stop.

## Execution

### Step 1: Extract

From the current conversation context, extract:
- **Problem**: What went wrong or what needed to be set up
- **Cause**: Root cause (if debug) or context (if setup)
- **Solution**: Commands, config changes, or steps that resolved it
- **Related commands**: Exact shell commands used

### Step 2: Classify

Determine which category this belongs to:

| Category | Directory | When |
|----------|-----------|------|
| Infrastructure | `docs/knowhow/infrastructure/` | Servers, SSH, networking, disk, GPU, cloud platforms |
| Toolchain | `docs/knowhow/toolchain/` | CLI tools, docker, conda/pip, frameworks, build systems |
| Debug Solutions | `docs/knowhow/debug-solutions/` | Error investigation paths + final fix |
| Runbooks | `docs/knowhow/runbooks/` | Step-by-step procedures ("to do X on Y, first Z") |

If unclear, ask user once: "这条记录属于哪个类别？infrastructure / toolchain / debug-solutions / runbooks"

### Step 3: Dedup Check

1. Use Glob to list all `*.md` files in the target directory
2. Use Grep to search for keywords from the extracted problem/solution across those files
3. If a relevant file exists → **update that file** (append new section or revise existing content)
4. If no match → **create new file** with kebab-case slug name (e.g., `docker-build-cache.md`)

### Step 4: Write

**For new files**, use this template:

```
# {Title}

> {One-line summary}

## Problem
{What went wrong or needed setup}

## Cause
{Root cause or context}

## Solution
{Steps, commands, config changes}

## Commands
\`\`\`bash
{Exact commands used}
\`\`\`

## Notes
- Date: {YYYY-MM-DD}
- Environment: {server/platform if relevant}
```

**For existing files**, append a new `## ` section with date, or update the relevant section if the content overlaps.

### Step 5: Index Sync

1. Read `CLAUDE.md`
2. Search for `docs/knowhow/` in its content
3. If NOT found, append at the end:

```
## Knowhow
- `docs/knowhow/infrastructure/` — Servers, networking, disk, GPU issues
- `docs/knowhow/toolchain/` — CLI tools, docker, conda/pip, framework tips
- `docs/knowhow/debug-solutions/` — Error investigation paths and fixes
- `docs/knowhow/runbooks/` — Step-by-step operational procedures
```

4. If already found, skip (do not duplicate)

### Step 6: Confirm

Output a one-line summary:
> 已归档到 `docs/knowhow/{category}/{slug}.md` — {one-line description}

Or if updated:
> 已更新 `docs/knowhow/{category}/{slug}.md` — {what was added}

## Constraints

- NEVER create files outside `docs/knowhow/`
- NEVER create new subdirectories beyond the 4 fixed categories
- Prefer updating existing files over creating new ones
- Do NOT call subagents — all info is in current conversation context
- CLAUDE.md index is directory-level (4 entries), not per-file
