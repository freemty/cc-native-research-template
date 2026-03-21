# Demystifying Evals for AI Agents

> Source: https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
> Author: Anthropic Engineering
> Type: Engineering blog post (not peer-reviewed)
> Date read: 2026-03-21
> Tags: agent evaluation, grading, pass@k, eval harness, regression testing, capability testing

## Summary

Anthropic 工程团队提出的 AI Agent 评估方法论。定义了一套评估原语（Task, Trial, Grader, Transcript, Outcome），将 Grader 分为三类（Code-based, Model-based, Human），区分 Capability eval 与 Regression eval，并为四种 Agent 类型（Coding, Conversational, Research, Computer-use）提供针对性评估策略。引入 pass@k（k 次中至少一次成功）和 pass^k（k 次全部成功）两个度量维度区分能力上限与一致性。实施建议从 20-50 个真实失败 case 起步迭代。

## Architecture & Design Methodology

### Evaluation Primitives

```
Task: 单个测试 — 定义 input + success criteria
Trial: 对 Task 的一次尝试 — 多次 trial 产生稳定信号
Grader: 评分逻辑 — 一个 task 可有多个 grader
Transcript: 完整记录 — 输出、工具调用、推理、中间结果
Outcome: 最终环境状态
Evaluation harness: 端到端运行 eval 的基础设施
Agent harness/scaffold: 使模型成为 agent 的系统
```

### Grader Taxonomy (核心贡献)

| Grader 类型 | 优势 | 劣势 | 适用场景 |
|-------------|------|------|----------|
| Code-based | 快速、客观、可复现 | 难处理合理变体 | 确定性输出（测试通过、状态验证） |
| Model-based | 处理 nuance、灵活 | 需要校准、引入二阶不确定性 | 交互质量、文本评估 |
| Human | 金标准 | 昂贵、慢、不可扩展 | 校准 model-based grader、edge cases |

### Agent-Type Specific Strategy

- **Coding agents**: 确定性测试验证 outcome + transcript 质量评估
- **Conversational agents**: 状态验证 + 交互质量 rubric
- **Research agents**: groundedness 检查 + 覆盖率验证 + 来源质量评估
- **Computer-use agents**: 环境状态检查验证 GUI 交互

### Metrics

- **pass@k**: P(k 次 trial 中 >= 1 次成功) — 衡量能力上限
- **pass^k**: P(k 次 trial 全部成功) — 衡量一致性/可靠性
- 两者差异大 = agent 有能力但不稳定

### Implementation Roadmap

```
1. 从手动检查转为测试 case（20-50 个真实失败起步）
2. 编写无歧义 task + reference solution
3. 构建平衡问题集（难度/类型分布）
4. 设计 robust harness（隔离 trial 环境）
5. 通过 transcript review 迭代 grader
```

## Claims & Evidence

| Claim | Assessment |
|-------|-----------|
| Agent eval 比单轮 eval 本质更复杂 | Strong — 工具调用、状态修改、多轮适应确实增加复杂度 |
| Grader 三分法覆盖所有场景 | Reasonable — 但混合 grader（如 code + model 联合评分）未充分讨论 |
| 20-50 个 task 足以起步 | Pragmatic — 避免 cold-start 瘫痪，但覆盖率保证弱 |
| pass@k vs pass^k 充分刻画 agent 质量 | Partial — 忽略效率（token 消耗）、安全性、用户体验维度 |
| Eval-Driven Development 可行 | Plausible — 类似 TDD，但 eval 维护成本未量化 |

## Assumptions & Limitations

### Explicit Assumptions

1. **Task 可明确定义为 input + success criteria** — 标准假设，对 coding agent 成立，对开放式任务困难
2. **环境可隔离和重置（沙盒化）** — 标准假设，长期 session 的隔离成本高
3. **多次 trial 产生一致信号** — 标准假设，前提是 agent 随机性可管理

### Implicit Assumptions (Restrictive)

4. **Grader 本身可靠** — Model-based grader 引入"用 AI 评估 AI"的循环问题
5. **Transcript 包含足够信息** — Agent 内部推理链可能不完全显现
6. **pass rate 是核心度量** — 未讨论效率、成本、安全性等同等重要的维度

### Missing Discussion

- Eval 维护成本：随 agent 演进如何保持 eval suite 同步
- 跨 agent/scaffold 可比性
- Eval 过拟合风险：agent 对特定 eval 格式过拟合
- 成本度量：每个 trial 的 token/时间/金钱消耗

## Bridge Analysis (vs LabMate)

### Terminology Mapping

| Anthropic Eval 概念 | LabMate 对应 |
|---------------------|-------------|
| Task | `exp/{id}/` 目录 |
| Trial | 单次实验运行 |
| Grader (code-based) | Hook 系统自动化检查 |
| Grader (model-based) | domain-expert Mode 2 分析 |
| Grader (human) | 用户最终判断 |
| Transcript | 实验日志 + 代码 diff |
| Evaluation harness | `/analyze-experiment` + `exp/summary.md` |
| pass@k / pass^k | `exp/summary.md` 的 check/cross/warning 可扩展 |

### Borrowable Ideas

1. **pass@k vs pass^k 维度扩展**: `exp/summary.md` 可区分"曾成功"与"稳定成功"两个维度
2. **Regression eval 积累**: 每次实验失败自动生成 regression case，积累 eval suite
3. **Grader 三层对应**: hook = code-based, domain-expert = model-based, user = human — 三层验证
4. **Research agent eval 策略**: groundedness + coverage + source quality 可直接用于评估 domain-expert Mode 5 survey 质量

### Differences to Be Careful About

1. **研究实验 vs Agent 行为评估**: 本文评估 agent 输出质量（有"正确答案"），LabMate 评估科学实验结果（往往没有正确答案）
2. **隔离性假设冲突**: Agent eval 要求 trial 间完全隔离；研究实验恰恰需要跨实验知识积累（landscape.md 核心价值）
3. **Transcript 分析局限**: 研究实验的"过程记录"是实验日志和代码，不是 agent 对话记录
