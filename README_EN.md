# cc-native-research-template

English | **[中文](README.md)**

> In the age of agents, keep asking: can this project go one meta-level higher with agents?

## Why

We built three agent-driven research projects (fars-reviewer, PostTrainBench, hle-solver) and kept rebuilding the same scaffolding every time: how to organize experiments, version prompts, track papers, analyze results, generate slides, persist knowledge across context windows.

The research content differs completely. The infrastructure doesn't. So we extracted the common parts into this template.

## What

A GitHub template repo that provides a complete Claude Code research harness:

- 7 agents (4 read-only advisors + 2 scoped-write builders + 1 background slides generator)
- 7 skills (experiment scaffolding, analysis pipeline, knowledge updates, slides, weekly reports, commits)
- 5 hooks (remind-based, no hard blocks)
- Experiment infrastructure (standardized naming, shared analysis utilities, cross-experiment records)
- Auto-maintained project knowledge (hooks remind you to update before context compaction)

The template gives you infrastructure, not research content.

## Agents

| Agent | Model | What it does |
|-------|-------|-------------|
| project-advisor | opus | Experiment history, research findings, codebase navigation |
| cc-advisor | sonnet | Claude Code workflow best practices |
| domain-expert | opus | Read papers, interpret results, maintain literature landscape |
| slides-maker | sonnet | Generate HTML slides in background (analysis or presentation) |
| exp-manager | sonnet | Monitor experiments, diagnose failures, retry jobs |
| viz-frontend | sonnet | Flask + HTML analysis dashboards |
| template-presenter | sonnet | Template overview slides, architecture docs, onboarding |

## Skills

| Skill | When to use | What it does |
|-------|------------|-------------|
| `/new-experiment` | Starting a new experiment | Scaffold `exp/{id}/` directory |
| `/analyze-experiment` | Experiment completed | Analysis → @domain-expert → @slides-maker |
| `/update-project-skill` | Knowledge stale (>24h) | Opus scans project → regenerates SKILL.md |
| `/present-template` | Need overview slides | @template-presenter → @slides-maker |
| `/weekly-progress` | Friday reminder | CHANGELOG + git log → `docs/weekly/` |
| `/commit-changelog` | Ready to commit | Standardized commits + CHANGELOG |

## Quick Start

**1.** Click "Use this template" on GitHub to create your repo

**2.** Bootstrap — answer 4 questions (project name, description, research domain, compute environment)

```bash
cd your-new-repo
bash bootstrap.sh
```

**3.** Create your first experiment

```
/new-experiment
```

**4.** Run → analyze → update knowledge

```
python exp/exp01a/run.py --config exp/exp01a/config.yaml
/analyze-experiment
/update-project-skill
```

Full cycle: `dev` → `/new-experiment` → run → `/analyze-experiment` → commit → `/update-project-skill` → repeat.

## Architecture

```
your-project/
├── CLAUDE.md                     # Route hub (<80 lines)
├── .claude/
│   ├── agents/                   # 7 agent definitions
│   ├── skills/                   # 7 skills
│   ├── hooks/                    # 5 hook scripts
│   └── settings.local.json      # Permissions + hook config
├── exp/                          # Experiments (exp{NN}{x} naming)
│   ├── lib/                      # Shared analysis utilities
│   └── summary.md                # Cross-experiment flight recorder
├── docs/papers/                  # Papers + landscape.md
├── prompts/                      # Versioned prompts (_v{NN}.md)
├── scripts/                      # Launch, monitor, download
├── slides/                       # Generated presentations
│   └── references/               # Visual spec
├── viewer/                       # Flask analysis dashboard
├── bootstrap.sh                  # First-run personalization
└── .pipeline-state.json          # Workflow state machine
```

Design principles: least-privilege agents (4/7 read-only); hooks remind but never block; heavy output delegated to background agents; all knowledge in repo, not chat history; optimize for agent readability first, human aesthetics second.

## Research Principles

1. Measure first, don't guess
2. Baseline is sacred — every claim needs a reproducible comparison
3. Single-run results are anecdotes, not conclusions — watch the variance
4. Multi-factor changes require per-factor ablation
5. Negative results get marked ❌ and aren't retried without new evidence
6. Write predicted values before running, calibrate after

## Applying to Existing Repos

Already have a research repo? No need to start over.

```bash
# Copy infrastructure
cp -r template/.claude/ your-repo/.claude/
cp template/bootstrap.sh your-repo/
cp -r template/slides/references/ your-repo/slides/references/

# Initialize
cd your-repo && bash bootstrap.sh

# First knowledge scan (deep scan of existing code and experiments)
/update-project-skill
```

## First User

[PostTrainBench](https://github.com/freemty/PostTrainBench) — an agent that iterates on auto post-training. It runs experiments, analyzes results, reads papers, updates its own knowledge base, and decides what to try next.

This is what we mean by scalable self-awareness: the agent doesn't just execute your tasks — it maintains the infrastructure that makes it smarter over time.

## References

- [OpenAI — Harness Engineering](https://openai.com/zh-Hans-CN/index/harness-engineering/)
- [Anthropic — Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Anthropic — Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Manus — Context Engineering](https://manus.im/blog/Context-Engineering-for-AI-Agents)
- [AReaL / Starcat](https://zhuanlan.zhihu.com/p/2003269671630165191)
- [Superpowers](https://github.com/obra/superpowers)

## License

MIT
