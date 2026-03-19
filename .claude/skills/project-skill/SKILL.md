---
name: project-skill
description: "Use when advising on project architecture, experiment history, codebase navigation, or research findings. Auto-maintained by /update-project-skill."
user-invocable: false
---

# LabMate — Project Knowledge

> Last updated: 2026-03-19

## Project Overview & Current State

LabMate (formerly cc-native-research-template) is a Claude Code Plugin for research project lifecycle. Renamed on 2026-03-19.

- **Repo:** https://github.com/freemty/labmate
- **Tagline:** Research Harness for Claude Code. Keep your agent grounded in context, not lost in vibe coding.
- **Version:** 0.4.0
- **License:** MIT
- **Stage:** Post-rename stabilization, preparing for marketplace publish

## Architecture

```
labmate/
├── .claude-plugin/plugin.json    # Manifest (name, agents, skills, hooks)
├── agents/ (7)                   # CC auto-loads
├── skills/ (7)                   # CC auto-loads (namespace: labmate:)
├── hooks/                        # hooks.json + 7 scripts
│   ├── hooks.json                # SessionStart + PreCompact + Stop + PostToolUse(x2) + PreToolUse(x2)
│   ├── run-hook.cmd              # Cross-platform wrapper
│   ├── session-start             # Context injection based on .pipeline-state.json
│   └── post-analyze-remind.sh    # Remind /analyze-experiment after analysis scripts
├── references/                   # Used by init-project (not auto-loaded)
│   ├── claude-md-template.md     # 9 sections with placeholders
│   ├── project-skill-template.md
│   ├── gitignore-rules.md
│   └── scripts + viewer files
├── docs/
│   ├── tutorial.md               # First experiment walkthrough
│   ├── specs/                    # Design specs
│   └── papers/                   # Literature (instance data, dev only)
```

## System Cognition

Core understanding validated through development:

- **Plugin > Template**: `claude plugin install` is the right distribution model — templates require manual sync, plugins auto-update
- **Agent override pattern works**: project `.claude/agents/x.md` overrides plugin (priority 2 > 4) — confirmed functional
- **Skill namespace isolation**: plugin skills always prefixed `/labmate:skill-name` — no override possible, only coexistence with local `/skill-name`
- **rules/ is a dead end for plugins**: upstream CC limitation, will not be supported — use CLAUDE.md injection via init-project instead
- **SessionStart hook is the right injection point**: auto-detect init state + context injection on every new session
- **Pipeline state machine is valuable**: `.pipeline-state.json` stage tracking guides agent behavior contextually

Active assumptions (unvalidated):
- Marketplace distribution will become available for third-party plugins
- 5-segment retrospective structure will improve agent research quality (testing with this project)

## Technical Archive

| Decision | Choice | Rejected Alternative | Rationale |
|----------|--------|---------------------|-----------|
| Distribution | CC Plugin | GitHub Template | Auto-update, no manual sync |
| Hook scripts | Extensionless + run-hook.cmd | .sh suffix | Windows compat |
| Skill namespace | Accept `/labmate:` prefix | Override local skills | CC limitation, not worth fighting |
| Context injection | SessionStart hook | CLAUDE.md static | Dynamic, state-aware |
| Agent models | opus for deep reasoning, sonnet for workflow | All same model | Cost/capability tradeoff |

## Experiment History Table

| Exp | Description | Status | Prediction | Actual | Key Finding |
|-----|-------------|--------|------------|--------|-------------|
| (no experiments yet — this is a plugin project, not a research target) | | | | | |

## Prediction Calibration

No predictions tracked yet. This section will accumulate meta-learning data when LabMate is used in research projects.

Tracking format: prediction accuracy %, systematic bias direction, calibration notes.

## Engineering Lessons (APPEND-ONLY)

1. `cp -r dir/ target/dir/` creates nested `target/dir/dir/` — always verify after bulk copy
2. CC plugins cannot distribute rules/ — upstream limitation
3. Plugin skills always namespaced `/plugin:skill` — no way around it
4. Agent override works; skill override uses namespace isolation instead
5. SessionStart matcher: use `""` for non-tool events
6. Hook scripts must be extensionless for Windows compat
7. `git rm` on main needs `--cached` + manual rm for working dir cleanup
8. `plugin.json` agents must list individual files, skills can use directory path
9. `${CLAUDE_PLUGIN_ROOT}` for hook paths, `${CLAUDE_PLUGIN_DATA}` for persistent data

## Active Prompt Versions & Trade-offs

N/A — LabMate is infrastructure, not a prompt-driven research project.

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/labmate:init-project` | Init research skeleton in target project |
| `/labmate:new-experiment` | Scaffold new experiment |
| `/labmate:analyze-experiment` | Analyze results |
| `/labmate:update-project-skill` | Refresh project knowledge |
| `claude --plugin-dir .` | Test plugin locally |

## Literature Landscape

12+ entries in docs/papers/landscape.md:
- trq212 trilogy: Prompt Caching → Tool Design → Skills Design
- HiTw93: CC 六层架构 + MCP 预算量化
- OpenAI Harness Engineering, Anthropic Evals + Long-Running Agents
- Manus Context Engineering, learn-claude-code, superpowers growth
- 2 zhihu: multi-CC parallel + AReaL vibe coding
