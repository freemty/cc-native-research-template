# {PROJECT_NAME}

> {ONE_LINE_DESCRIPTION}

## Quick Commands

| Command | Purpose |
|---------|---------|
| `/new-experiment` | Scaffold a new experiment directory |
| `/analyze-experiment` | Analyze results from current experiment |
| `/update-project-skill` | Refresh project knowledge base |
| `python scripts/launch_exp.py --exp <id>` | Launch experiment runs |
| `python viewer/app.py` | Start analysis viewer (port 5001) |
| `tail -f exp/null/results/runs.log` | Monitor live experiment |

## Session Startup

| 要做什么 | 先读什么 |
|---------|--------|
| 了解当前进展 | `.claude/skills/project-skill/SKILL.md` |
| 查阅领域文献 | `docs/papers/landscape.md` |
| 运行实验 | `exp/{current_exp}/README.md` + config.yaml |
| 了解模板架构 | 问 @template-presenter |

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
| weekly-progress | Summarize week's CHANGELOG + experiments into docs/weekly/ (Friday hook reminder) |

## Workflow

`dev` → `/new-experiment` → run experiment → `/analyze-experiment` → commit findings → `/update-project-skill` → repeat

Pipeline state tracked in `.pipeline-state.json`. Hooks remind next action per stage.

## Research Principles

1. **Measure first** — 攻击实测最大瓶颈，不凭直觉
2. **Baseline 不可侵犯** — 每个 claim 必须有可复现 baseline 对比
3. **统计显著性** — 单次结果不下结论，关注方差
4. **Ablation 驱动** — 多因素改动逐一隔离
5. **尊重负面结论** — ❌ 方向不重复，除非有新证据
6. **预测先行** — 实验前记录预期数值范围，实验后校准

## Conventions

- **Exp naming:** `exp{NN}{x}` — e.g., `exp01a`, `exp01b`, `exp02a` (number=major, letter=variant)
- **Prompt versioning:** `prompts/{component}/_v{NN}.md` — never overwrite, always increment
- **CHANGELOG rule:** All iterating artifacts (prompts, skills, agents) must have CHANGELOG entries
- **Worktree rule:** Destructive or exploratory changes use `git worktree` to avoid polluting main

## Current State

- **current_exp:** null
- **stage:** dev
- **skill_updated_at:** {SKILL_UPDATE_DATE}
