# cc-native-research-template

> Claude Code Plugin for research project lifecycle — experiment scaffold, analysis, domain expertise, and workflow enforcement.

## Quick Commands

| Command | Purpose |
|---------|---------|
| `/init-project` | Initialize research skeleton in target project |
| `/new-experiment` | Scaffold a new experiment directory |
| `/analyze-experiment` | Analyze results from current experiment |
| `/update-project-skill` | Refresh project knowledge base |

## Plugin Architecture

| Component | Location | Auto-loaded |
|-----------|----------|-------------|
| Agents (7) | agents/ | Yes (plugin.json) |
| Skills (7) | skills/ | Yes (plugin.json) |
| Hooks (5) | hooks/ | Yes (hooks.json) |
| References | references/ | No (used by init-project) |

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| project-advisor | opus | Research project — experiment history, findings, codebase navigation |
| cc-advisor | sonnet | Claude Code workflow best practices and tooling guidance |
| domain-expert | opus | Domain research — reads papers, interprets experiment results |
| exp-manager | sonnet | Experiment monitor — diagnose, retry, detect completion |
| slides-maker | sonnet | Generate HTML slides — experiment analysis or project presentations |
| viz-frontend | sonnet | Build analysis dashboards (writes to viewer/) |
| template-presenter | sonnet | Template meta — project overview, architecture docs, onboarding |

## Skills

| Skill | Trigger |
|-------|---------|
| init-project | One-command project initialization |
| new-experiment | When starting a new experiment |
| analyze-experiment | After experiment completes |
| update-project-skill | After major findings or when stale |
| present-template | Generate template overview slides |
| weekly-progress | Summarize week's progress |
| commit-changelog | Commit with CHANGELOG |

## How to Test

1. Install locally: add plugin path to settings.json
2. Create a test project: `mkdir /tmp/test-project && cd /tmp/test-project && git init`
3. Run `/init-project` and verify skeleton creation
4. Test agent override: create `.claude/agents/domain-expert.md` in test project

## Branch Strategy

- **main** = Plugin release (clean, only plugin infrastructure)
- **dev** = Development + self-use (may have override files, experiment data)

## Spec

See `docs/specs/2026-03-18-inject-template-design.md` for full design rationale.
