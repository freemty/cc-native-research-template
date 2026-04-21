# LabMate

![version](https://img.shields.io/badge/version-0.9.0-blue)
![license](https://img.shields.io/badge/license-MIT-green)
<!-- TODO: 30s demo GIF — record with VHS or asciinema -->

Your AI labmate for the full research lifecycle — from reading papers to running experiments to writing them up.

[中文](README_ZH.md)

## The problem

You start a research project with Claude. Three hours later you're debugging a CUDA kernel and have completely forgotten what hypothesis you were testing.

Your agent is no better — doesn't know what you tried last week, can't read your reference papers, and treats every session like day one.

LabMate fixes both sides. It gives your agent persistent experiment memory and domain knowledge. It gives you a research flow that keeps hypotheses, baselines, and findings visible — even when you're deep in implementation.

## Install

```bash
# Add marketplace, then install
/plugin marketplace add freemty/labmate-marketplace
/plugin install labmate@labmate-marketplace
```

Then run `/init-project` in your existing research project. LabMate auto-detects your project and sets up the skeleton. Done.

### Tutorial

New to Claude Code for research? Start here: **[CC Research Playbook](https://freemty.github.io/cc-research-playbook.html)** — covers context engineering, skills, hooks, sub-agents, and how LabMate ties it all together.

### Recommended companions

LabMate works on its own, but these plugins make it better:

```bash
# Development workflow (TDD, planning, code review, brainstorming)
/plugin install superpowers

# Better slides quality (visual spec for slide generation)
/plugin install frontend-slides

# Fetch Twitter/X, XiaoHongShu, Bilibili content for paper discovery
/plugin install agent-reach
```

superpowers is strongly recommended — it powers the structured development workflow that keeps research projects from going off the rails.

## What can it do?

### Reading papers

Drop a link or PDF. LabMate breaks down the methodology, flags the assumptions, and connects it to your own work.

```
/read-paper https://arxiv.org/abs/2401.04088
```

After the deep-dive, ask follow-up questions. Say "save" when done — it archives to your literature base automatically.

Want a broader picture? Survey a whole topic:

```
/survey-literature attention sink mechanisms in Diffusion Transformers
```

### Running experiments

Describe what you want to test. LabMate scaffolds the experiment directory, config, run script, and analysis script.

```
/new-experiment
```

After you start the run, check status anytime:

```
/monitor
```

LabMate diagnoses failures, retries crashed jobs, and tells you when it's done.

### Analyzing results

One command to get domain interpretation, literature comparison, and presentation slides:

```
/analyze-experiment
```

Then see the results as an interactive dashboard:

```
/visualize
```

### Staying organized

LabMate remembers across sessions. Your experiment history, paper notes, and key findings persist. Every new session starts with context — your agent knows what stage you're at and what to do next.

Commit your work with automatic CHANGELOG updates:

```
/commit-changelog
```

## You don't need to memorize commands

LabMate tells you what to do next. After creating an experiment, it suggests `/monitor`. After analysis finishes, it suggests `/visualize`. On Fridays it reminds you to write your weekly summary. Just follow the prompts.

## The full research lifecycle

```
/init-project → /new-experiment → /monitor → /analyze-experiment → /visualize → /commit-changelog → repeat
    read papers anytime: /read-paper, /survey-literature
```

Pipeline state lives in `.pipeline-state.json`. Your agent picks up where you left off.

## How it compares

| Capability | labmate | [K-Dense](https://github.com/K-Dense-AI/claude-scientific-skills) | [Orchestra](https://github.com/Orchestra-Research/AI-Research-SKILLs) | [ARIS](https://github.com/conglu1997/ARIS) |
|------------|---------|---------|-----------|------|
| Deep paper reading | Yes | No | No | No |
| Literature survey | Yes | No | No | No |
| Experiment design | Yes | No | Partial | No |
| Research memory | Yes | No | No | No |
| Experiment monitoring | Yes | No | No | Yes |
| Results dashboard | Yes | No | No | No |
| Cross-discipline | Yes | Bio/Chem | ML/AI only | ML only |

## Customization

Override anything by creating a local copy in your project:

```bash
mkdir -p .claude/agents
# Your local .claude/agents/domain-expert.md overrides the plugin version
```

## Under the hood

5 specialized agents, 9 skills, 8 hooks working together. See [CLAUDE.md](CLAUDE.md) for the technical architecture.

## Acknowledgments

- [superpowers](https://github.com/obra/superpowers) — skills framework and development workflow
- [frontend-slides](https://github.com/zarazhangrui/frontend-slides) — slide generation engine
- [Agent-Reach](https://github.com/Panniantong/Agent-Reach) — multi-platform content fetching

## Citing

```bibtex
@software{labmate2026,
  title   = {LabMate: Research Harness for Claude Code},
  author  = {freemty},
  year    = {2026},
  version = {0.5.0},
  url     = {https://github.com/freemty/labmate}
}
```

## License

MIT
