# {project-name}

> {description}

## Quick Commands

| Command | Purpose |
|---------|---------|
| /init-project | Initialize research skeleton |
| /new-experiment | Scaffold new experiment |
| /analyze-experiment | Analyze results |
| /update-project-skill | Refresh project knowledge |
| python scripts/launch_exp.py --exp <id> | Launch experiment |

## Session Startup

| 要做什么 | 先读什么 |
|---------|--------|
| 了解当前进展 | .claude/skills/project-skill/SKILL.md |
| 查阅领域文献 | docs/papers/landscape.md |
| 运行实验 | exp/{current_exp}/README.md |

## Project Knowledge

- **Primary skill hub:** .claude/skills/project-skill/SKILL.md
- **Experiment log:** exp/summary.md
- **Domain papers:** docs/papers/

## Agents

| Agent | Model | Purpose | Source |
|-------|-------|---------|--------|
| project-advisor | opus | 研究项目顾问 | plugin |
| cc-advisor | sonnet | CC 最佳实践 | plugin |
| domain-expert | opus | 领域研究专家 | plugin |
| exp-manager | sonnet | 实验监控 | plugin |
| slides-maker | sonnet | 幻灯片生成 | plugin |
| viz-frontend | sonnet | 可视化仪表盘 | plugin |
| template-presenter | sonnet | 模板介绍 | plugin |

## Skills

| Skill | Trigger | Source |
|-------|---------|--------|
| init-project | 初始化项目骨架 | plugin |
| new-experiment | 开始新实验 | plugin |
| analyze-experiment | 实验完成后分析 | plugin |
| update-project-skill | 更新项目知识 | plugin |
| present-template | 生成模板介绍 | plugin |
| weekly-progress | 周报总结 | plugin |
| commit-changelog | 提交 + CHANGELOG | plugin |

## Workflow

dev -> /new-experiment -> run experiment -> /analyze-experiment
  -> commit findings -> /update-project-skill -> repeat

Pipeline state tracked in .pipeline-state.json.

## Research Principles

1. **Measure first** — 攻击实测最大瓶颈，不凭直觉
2. **Baseline 不可侵犯** — 每个 claim 必须有可复现 baseline 对比
3. **统计显著性** — 单次结果不下结论，关注方差
4. **Ablation 驱动** — 多因素改动逐一隔离
5. **尊重负面结论** — 方向不重复，除非有新证据
6. **预测先行** — 实验前记录预期数值范围，实验后校准

## Conventions

- **Exp naming:** exp{NN}{x} — number=major, letter=variant
- **Prompt versioning:** prompts/{component}/_v{NN}.md — never overwrite
- **CHANGELOG rule:** all iterating artifacts must have CHANGELOG entries
- **Worktree rule:** destructive/exploratory changes use git worktree

## Current State

- **current_exp:** null
- **stage:** dev
- **skill_updated_at:** {date}
