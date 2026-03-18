# cc-native-research-template

> Claude Code native research project template — standardized agents, skills, hooks, and experiment lifecycle

## Quick Commands

| Command | Purpose |
|---------|---------|
| `/new-experiment` | Scaffold a new experiment directory |
| `/analyze-experiment` | Analyze results from current experiment |
| `/update-project-skill` | Refresh project knowledge base |
| `python scripts/launch_exp.py --exp <id>` | Launch experiment runs |
| `python viewer/app.py` | Start analysis viewer (port 5001) |
| `tail -f exp/null/results/runs.log` | Monitor live experiment |

## Project Knowledge

- **Primary skill hub:** `.claude/skills/project-skill/SKILL.md` — read this before advising on experiments
- **Experiment log:** `exp/summary.md` — cross-experiment flight recorder
- **Domain papers:** `docs/papers/` — reference material for domain-expert agent

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| project-advisor | opus | Research project — experiment history, findings, codebase navigation |
| cc-advisor | sonnet | Claude Code workflow best practices and tooling guidance |
| domain-expert | opus | Domain research — reads papers, interprets experiment results |
| slides-maker | sonnet | Generate HTML slides — experiment analysis or project presentations |
| exp-manager | sonnet | Experiment monitor — diagnose, retry, detect completion |
| viz-frontend | sonnet | Build analysis dashboards (writes to viewer/) |
| template-presenter | sonnet | Template meta — project overview, architecture docs, onboarding |

## Skills

| Skill | Trigger |
|-------|---------|
| update-project-skill | After major findings, before context compacts, or when stale (>24h) |
| new-experiment | When starting a new experiment |
| analyze-experiment | After experiment completes — runs analysis, domain interpretation, slides |
| present-template | Generate template overview slides, onboarding docs, or demo scripts |

## Workflow

`dev` → `/new-experiment` → run experiment → `/analyze-experiment` → commit findings → `/update-project-skill` → repeat

Pipeline state tracked in `.pipeline-state.json`. Hooks remind next action per stage.

## Conventions

- **Exp naming:** `exp{NN}{x}` — e.g., `exp01a`, `exp01b`, `exp02a` (number=major, letter=variant)
- **Prompt versioning:** `prompts/{component}/_v{NN}.md` — never overwrite, always increment
- **CHANGELOG rule:** All iterating artifacts (prompts, skills, agents) must have CHANGELOG entries
- **Worktree rule:** Destructive or exploratory changes use `git worktree` to avoid polluting main

## Current State

- **current_exp:** null
- **stage:** dev
- **skill_updated_at:** 2026-03-18
