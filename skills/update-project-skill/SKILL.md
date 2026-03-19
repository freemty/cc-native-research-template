---
name: update-project-skill
description: "Use when project skill is stale (>24h), before context compacts, after major findings, or on first run for existing repos — regenerates project-skill/SKILL.md from current codebase."
disable-model-invocation: true
---

# Update Project Skill

Refreshes `.claude/skills/project-skill/SKILL.md` by scanning the entire project.

## Detect Mode

Check if `.claude/skills/project-skill/SKILL.md` is empty or only contains skeleton placeholder content.

- **Bootstrap mode** (first run / empty SKILL.md): deep scan, generate from scratch
- **Update mode** (existing SKILL.md): incremental update, preserve existing content

## Instructions

### Step 1: Spawn Opus subagent (read-only)

Use the Agent tool to spawn an Opus subagent. Provide different prompts depending on mode:

**Bootstrap mode prompt** (first run on existing repo):

> You are initializing the project knowledge base for the first time. Do a DEEP scan:
>
> 1. **Project identity**: Read CLAUDE.md, README.md, pyproject.toml/package.json → extract project name, description, purpose, motivation
> 2. **Architecture**: Use Glob to map directory tree. Read key entry points. Identify: what does this project do? What are the main modules?
> 3. **Design decisions**: Read docs/specs/, docs/archive/ → extract key architectural decisions and rejected alternatives
> 4. **Experiment history**: Scan exp/*/README.md → build experiment table (ID, description, status, key finding)
> 5. **Domain papers**: List docs/papers/ contents → inventory of reference material
> 6. **Prompt evolution**: Scan prompts/*/CHANGELOG.md → active versions and trade-offs
> 7. **Git milestone history**: Run `git log --oneline -50` → identify key milestones
> 8. **Known pitfalls**: Extract from exp/*/README.md "Pitfalls" sections + any LESSONS.md or troubleshooting docs
>
> Generate a complete SKILL.md. Mark as "v0 — auto-generated bootstrap, review recommended."

**Update mode prompt** (incremental refresh):

> You are refreshing the project knowledge base. Do an INCREMENTAL scan:
>
> 1. Read current `.claude/skills/project-skill/SKILL.md` — preserve structure and user-added custom sections
> 2. Read `exp/` for new or updated experiments since last update
> 3. Read `prompts/` for version changes
> 4. Run `git log --oneline -20` for recent changes
> 5. Check `docs/` for new specs or plans
>
> Update only sections that changed. CRITICAL constraints:
> - NEVER remove entries from "Key Pitfalls & Lessons Learned" (append-only)
> - NEVER downgrade experiment status ("Done" stays "Done")
> - Preserve any user-added custom sections unchanged

**Common output format for both modes:**

> Output: complete SKILL.md content with these sections (5-segment retrospective structure):
> - **Project Overview & Current State** (name, description, motivation, current stage)
> - **Architecture** (code structure, data flow, key modules)
> - **System Cognition** (core understanding: what works, what doesn't, validated hypotheses, active assumptions)
> - **Technical Archive** (key technical decisions, parameter choices, benchmark baselines, rejected alternatives with rationale)
> - **Experiment History Table** (exp → status → prediction → actual → key finding — include prediction calibration column)
> - **Prediction Calibration** (prediction vs actual meta-learning: systematic biases, calibration accuracy trends)
> - **Engineering Lessons** (APPEND-ONLY — pitfalls, debugging insights, tooling gotchas, workflow improvements)
> - **Active Prompt Versions & Trade-offs**
> - **Quick Reference** (commands, paths, env vars)

### Step 2: Show diff to user

Show diff between current and proposed SKILL.md for approval.
In bootstrap mode, show the entire generated content.

### Step 3: Write on approval

Write the updated SKILL.md.

### Step 4: Append CHANGELOG

Append entry to `.claude/skills/project-skill/CHANGELOG.md` with date and summary.
In bootstrap mode: "Initial bootstrap — auto-generated from existing codebase"

### Step 5: Update pipeline state

```python
import json, time
state = json.load(open('.pipeline-state.json'))
state['skill_updated_at'] = int(time.time())
json.dump(state, open('.pipeline-state.json', 'w'), indent=2)
```

### Step 6: Prompt next action

"Also run /commit-changelog? (Y/n)"
