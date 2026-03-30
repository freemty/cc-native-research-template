---
name: update-knowhow
description: "Use when user says '记下来', '归档', 'save this', or after a knowhow-hint prompt. Triggers on environment setup, debug resolution, infrastructure troubleshooting, or operational procedure discovery."
disable-model-invocation: true
---

# Update Knowhow

Archive environment knowledge into structured `docs/knowhow/` directories. Dedup-first: update existing files before creating new ones. Auto-sync CLAUDE.md index.

## Quick Reference

| Category | Directory | Signals |
|----------|-----------|---------|
| Infrastructure | `docs/knowhow/infrastructure/` | Servers, SSH, networking, disk, GPU, cloud platforms |
| Toolchain | `docs/knowhow/toolchain/` | CLI tools, docker, conda/pip, frameworks, build systems |
| Debug Solutions | `docs/knowhow/debug-solutions/` | Error investigation paths + final fix |
| Runbooks | `docs/knowhow/runbooks/` | Step-by-step procedures ("to do X on Y, first Z") |

## Pre-check

Verify `docs/knowhow/` exists with all 4 subdirectories. If missing: "docs/knowhow/ 不存在，请先运行 /init-project" — stop.

## Execution

### Step 1: Extract

From conversation context, extract:
- **Problem**: What went wrong or needed setup
- **Cause**: Root cause (debug) or context (setup)
- **Solution**: Commands, config changes, steps that resolved it
- **Commands**: Exact shell commands used

### Step 2: Classify

Pick one category from Quick Reference. If unclear, ask user once.

### Step 3: Dedup Check

1. Glob `docs/knowhow/{category}/*.md`
2. Grep keywords from extracted problem/solution across matches
3. Match found → **update that file** (append or revise)
4. No match → **create new file** with kebab-case slug (e.g., `docker-build-cache.md`)

### Step 4: Write

New file template:

```markdown
# {Title}

> {One-line summary}

## Problem
{What went wrong or needed setup}

## Cause
{Root cause or context}

## Solution
{Steps, commands, config changes}

## Commands
```bash
{Exact commands used}
```

## Notes
- Date: {YYYY-MM-DD}
- Environment: {server/platform if relevant}
```

Existing file: append `## {Topic} ({date})` section, or update overlapping content in-place.

### Step 5: Index Sync

1. Read `CLAUDE.md`, search for `docs/knowhow/`
2. If NOT found, append:

```markdown
## Knowhow
- `docs/knowhow/infrastructure/` — Servers, networking, disk, GPU issues
- `docs/knowhow/toolchain/` — CLI tools, docker, conda/pip, framework tips
- `docs/knowhow/debug-solutions/` — Error investigation paths and fixes
- `docs/knowhow/runbooks/` — Step-by-step operational procedures
```

3. If found, skip

### Step 6: Confirm

> 已归档到 `docs/knowhow/{category}/{slug}.md` — {one-line description}

Or: 已更新 `docs/knowhow/{category}/{slug}.md` — {what was added}

## Common Mistakes

- **创建新文件而非更新** — 永远先 dedup check，已有相关文件就更新
- **在 docs/knowhow/ 之外创建文件** — 所有 knowhow 必须在 4 个固定目录内
- **新建子目录** — 只有 4 个固定类别，不允许新增
- **调用 subagent** — 所有信息都在当前对话上下文，直接执行
- **逐文件索引 CLAUDE.md** — 索引粒度是目录级（4 条），不是文件级
