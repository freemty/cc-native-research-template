# Effective Harnesses for Long-Running Agents — Deep Dive

> Source: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
> Type: Engineering blog post (Anthropic)
> Date: 2025-11
> Read date: 2026-03-21

## Summary

Anthropic's engineering team presents a two-agent architecture for sustaining AI agent progress across multiple context windows. The core insight: externalize all progress state (feature list, progress file, git history) so each new session can fully reconstruct where the project stands. Designed for web development but raises broader questions about multi-session agent orchestration.

## Architecture & Design Methodology

- **Dual-agent model:** Initializer Agent (first session) + Coding Agent (subsequent sessions)
- Initializer creates: `init.sh`, `claude-progress.txt`, Feature List (JSON), initial git commit
- Coding Agent startup protocol: `pwd` -> read git log + progress file -> select highest-priority incomplete feature
- **Single-feature-per-session** discipline to prevent scope sprawl
- **External state machine:** Feature List (JSON with description/steps/passes) is the ground truth
- **Immutable tests:** "It is unacceptable to remove or edit tests" — prevents agent self-deception
- **Verification:** End-to-end browser automation via Puppeteer MCP

### Observed Failure Modes & Countermeasures

| Problem | Initializer Response | Coding Agent Response |
|---------|---------------------|-----------------------|
| Premature completion | Comprehensive feature list | Work single feature; verify thoroughly |
| Buggy undocumented state | Write git repo + progress notes | Start by testing; commit changes formally |
| Incomplete implementation | Feature list scaffolding | Test all features before marking complete |
| Environment setup confusion | Write executable init.sh | Begin by reading init.sh |

## Assumptions & Limitations

| Assumption | Type | Analysis |
|------------|------|----------|
| Features can be completed independently in sequence | Restrictive | Research experiments have strong dependency chains (baseline before ablation) |
| JSON feature list captures all task state | Restrictive | Research tasks are hard to pre-define; experiments generate new directions |
| Two agent roles suffice | Standard | Adequate for web dev; research may need analysis, writing, literature roles |
| Git commits provide sufficient rollback | Standard | Widely validated assumption |
| Browser automation verifies correctness | Restrictive | Only for web apps; research needs metric-based verification |
| Progress file as plain text | Standard | Simple and effective but lacks structured query capability |
| Tests are immutable | Restrictive | In research, evaluation criteria themselves may need iteration |

### Open Questions (acknowledged by authors)

- Multi-agent parallel vs single-agent sequential trade-offs
- Generalization beyond web development
- Progress file conflict handling (concurrent agents)
- Feature list evolution under changing requirements

## Bridge Analysis (vs LabMate)

**Complementary positioning:** This paper provides the foundational pattern that LabMate extends into the research domain.

| Dimension | Long-Running Agents | LabMate |
|-----------|-------------------|---------|
| Domain | Web development | Research experimentation |
| Agent count | 2 (Initializer + Coding) | 5 specialized agents |
| State externalization | Feature List (JSON) + progress.txt | exp/summary.md + landscape.md + agent memory |
| Session startup | 4-step protocol (pwd, git, progress, select) | session-start hook (context injection) |
| Verification | Browser automation (pass/fail) | Metric-based + statistical significance |
| Knowledge accumulation | progress.txt only | docs/papers/ + landscape.md + cross-session memory |
| Task discovery | Pre-defined feature list | Hook-guided exploration + dynamic experiment design |

### Borrowable Ideas

1. **Session startup protocol** — formalize the "read state -> select task -> execute -> write state" loop more explicitly in LabMate's session-start hook
2. **Immutable test principle** — mirrors LabMate's "baseline is sacred" rule; validates the design choice
3. **Feature List as external state machine** — LabMate's exp/summary.md serves the same role in Markdown form
4. **Failure mode taxonomy** — the 4-failure-mode table is a useful template for documenting agent failure patterns in research contexts

### Not Directly Applicable

- Browser-based verification assumes deterministic web UI outcomes; research results are probabilistic
- Pre-defined feature lists assume known scope; research is fundamentally exploratory
- Two-agent architecture is too coarse for research lifecycle (need domain expertise, literature awareness, visualization)
- "Single feature per session" may be too conservative for quick parameter sweeps or ablation studies
