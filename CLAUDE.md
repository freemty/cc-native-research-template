# {PROJECT_NAME}

> {ONE_LINE_DESCRIPTION}

## Quick Commands

| Command | Purpose |
|---------|---------|
| `new-experiment` | Scaffold a new experiment directory |
| `analyze-experiment` | Analyze results from current experiment |
| `update-project-skill` | Refresh `.claude/skills/project-skill/SKILL.md` |
| `tail -f exp/{CURRENT_EXP}/results/runs.log` | Monitor live experiment loop |

## Project Knowledge

Primary skill hub: `.claude/skills/project-skill/SKILL.md`

Domain knowledge, conventions, and accumulated findings live there. Read it before advising on experiments.

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| project-advisor | sonnet | High-level research direction and prioritization |
| cc-advisor | sonnet | Claude Code workflow and tooling guidance |
| domain-expert | opus | Deep domain reasoning and hypothesis evaluation |
| slides-maker | haiku | Generate and update presentation slides |
| exp-manager | sonnet | Experiment lifecycle: scaffold, monitor, archive |
| viz-frontend | haiku | Flask viewer and matplotlib figure generation |

## Skills

| Skill | Trigger |
|-------|---------|
| update-project-skill | After major findings or milestone commits |
| new-experiment | When starting a new experiment |
| analyze-experiment | After experiment loop completes |

## Workflow

`dev` → scaffold experiment (`new-experiment`) → run loop → analyze (`analyze-experiment`) → commit findings → repeat

Pipeline state tracked in `.pipeline-state.json`. Stage advances automatically on key events.

## Conventions

- **Exp naming:** `exp{NN}{x}` — e.g., `exp01a`, `exp01b`, `exp02a`
- **Prompt versioning:** `prompts/{component}/_v{NN}.md` — never overwrite, always increment
- **CHANGELOG rule:** All iterating artifacts (prompts, skills, configs) must have a CHANGELOG section
- **Worktree rule:** Destructive or exploratory changes use `git worktree` to avoid polluting main

## Current State

- **current_exp:** {CURRENT_EXP}
- **stage:** {STAGE}
- **skill_updated_at:** {SKILL_UPDATE_DATE}
