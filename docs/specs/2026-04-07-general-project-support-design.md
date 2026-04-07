# General Project Support — Design Spec

> Make init-project work for general software projects, not just research/experiment-driven ones.

**Date:** 2026-04-07
**Status:** Draft

---

## Motivation

LabMate's `/init-project` currently scaffolds a full research project skeleton: `exp/`, `scripts/`, `viewer/`, `slides/`, paper landscape, etc. Many projects (LLM Wiki, reader apps, general tools) only need:

- Project knowledge maintenance (project-skill, CLAUDE.md)
- Environment knowledge accumulation (knowhow)
- Domain expert context
- Commit & changelog workflow

The current init-project is too heavy for these projects.

## Design

### Project Type Selection

Add a `type` field with two values: `research` (current behavior) and `general` (new lightweight mode).

**Step 2 of init-project** adds type selection after existing info gathering:

```
项目类型：research / general（默认 general）
```

**Auto-inference**: if project has `exp/` directory or README contains experiment/benchmark/training keywords, default to `research`. Otherwise default to `general`.

### Directory Structure by Type

| Component | general | research |
|-----------|---------|----------|
| `docs/specs/` | Yes | Yes |
| `docs/knowhow/` (4 subdirs) | Yes | Yes |
| `docs/papers/` + `landscape.md` | No | Yes |
| `docs/weekly/` | No | Yes |
| `docs/archive/` | No | Yes |
| `exp/` + `summary.md` | No | Yes |
| `scripts/` (launch_exp, monitor_exp, download_results) | No | Yes |
| `viewer/` | No | Yes |
| `slides/` | No | Yes |
| `.claude/skills/project-skill/` | Yes | Yes |
| `.pipeline-state.json` | Yes | Yes |
| `CHANGELOG.md` | Yes | Yes |

### .pipeline-state.json

Unified structure for both types. Add `type` field:

```json
{
  "type": "general",
  "project_name": "llm-wiki",
  "description": "Personal knowledge base powered by LLMs",
  "domain": "knowledge management",
  "compute_env": "local",
  "current_exp": null,
  "stage": "dev",
  "skill_updated_at": null
}
```

Research projects get `"type": "research"`.

### CLAUDE.md Templates

Two separate template files:

- `references/claude-md-template-research.md` — renamed from current `claude-md-template.md`
- `references/claude-md-template-general.md` — new file

**General template includes:**
- Quick commands: update-project-skill, commit-changelog, update-knowhow
- Session startup: project-skill reference
- Project knowledge index
- Knowhow index (4 directories)
- Agents table: project-advisor, domain-expert only
- Conventions: CHANGELOG rule, worktree rule

**General template excludes:**
- Research principles
- Experiment naming conventions
- Prompt versioning rules
- Experiment workflow diagram
- Pipeline current state section
- Experiment-related agents (exp-manager) and skills (new-experiment, analyze-experiment, monitor)

### .gitignore Rules

No file split. SKILL.md filters rules by type at write time.

**General projects** — only append:
```gitignore
# labmate rules
.pipeline-state.json
.labmate-hook-state.json
```

**Research projects** — append full current `references/gitignore-rules.md` (papers, slides, exp results, etc.).

### Impact on Other Skills

| Skill | Change needed |
|-------|--------------|
| update-project-skill | None — reads .pipeline-state.json which has unified structure |
| commit-changelog | None — weekly mode already handles missing exp/summary.md gracefully |
| update-knowhow | None — only depends on docs/knowhow/ |
| new-experiment | None — research-only, general projects won't invoke it |
| analyze-experiment | None — research-only |
| monitor | None — research-only |

## Files Changed

1. **`skills/init-project/SKILL.md`** — Add type selection to Step 2. Branch Step 3 by type. Branch Step 4 template selection. Branch Step 5 gitignore filtering.
2. **`references/claude-md-template.md`** — Rename to `references/claude-md-template-research.md`
3. **New: `references/claude-md-template-general.md`** — Lightweight CLAUDE.md template
4. **`references/gitignore-rules.md`** — No change (filtering done in SKILL.md)
