# obra/superpowers: Agentic Skills Framework

> Source: https://github.com/obra/superpowers
> Type: Open-source agentic skills framework (not a research paper)
> Author: Jesse Vincent
> Date: 2025-10
> Date read: 2026-03-21
> Tags: agentic-workflow, skills-framework, TDD, code-review, subagents, git-worktrees

## Summary

superpowers is a composable skills framework for coding agents (102K stars, MIT license) that structures AI-assisted software development into a mandatory 7-phase sequential workflow: Brainstorming, Git Worktrees, Writing Plans, Executing Plans (subagent-driven), TDD, Code Review, and Finishing Branch. Core philosophy is "process over guessing" — enforcing structured workflows rather than letting agents freestyle. Supports Claude Code, Cursor, Codex, OpenCode, Gemini CLI.

## Architecture & Design Methodology

- **Seven-phase sequential workflow** — each phase is a gated checkpoint, not optional
- **Subagent-driven execution** — tasks dispatched to individual agents with two-stage review
- **Mandatory TDD** — RED-GREEN-REFACTOR cycle enforced, not suggested
- **Socratic brainstorming** — iterative questioning to refine design before implementation
- **Git worktree isolation** — each development branch gets clean workspace
- **Severity-based code review** — Critical/High/Medium/Low issue classification
- **Composable skills library** — skills grouped by function, not by phase

### Skills Library

| Category | Skills |
|----------|--------|
| Testing & Debugging | test-driven-development, systematic-debugging, verification-before-completion |
| Collaboration | brainstorming, writing-plans, executing-plans, dispatching-parallel-agents, requesting-code-review, receiving-code-review, using-git-worktrees, finishing-a-development-branch, subagent-driven-development |
| Meta | writing-skills, using-superpowers |

### Key Design Principles

1. **Process over guessing** — workflow constraints replace agent free-form behavior
2. **TDD as mandatory** — not optional, not "when appropriate"
3. **Simplicity as primary objective** — avoid over-engineering
4. **Evidence-based verification** — prove completion before declaring success
5. **2-5 minute task granularity** — plans broken into small, precise units

## Assumptions & Limitations

| Assumption | Type | Analysis |
|------------|------|----------|
| Tasks decompose into 2-5 min units | **Restrictive** | Research tasks (training, evaluation) run hours-to-days; granularity assumption breaks |
| Seven phases execute sequentially | **Restrictive** | Research is iterative (experiment-analyze-hypothesize-repeat), not waterfall |
| TDD is always beneficial | **Restrictive** | Exploratory scripts, data analysis, one-off experiments: TDD overhead > benefit |
| Subagents work independently | **Standard** | Common in SWE, but research tasks have strong knowledge dependencies |
| Git worktree provides sufficient isolation | **Standard** | Works for code; fails for experiment data, model checkpoints, large artifacts |
| Quality assured via review process | **Standard** | Widely accepted in industry |
| Cross-platform portability | **Restrictive** | Claims support for 5+ platforms, but tool capability gaps across platforms are undocumented |

## Bridge Analysis (vs LabMate)

**Positioning:** superpowers is LabMate's upstream dependency / recommended companion — not a competitor. superpowers handles code-level workflow; LabMate handles research-level cognition.

| Dimension | superpowers | LabMate |
|-----------|-------------|---------|
| Target user | Software engineers | Researchers |
| Core flow | Brainstorm -> Ship (7 phases) | Init -> Experiment -> Analyze -> Iterate |
| Knowledge mgmt | None (no persistence layer) | `docs/papers/` + `landscape.md` + agent memory |
| Parallelism | Subagent per task | Agent per role (domain-expert, exp-manager, etc.) |
| TDD stance | Mandatory | Available (tdd-guide agent) but not forced |
| Review model | Two-stage (auto + manual) | Hook system (pre/post/stop) |
| Time scale | Minute-level tasks | Hour-to-day-level experiments |
| State management | Git worktree | `exp/` directory + `exp/summary.md` |
| Stars | 102K | Research-focused niche |

### Borrowable Ideas

1. **Socratic brainstorming** — `/new-experiment` could add Socratic questioning before scaffold to ensure experiment design is sound
2. **Two-stage review** — `/analyze-experiment` could add cross-validation: domain-expert analyzes, then project-advisor verifies
3. **writing-skills meta-skill** — LabMate could adopt a "how to write a LabMate skill" self-bootstrap mechanism
4. **Severity-graded review output** — domain-expert experiment analysis could use Critical/High/Medium/Low classification for findings

### Not Applicable to Research

- Sequential 7-phase waterfall is too rigid for iterative research workflows
- 2-5 minute task granularity does not map to research atomic units (one full train+eval cycle)
- Mandatory TDD creates friction for exploratory/throwaway analysis code
- No knowledge accumulation layer — this is LabMate's core differentiator, must not be compromised
- Stateless subagent model loses cross-experiment knowledge dependencies
