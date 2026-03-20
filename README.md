# LabMate

![version](https://img.shields.io/badge/version-0.4.3-blue)
![license](https://img.shields.io/badge/license-MIT-green)
![agents](https://img.shields.io/badge/agents-7-orange)
![skills](https://img.shields.io/badge/skills-7-orange)
<!-- TODO: 30s demo GIF — record with VHS or asciinema -->

Research Harness for Claude Code. Keep your agent grounded in context, not lost in vibe coding.

[中文](README_ZH.md)

## The problem

You start a research project with Claude. Three hours later you're debugging a CUDA kernel and have completely forgotten what hypothesis you were testing.

Meanwhile your agent has no idea what you tried last week, can't read your reference papers, and treats every session like day one.

LabMate fixes both sides. Your agent gets persistent experiment context, domain paper knowledge, and 7 specialized agents that each know their role. You get a research lifecycle that keeps hypotheses, baselines, and findings visible, even when you're deep in implementation.

## Install

```bash
# Add marketplace
/plugin marketplace add freemty/labmate-marketplace

# Install (user scope, works across all projects)
/plugin install labmate@labmate-marketplace
```

## Quick start

1. Run `/labmate:init-project` in your existing project
2. LabMate auto-detects project name, description, domain. Confirm or edit.
3. Start researching. Your agent now knows the workflow.

See [Tutorial: your first experiment](docs/tutorial.md) for a full walkthrough.

## What's inside

7 agents, each with a specific research role:

- `@domain-expert` reads your papers, interprets results, connects findings to literature
- `@project-advisor` knows your experiment history and guides next steps
- `@exp-manager` monitors running experiments, diagnoses failures, detects completion
- `@slides-maker` turns analysis into presentation-ready HTML slides
- plus `@cc-advisor`, `@viz-frontend`, `@template-presenter`

7 skills (plugin skills use the `labmate:` prefix):

- `/labmate:new-experiment` scaffolds with config, README, run script, analysis script
- `/labmate:analyze-experiment` does domain interpretation, cross-experiment comparison, slides
- `/labmate:update-project-skill` compresses findings into persistent project memory
- plus `/labmate:init-project`, `/labmate:present-template`, `/labmate:weekly-progress`, `/labmate:commit-changelog`

6 hooks that run automatically:

- SessionStart detects project state and injects context
- PreCompact reminds to save progress before context compression
- Stop checks workflow state at session end

## Workflow

```
/labmate:init-project → /labmate:new-experiment → run → /labmate:analyze-experiment
  → commit findings → /labmate:update-project-skill → repeat
```

Pipeline state lives in `.pipeline-state.json`. Your agent picks up where you left off.

## How it compares

| Feature | labmate | [K-Dense](https://github.com/K-Dense-AI/claude-scientific-skills) | [Orchestra](https://github.com/Orchestra-Research/AI-Research-SKILLs) | [ARIS](https://github.com/conglu1997/ARIS) |
|---------|---------|---------|-----------|------|
| Deep paper reading | Yes | No | No | No |
| Experiment design | Yes | No | Partial | No |
| Research memory/context | Yes | No | No | No |
| ML experiment tracking | Yes | No | Yes | Yes |
| Paper writing pipeline | Partial | No | Partial | Partial |
| Cross-discipline support | Yes | Bio/Chem | ML/AI only | ML only |

## Customization

Override anything by creating a local copy:

```bash
# Example: customize domain-expert for your field
mkdir -p .claude/agents
# your local version automatically overrides the plugin
```

Agents, skills, and hooks are all overridable.

## Roadmap

Next up: Auto Research Agent mode. Let your agent run the full hypothesis-to-analysis loop with minimal supervision.

## Acknowledgments

- [superpowers](https://github.com/obra/superpowers) — skills framework, subagent-driven development, SessionStart hook pattern
- [frontend-slides](https://github.com/zarazhangrui/frontend-slides) — slide generation for the slides-maker agent
- [Agent-Reach](https://github.com/Panniantong/Agent-Reach) — multi-platform content fetching for the domain-expert agent

## Citing

```bibtex
@software{labmate2026,
  title   = {LabMate: Research Harness for Claude Code},
  author  = {freemty},
  year    = {2026},
  version = {0.4.3},
  url     = {https://github.com/freemty/labmate}
}
```

## License

MIT
