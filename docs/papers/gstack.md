# gstack: Garry Tan's Claude Code Framework

> Source: https://github.com/garrytan/gstack
> Type: Open-source development framework (not a research paper)
> Date read: 2026-03-21

## Summary

gstack is a Claude Code skill pack that structures AI-assisted development into a 7-phase Sprint framework (Think -> Plan -> Build -> Review -> Test -> Ship -> Reflect). Created by Garry Tan (YC CEO), it provides 15 skills and 6 power tools as slash commands, with a Conductor-based parallelism model for running 10-15 independent Sprints simultaneously.

## Architecture & Design Methodology

- **Phase-gated Sprint framework** — each skill guards a specific lifecycle phase
- **Workflow orchestration** pattern, not free-form agent conversation
- **Embarrassingly parallel** Sprint model via Conductor — no shared state between Sprints
- **Safety tool group** — `/careful` (destructive warnings), `/freeze` (edit scope), `/guard` (combined)
- **Multi-AI cross-review** — `/codex` brings in OpenAI as second opinion

### Key Skills

| Phase | Skills |
|-------|--------|
| Planning | `/office-hours`, `/plan-ceo-review`, `/plan-eng-review` |
| Design | `/design-consultation`, `/plan-design-review` |
| Implementation | `/review`, `/investigate`, `/design-review` |
| Testing | `/qa`, `/qa-only` |
| Release | `/ship`, `/document-release` |
| Utilities | `/browse`, `/setup-browser-cookies`, `/retro` |

## Claims & Evidence Assessment

| Claim | Assessment |
|-------|-----------|
| 600K lines in 60 days | Unverifiable — no definition of "production code", no independent audit |
| 10-20K usable lines/day | "Usable" undefined, no defect rate or tech debt metrics |
| GitHub contributions 2026 vs 2013 | Commit frequency != code quality; different era, different habits |

## Assumptions & Limitations

- Assumes Sprints can be fully isolated — ignores implicit module dependencies and merge conflicts
- 7-phase linear process may be too heavy for exploratory coding, prototyping, or hotfixes
- 10-15 parallel Sprints managed by one person — context switching cost undiscussed
- No merge conflict management strategy documented
- No failure recovery / rollback strategy
- No quality metrics beyond line count

## Bridge Analysis (vs LabMate)

**Complementary positioning:** gstack optimizes code output speed; LabMate optimizes research cognition accumulation.

| Dimension | gstack | LabMate |
|-----------|--------|---------|
| Target user | Product engineers | Researchers |
| Core flow | Think->Ship (7 phases) | Init->Experiment->Analyze->Iterate |
| Agents | 0 explicit agents, 15 skills | 5 agents + 9 skills + 8 hooks |
| Parallelism | Conductor (10-15 Sprints) | Single agent dispatch |
| Knowledge mgmt | `/retro` only, no persistence | `docs/papers/` + `landscape.md` |
| Safety | `/careful` + `/freeze` + `/guard` | Hook system (pre/post/stop) |

### Borrowable Ideas

1. **Phase gates** — insert `/review-experiment-design` gate between `/new-experiment` and execution
2. **Freeze scope** — protect experiment directories from accidental edits
3. **Multi-model cross-review** — let different models independently analyze same results as "peer review"
4. **Self-upgrade mechanism** — `/gstack-upgrade` pattern for plugin updates

### Not Applicable to Research

- "Lines of code" productivity metric irrelevant for research
- Stateless parallelism loses cross-experiment dependencies
- No knowledge accumulation layer (no landscape.md equivalent)
- Full Sprint too heavy for "tweak hyperparams and run ablation"
