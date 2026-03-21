# Literature Landscape

> Living literature map — maintained by @domain-expert agent.
> Each paper has detailed notes in `docs/papers/{short-name}.md`.

## Agent Harness & Workflow Engineering

| Source | Date | Key Contribution | Relevance to Template | Notes |
|--------|------|------------------|-----------------------|-------|
| [Lessons from Building Claude Code: How We Use Skills](https://x.com/trq212/article/2033772621536591872) — @trq212 (Anthropic) | 2026-03 | Skills 9 大分类 + 文件夹化设计 + Gotchas 最高信号密度 | Skills 架构直接参考 | [notes](skills-design-trq212.md) |
| [10 Tips for Using Claude Code](https://x.com/bcherny/status/2017742741636321619) — @bcherny (Claude Code 创始人) | 2026-01 | 并行 worktrees、Plan Mode、CLAUDE.md 迭代、Subagents | 工作流最佳实践 | [notes](cc-tips-bcherny.md) |
| [你不知道的 Claude Code](https://x.com/HiTw93/article/2032079318256664586) — @HiTw93 | 2026-03 | 六层架构模型、上下文预算量化、HANDOFF.md 模式 | 上下文治理 + session 交接 | [notes](cc-architecture-tw93.md) |
| [Harness Engineering: Leveraging Codex](https://openai.com/index/harness-engineering/) — OpenAI (Ryan Lopopolo) | 2026-02 | Agent-first 开发、progressive disclosure 文档、linter 编码架构约束 | 对比 OpenAI vs Anthropic 方法论 | [notes](harness-eng-openai.md) |
| [Demystifying Evals for AI Agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) — Anthropic | 2026-01 | pass@k vs pass^k、三类 Grader、Eval-Driven Development | 实验评估框架设计 | [notes](evals-anthropic.md) |
| [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — Anthropic | 2025-11 | Initializer/Coding Agent 分离、Feature list 外部状态机、跨 session 持久化 | 长实验 session 管理 | [notes](long-running-anthropic.md) |
| [obra/superpowers](https://github.com/obra/superpowers) — Jesse Vincent | 2025-10 | 102K star 的 agentic skills framework；7 阶段顺序工作流 + mandatory TDD + subagent 两阶段 review；composable skills 库 | Skills 框架对标 + 上游依赖 | [notes](superpowers-repo.md) |

## AI Tools & Frameworks

| Source | Date | Key Contribution | Relevance | Notes |
|--------|------|-----------------|-----------|-------|
| [gstack](gstack.md) — Garry Tan | 2026-03 | Phase-gated Sprint framework for Claude Code; 15 skills + Conductor parallelism | Complementary — gstack optimizes code output speed, LabMate optimizes research cognition | [notes](gstack.md) |
| [NotebookLM 教授工作流](notebooklm-education.md) — Ihtesham Ali | 2026-03 | Source-grounded curriculum generation; 7-step professor workflow | Architecturally isomorphic (notebook=unit vs exp/=experiment); LabMate advantage in cross-session knowledge accumulation | [notes](notebooklm-education.md) |

## Cross-Cutting Themes

1. **Skills 是首要杠杆** — 文件夹化、Gotchas 积累、mandatory 触发（trq212 + bcherny + superpowers）
2. **上下文工程 > Prompt 工程** — MCP 隐形消耗量化、分层加载策略（HiTw93 + OpenAI）
3. **外部状态 > 模型记忆** — progress file + git log + feature list + HANDOFF.md（Anthropic long-running + HiTw93）
4. **结构性约束 > 运行时监管** — linter 编码规则、feature list 防误判（OpenAI + Anthropic eval）
5. **并行化是最大乘数** — worktrees + subagents + 多 session（bcherny + superpowers）
6. **Eval-Driven Development** — 先定义 success criteria，pass@k/pass^k 区分一致性（Anthropic eval）
7. **Source-grounded generation** — 引用追溯到原始材料，防止幻觉（NotebookLM + LabMate domain-expert Hard Rules）
8. **一次摄入，多次衍生** — 同一知识源生成多种产出形式（NotebookLM 5 种 + LabMate 3 种）
