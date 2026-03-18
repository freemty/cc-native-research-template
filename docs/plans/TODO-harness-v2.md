# Harness v2 — 借鉴 research_harness_bootstrap_prompt 的改进计划

> Source: `research_harness_bootstrap_prompt.md` (认知闭环驱动的 research harness)
> Status: TODO — 下一轮迭代

## 参考文件核心理念

Agent 不只是被动执行，而是主动维护实验闭环：**预测 → 执行 → 记录 → 更新认知 → 产生新搜索种子**

### 参考 harness 的 6 条搜索原则

1. **Measure first** — 优先攻击实测最大瓶颈，不凭直觉猜
2. **统计显著性** — 单次结果不下结论，关注置信区间和方差
3. **Baseline 神圣不可侵犯** — 每个 claim 必须有可复现的 baseline 对比
4. **低风险高回报优先** — 参数调优 > 轻量修改 > 重写核心模块
5. **尊重负面结论** — retrospective 中标记 ❌ 的方向不重复尝试，除非有新证据
6. **Ablation 驱动** — 多因素改动必须逐一 ablation，不接受打包对比

### 参考 harness 的结构化记忆

```
research/memory/
├── current_progress.md    # 待研究方向 + 当前最优结果 + 实验索引
└── retrospective.md       # 系统认知 + 技术档案 + 搜索种子 + 预测校准 + 工程经验
```

### 参考 harness 的 /report skill

实验后自动执行 4 步：补完报告 → 更新记分板 → 更新经验进化库 → 生成新候选方向

### 参考 harness 的 /paper skill

从实验记录生成 paper 素材：主实验表(LaTeX) + ablation 表 + 关键发现 + 负面结果

---

## 当前模板 vs 参考 harness 差距分析

| 维度 | 当前模板 | 参考 harness | 差距 |
|------|---------|-------------|------|
| 核心循环 | dev → experiment → analyze → commit | 预测 → 执行 → 记录 → 更新认知 → 新种子 | 缺预测校准 |
| 搜索原则 | 无 | 6 条硬规则 | 完全缺失 |
| 经验进化库 | project-skill (笼统) | 5 段式 retrospective | 结构不够精细 |
| 预测校准 | 无 | 每次实验前记录预测，实验后对比 | 完全缺失 |
| 自动触发 | 手动 /analyze-experiment | /report 实验后自动执行 | 可加 hook 提醒 |
| Paper 素材 | 无 | /paper 生成 LaTeX | 完全缺失 |
| Session 启动 | CLAUDE.md route hub | 明确 "先读什么" 表格 | 不够明确 |
| 负面结果 | pitfalls (append-only) | ❌ 标记 + 不重复尝试规则 | 结构化不足 |

---

## 改进 TODO（按优先级）

### HIGH — 下一轮迭代

- [ ] **CLAUDE.md 加搜索原则** — 6 条规则写入 CLAUDE.md 的 Conventions 区域
- [ ] **实验 README.md 模板加预测部分** — `/new-experiment` 脚手架加 "## 预测（含预期数值范围）" + "## 预测 vs 实际"
- [ ] **project-skill 结构精细化** — `/update-project-skill` 生成的 SKILL.md 拆分为：系统认知、技术档案、预测校准、工程经验（参考 retrospective.md 五段式）

### MEDIUM — 后续迭代

- [ ] **`/paper` skill** — 从 exp/ 和 project-skill 生成 LaTeX 表格（main_table.tex, ablation_table.tex, key_findings.md, negative_results.md）
- [ ] **Session 启动指南** — CLAUDE.md 加 "新 session 先读什么" 表格
- [ ] **实验后自动提醒** — PostToolUse hook 检测 analyze.py 完成 → 提醒 `/analyze-experiment`
- [ ] **负面结果结构化** — exp/summary.md 的 ❌ 实验加 "不重复尝试规则" 标记

### LOW — 可选

- [ ] **预测校准 meta-learning** — project-skill 加 "系统性偏差识别" section
- [ ] **搜索种子管理** — 从 retrospective 分离出独立的 "远期方向" 文件

---

## 参考文件原文

> 以下为 `research_harness_bootstrap_prompt.md` 的完整内容，供后续实现参考。

核心理念：让 Agent 不只是被动执行命令，而是主动维护实验闭环。

关键 skill 设计：
- `/report` — 实验后 4 步流程（补完报告 → 记分板 → 经验进化 → 新方向）
- `/paper` — 从实验记录生成 paper 素材（LaTeX 表格 + 关键发现 + 负面结果）

关键记忆文件：
- `current_progress.md` — 待研究方向表 + 最优结果 + baseline + 实验索引
- `retrospective.md` — 系统认知 + 技术档案 + 搜索种子 + 预测校准 + 工程经验

关键规则：
- 实验前必须写预测（含数值范围）
- 实验后自动执行 /report（不需要人类提醒）
- 负面结论标 ❌，不重复尝试（除非有新证据）
- 预测校准积累 meta-learning 数据
