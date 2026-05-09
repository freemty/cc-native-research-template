---
name: update-docs
description: >
  Unified document archival — covers both agent-facing knowhow (env setup, debug,
  infra, runbooks) and human-facing docs (design, guides, README, changelog).
  Triggers on: "update docs", "更新文档", "写 README", "记下来", "归档", "save this",
  "update knowhow", or after a <knowhow-hint> prompt. Also triggers when conversation
  context implies documentation should be created or updated.
disable-model-invocation: true
---

# /update-docs

Unified document archival. One workflow, two branches: **knowhow** (agent-facing environment knowledge) and **docs** (human-facing documentation). Route automatically — never ask the user which branch.

## Usage

```
/update-docs                     — Auto-detect from conversation context
/update-docs <description>       — Natural language description of what to document
/update-docs <path>              — Update existing doc at path
/update-knowhow                  — Alias, same workflow (routes to knowhow branch)
```

---

## Step 1: Route

Determine which branch to use based on context. Never ask — decide yourself.

| Signal | Branch |
|--------|--------|
| Debug resolution, error fix, workaround | **knowhow** |
| Server/GPU/networking/disk setup | **knowhow** |
| CLI tool, docker, conda/pip discovery | **knowhow** |
| Step-by-step ops procedure (SSH tunnel, deploy) | **knowhow** |
| After a `<knowhow-hint>` prompt | **knowhow** |
| After a `<docs-hint>` prompt | **docs** |
| After a `<archive-hint>` prompt | **auto** (inspect context, pick the right branch) |
| User said "记下来", "归档", "save this" | **knowhow** |
| Design decisions, architecture | **docs** |
| How-to guides for humans | **docs** |
| README, CHANGELOG, getting started | **docs** |
| User said "写文档", "write docs", "update README" | **docs** |
| Invoked via /update-knowhow | **knowhow** |
| Explicit path to `docs/knowhow/` | **knowhow** |
| Explicit path outside `docs/knowhow/` | **docs** |

---

## Branch A: Knowhow

Archive environment knowledge into `docs/knowhow/`. Fixed 4 categories, fixed template, dedup-first.

### Categories

| Category | Directory | Signals |
|----------|-----------|---------|
| Infrastructure | `docs/knowhow/infrastructure/` | Servers, SSH, networking, disk, GPU, cloud platforms |
| Toolchain | `docs/knowhow/toolchain/` | CLI tools, docker, conda/pip, frameworks, build systems |
| Debug Solutions | `docs/knowhow/debug-solutions/` | Error investigation paths + final fix |
| Runbooks | `docs/knowhow/runbooks/` | Step-by-step procedures ("to do X on Y, first Z") |

### Pre-check

Verify `docs/knowhow/` exists with all 4 subdirectories. If missing: "docs/knowhow/ 不存在，请先运行 /init-project" — stop.

### A1: Extract

From conversation context, extract:
- **Problem**: What went wrong or needed setup
- **Cause**: Root cause (debug) or context (setup)
- **Solution**: Commands, config changes, steps that resolved it
- **Commands**: Exact shell commands used

### A2: Classify

Pick the best-fit category from the table above. Never ask the user — make the judgment call yourself based on the extracted content.

### A3: Dedup Check

1. Glob `docs/knowhow/{category}/*.md`
2. Grep keywords from extracted problem/solution across matches
3. Match found → **update that file** (append or revise)
4. No match → **create new file** with kebab-case slug (e.g., `docker-build-cache.md`)

### A4: Write

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

### A5: Index Sync

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

### A6: Confirm

> 已归档到 `docs/knowhow/{category}/{slug}.md` — {one-line description}

Or: 已更新 `docs/knowhow/{category}/{slug}.md` — {what was added}

---

## Branch B: Docs

Create or update human-facing structured documents with automatic CLAUDE.md indexing.

### B1: Determine Intent

**With args:** Parse to identify target path, operation (create/update), or infer from natural language.

**Without args:** Analyze conversation context:
- Design decisions discussed → `docs/design/` or `docs/specs/`
- Step-by-step procedures for humans → `docs/guides/`
- Feature completed → README update or new guide
- Version bumps → CHANGELOG update

Produce a one-line summary of what you plan to create/update and proceed immediately.

### Document Types

| Type | Default Path | Template |
|------|-------------|----------|
| design | `docs/design/{name}.md` | Overview, Architecture, API, Trade-offs |
| guide | `docs/guides/{name}.md` | Prerequisites, Steps, Troubleshooting |
| readme | `README.md` | Project README |
| changelog | `CHANGELOG.md` | Version changelog |
| custom | user-specified | Title + content |

### B2: Gather Context

```bash
ls -la
git log --oneline -20
```

For **updates**: read the current file, identify stale or missing sections.
For **creates**: scan codebase for relevant code to document.

### B3: Write Document

**Create:** Generate from type template + gathered context → write → index.

**Update:** Read existing → identify stale sections → edit (preserve user-written sections) → verify index.

### B4: Auto-Index in CLAUDE.md

| Path pattern | Index action |
|--------------|-------------|
| `docs/specs/*.md` or `docs/design/*.md` | Add to Specs section |
| `docs/guides/*.md` | Add to Guides section (create if absent) |
| `README.md`, `CHANGELOG.md` | Skip (already discoverable) |
| Custom paths | Add to most relevant section |

Check before adding: `grep -q "<path>" CLAUDE.md` — only add if not present.

### B5: Report

- What was created/updated
- What sections changed (for updates)
- Index entry status

---

## Common Mistakes

| Mistake | Correct |
|---------|---------|
| Asking user to pick a type or category | Infer from context, execute |
| Creating new knowhow file without dedup check | Always grep existing files first |
| Writing agent-facing knowledge to docs/ | That's knowhow → Branch A |
| Writing human-facing docs to docs/knowhow/ | That's docs → Branch B |
| Overwriting user-written content | Only update generated/stale sections |
| Forgetting CLAUDE.md index | Always check + add/update |
| Creating new knowhow subdirectories | Only 4 fixed categories allowed |
| Calling subagent | All info is in conversation context, execute directly |
