# 10 Tips for Using Claude Code — Boris Cherny (@bcherny)

> Source: https://x.com/bcherny/status/2017742741636321619
> Type: Practitioner guide (X thread by Claude Code creator)
> Date: 2026-01-31
> Stats: 9M views, 50K likes, 104K bookmarks
> Date read: 2026-03-21

## Summary

Claude Code 创始人 Boris Cherny 基于内部团队使用经验总结的 10 条最佳实践。核心主张：不要微观管理 agent 的执行方式，而是通过并行化、规划前置、知识沉淀和环境融合来最大化生产力。这是关于 Claude Code 使用方法的最高权威来源。

## Methodology Skeleton

四层生产力模型：

**第一层: 并行化 (Tip 1, 8)**
- 3-5 个 git worktrees 并行运行独立 Claude session
- Subagents 纵向扩展单 session 计算密度 + 保护主 context window

**第二层: 规划驱动 (Tip 2, 6)**
- Plan Mode 前置，投入精力在规划上让 Claude 一次通过实现
- 对抗式 prompting："Grill me"、"Prove to me this works" 将 agent 提升为审查者

**第三层: 知识沉淀 (Tip 3, 4)**
- CLAUDE.md 自我迭代：每次纠正后让 Claude 更新规则
- Skills 版本控制化，跨项目复用高频操作

**第四层: 环境融合 (Tip 5, 7, 9, 10)**
- MCP 集成消除上下文切换（Slack、BigQuery、Chrome）
- 终端优化（Ghostty + /statusline）降低 session 管理负担
- Learning output style 让 Claude 解释 why

## 10 Tips Detail

| # | Tip | Key Insight |
|---|-----|-------------|
| 1 | Parallel worktrees | 团队排名第一的生产力提升；3-5 worktrees 各跑独立 session |
| 2 | Plan Mode first | 规划质量决定一次通过率；可让第二个 Claude 以 staff engineer 角色审查计划 |
| 3 | Invest in CLAUDE.md | 每次纠正后更新；Claude 擅长为自己写规则；持续编辑精炼 |
| 4 | Custom skills in git | 日频操作 skill 化；/techdebt 命令清理重复代码 |
| 5 | Claude fixes bugs | Slack MCP + "fix"；CI 失败直接指向日志让 Claude 修 |
| 6 | Level up prompting | 对抗式："Grill me"；迭代式：mediocre 结果 -> 改 prompt 重试 |
| 7 | Terminal setup | Ghostty（同步渲染、24-bit color、unicode）；/statusline 显示 context 和 branch |
| 8 | Subagents | "use subagents" 追加到请求；任务分流保护主 context；Opus 4.5 审批 hook |
| 9 | Data & analytics | BigQuery skill 直接在 Claude Code 中做数据分析，团队零手写 SQL |
| 10 | Learning mode | /config 开启 Explanatory/Learning 输出风格；HTML 可视化讲解陌生概念 |

## Assumptions & Limitations

| Assumption | Type | Assessment |
|------------|------|------------|
| 3-5 并行 worktrees 可有效管理 | Restrictive | 功能级隔离成立，但研究实验间有数据/模型依赖，隔离度更低 |
| Plan Mode 能让 Claude 一次通过 | Standard | 业界共识：规划质量正相关于执行质量 |
| CLAUDE.md 自我编写有效 | Standard | 模型对自身错误模式有元认知能力 |
| MCP 集成无显著上下文开销 | Restrictive | 与 HiTw93 发现矛盾——MCP 工具描述隐性消耗 context |
| "Just say fix" 修复大多数 bug | Restrictive | 简单 bug 成立，架构级问题需人类判断 |

**Key blind spots:**
- 没有讨论失败案例（何时 tips 不起作用）
- 没有量化指标（"最大生产力解锁"缺乏度量）
- 团队偏向产品开发，研究场景适用性需验证
- 没有涉及 context window 管理策略

## Bridge Analysis (vs LabMate)

### Borrowable Ideas

| Tip | LabMate Component | Action |
|-----|-------------------|--------|
| Tip 1 并行 worktrees | hooks/worktree-suggest | 强化为实验级并行模板 |
| Tip 2 Plan Mode | analyze-experiment | 分析前先规划分析维度 |
| Tip 3 CLAUDE.md 迭代 | agent memory system | 已实现；可增加"修正后自动更新 memory" |
| Tip 4 Skills 复用 | skills/ directory | 核心架构已完全对齐 |
| Tip 6 对抗式 prompting | domain-expert Mode 2 | 实验分析加入 self-challenge 步骤 |
| Tip 8 Subagents | 5-agent dispatch | LabMate agent dispatch 本质是 subagent 模式 |
| Tip 9 数据分析 CLI | exp-manager | 可扩展支持直接查询实验日志/数据 |

### Differences to Be Careful About

1. **并行粒度** — bcherny 的并行是功能级（独立 feature），LabMate 是实验级（共享数据集/检查点），隔离度更低
2. **"Just say fix" 不适用于研究** — 实验失败往往是假设错误，需要分析而非修复
3. **数据源差异** — BigQuery skill 模式可借鉴，但研究用 tensorboard/wandb/CSV
4. **Chrome MCP** — 对验证 viz-frontend 生成的 dashboard 有价值

### Where LabMate Already Exceeds

- 知识持久化：docs/papers/ + landscape.md vs 仅 CLAUDE.md
- 结构化实验管理：exp/ 目录 vs 无对应概念
- Hook 引导式工作流：零记忆负担 vs 需要记住 tips
- 多模态产出：分析报告 + slides + dashboard vs 代码为主

## Notable Community Signals

- Chrome MCP 被评论区高度认可 -> 验证可视化场景
- Lefthook (git hooks) + feature dev slash commands 被推荐 -> 与 LabMate hooks 设计方向一致
- 大型 codebase 代码重复问题 -> bcherny 建议：计划阶段探索可复用函数 + CI 中用 `claude -p` 做 review
