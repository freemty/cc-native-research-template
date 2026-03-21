# 你不知道的 Claude Code — Deep Dive

- **Author:** @HiTw93 (Tw93)
- **Date:** 2026-03
- **Link:** https://x.com/HiTw93/article/2032079318256664586
- **Tags:** Claude Code, agent architecture, context engineering, session handoff, MCP
- **Read date:** 2026-03-21
- **Source status:** Original ~7000-word article deleted/rewritten by author. This note is reconstructed from landscape.md summary, author's TLDR tweet (2035114867611578797), and `tw93/claude-health` tool context. Verified content is marked [verified]; reconstructed content is marked [reconstructed].

## Summary

Tw93's article was one of the most influential Chinese-language deep-dives on Claude Code's internal architecture. The author decomposed Claude Code into a six-layer architecture model, quantified hidden context consumption from MCP tools, and documented the HANDOFF.md pattern for session handoff. The article was later distilled into a practical tool: `npx skills add tw93/claude-health` (run `/health`).

Core thesis [verified]: "Agent 核心是感知-决策-行动-反馈的稳定循环，控制流基本不变，新能力主要通过工具扩展、提示结构调整和状态外化实现。"

## Methodology Skeleton

### Six-Layer Architecture Model [reconstructed]

The author decomposed Claude Code's runtime into six layers. Exact definitions are lost with the original article, but cross-referencing `claude-health` functionality and the TLDR thread, the layers likely cover:

1. **System Prompt Layer** -- CLAUDE.md, rules files, project instructions
2. **Tool Definition Layer** -- MCP tool schemas, built-in tool declarations (major hidden consumer)
3. **Session State Layer** -- conversation history, tool call results accumulation
4. **Agent Orchestration Layer** -- subagent dispatch, skill triggers, hook execution
5. **External State Layer** -- file system, git, HANDOFF.md, persistent memory
6. **User Interaction Layer** -- input parsing, output presentation

### Core Insight: Three Axes of Evolution [verified]

Agent evolution does not change the core loop (perceive-decide-act-feedback). Instead, capabilities expand along three orthogonal axes:

- **Tools** -- new abilities via MCP tools and built-in tools
- **Prompt structure** -- cognitive scaffolding via CLAUDE.md, skills, rules
- **State externalization** -- memory via files, git, HANDOFF.md

### HANDOFF.md Pattern [verified]

When context window approaches exhaustion, the agent writes current task state, incomplete work, and key decisions to `HANDOFF.md`. The next session reads this file to resume. This is a practical implementation of "external state > model memory."

### Context Budget Quantification [verified concept, details reconstructed]

MCP tool definitions silently consume context tokens -- each tool's JSON schema is injected into the system prompt. With 10+ MCP tools, thousands of tokens may be consumed before the user even types. The `claude-health` tool (`/health` command) materializes this insight, allowing users to audit their context budget in real time.

### Layered Loading Strategy [verified concept]

Rather than loading all context at once, load in tiers based on relevance. Core context first, detailed information on demand. This aligns with LabMate's session-start hook design.

## Assumptions & Limitations

| Assumption | Type | Assessment |
|------------|------|------------|
| Agent core loop is stable and unchanging | **Standard** | Widely accepted in current agent frameworks |
| Tool extension is the primary evolution axis | **Standard** | Consistent with Anthropic's official engineering docs |
| Context window is a hard constraint | **Standard** | True even in 1M context era (quality degrades with length) |
| MCP tool definition consumption is quantifiable | **Verifiable** | `claude-health` is empirical evidence |
| Six-layer decomposition is complete | **Restrictive** | Original text deleted; may omit security, caching, or other layers |
| HANDOFF.md effectively transfers session state | **Restrictive** | Assumes agent can accurately self-assess progress; implicit context may be lost |

## Bridge Analysis (vs LabMate)

### Position in Literature Map

This article sits in the "Agent Harness & Workflow Engineering" cluster in landscape.md, forming a knowledge quartet with:

- **trq212 (Skills):** Tw93 explains *why* tools are leverage; trq212 explains *how* to organize them
- **Anthropic long-running:** HANDOFF.md and Anthropic's "Initializer/Coding Agent separation" + "Feature list state machine" are different implementations of the same design philosophy
- **OpenAI harness-eng:** Context budget quantification and OpenAI's "progressive disclosure docs" both address context as scarce engineering resource

### Borrowable Points

1. **`/health` check pattern** -- LabMate could add context health monitoring, especially when domain-expert processes long papers
2. **HANDOFF.md auto-generation** -- LabMate's pre-compact-remind hook could be enhanced to auto-write a HANDOFF summary
3. **MCP tool consumption audit** -- `/init-project` could report number of installed MCP tools and estimated token cost
4. **Three-axis framework** -- useful mental model for LabMate's own evolution: which axis (tools, prompts, state) gives highest ROI for next feature?

### Differences to Be Careful About

- `claude-health` is a general-purpose tool; LabMate is domain-specialized -- generic health checks may miss research-specific context issues (e.g., paper notes bloat, experiment history growth)
- The six-layer model is a static decomposition; LabMate's usage spans dynamic experiment lifecycles across multiple sessions
- HANDOFF.md handles single-session continuity; LabMate needs cross-session *knowledge accumulation* (landscape.md, exp/summary.md), which is a harder problem

## Key Numbers / Baselines

- Original article: ~7000 words (author's own count) [verified]
- Community reception: 6000+ likes across Asian developer community [verified, author's claim]
- Practical distillation: `npx skills add tw93/claude-health` [verified]

## Open Questions

1. What were the exact six layers in the original article? Does `claude-health` source code preserve the full taxonomy?
2. Concrete numbers for context budget: how many tokens does an average MCP tool schema consume?
3. What is the information fidelity of HANDOFF.md in practice? Any user feedback data?
4. Why did the author delete/rewrite the original? Is there a revised version?

## Cross-Cutting Themes (from landscape.md)

This article directly contributes to three of the eight cross-cutting themes identified in our literature map:

- **Theme 2: 上下文工程 > Prompt 工程** -- MCP hidden consumption quantification, layered loading
- **Theme 3: 外部状态 > 模型记忆** -- HANDOFF.md pattern
- **Theme 5: 并行化是最大乘数** -- implicit in the three-axis evolution model (tool parallelism)
