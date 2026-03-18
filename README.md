# cc-native-research-template

> 在 agent 的时代，不断思考：任何 project 能不能通过 agent 实现更 meta 一级的迭代？
>
> In the age of agents, keep asking: can this project go one meta-level higher with agents?

## Why / 为什么

我们做了三个 agent 驱动的研究项目（fars-reviewer、PostTrainBench、hle-solver），发现每次都在重新搭同一套东西：实验目录怎么组织、prompt 怎么版本管理、论文怎么追踪、结果怎么分析、slides 怎么出、context 满了知识怎么不丢。

这些项目的研究内容完全不同，但脚手架高度重复。所以我们把共性抽出来做成了这个模板。

We built three agent-driven research projects and kept rebuilding the same scaffolding: experiment folders, prompt versioning, paper tracking, result analysis, slides generation, knowledge persistence across context windows. The research content differs; the infrastructure doesn't. So we extracted it.

## What / 是什么

一个 GitHub template repo，给 Claude Code 研究项目提供完整的 harness：

- 7 个 agent（4 个只读顾问 + 2 个限定目录写入 + 1 个后台生成 slides）
- 7 个 skill（实验脚手架、分析流水线、知识更新、slides、周报、commit）
- 5 个 hook（提醒为主，不硬拦）
- 实验基础设施（标准命名、共享分析库、跨实验记录）
- 自动维护的项目知识（context compact 前提醒更新）

模板给你基础设施，不给你研究内容。

## Agents

| Agent | Model | 做什么 |
|-------|-------|--------|
| project-advisor | opus | 实验历史、研究发现、代码导航 |
| cc-advisor | sonnet | Claude Code 工作流最佳实践 |
| domain-expert | opus | 读论文、解释实验结果、维护文献地图 |
| slides-maker | sonnet | 后台生成 HTML slides（分析或演示） |
| exp-manager | sonnet | 监控实验、诊断失败、重试 |
| viz-frontend | sonnet | Flask + HTML 分析仪表盘 |
| template-presenter | sonnet | 模板概览 slides、架构文档、onboarding |

## Skills

| Skill | 什么时候用 | 做什么 |
|-------|-----------|--------|
| `/new-experiment` | 开始新实验 | 生成 `exp/{id}/` 目录 |
| `/analyze-experiment` | 实验跑完 | 分析 → @domain-expert 解读 → @slides-maker 出 slides |
| `/update-project-skill` | 知识过期（>24h） | Opus 扫描项目 → 重写 SKILL.md |
| `/present-template` | 要做概览 slides | @template-presenter → @slides-maker |
| `/weekly-progress` | 周五提醒 | CHANGELOG + git log → `docs/weekly/` |
| `/commit-changelog` | 要提交了 | 标准化 commit + CHANGELOG |

## Quick Start / 快速开始

**1.** 在 GitHub 点 "Use this template" 创建你的 repo

**2.** Bootstrap — 回答 4 个问题（项目名、描述、领域、计算环境）

```bash
cd your-new-repo
bash bootstrap.sh
```

**3.** 创建第一个实验

```
/new-experiment
```

**4.** 跑实验 → 分析 → 更新知识

```
python exp/exp01a/run.py --config exp/exp01a/config.yaml
/analyze-experiment
/update-project-skill
```

完整循环：`dev` → `/new-experiment` → 跑 → `/analyze-experiment` → commit → `/update-project-skill` → 下一轮。

## Architecture / 架构

```
your-project/
├── CLAUDE.md                     # 路由入口（<80 行）
├── .claude/
│   ├── agents/                   # 7 个 agent 定义
│   ├── skills/                   # 7 个 skill
│   ├── hooks/                    # 5 个 hook 脚本
│   └── settings.local.json      # 权限 + hook 配置
├── exp/                          # 实验目录（exp{NN}{x} 命名）
│   ├── lib/                      # 共享分析工具
│   └── summary.md                # 跨实验记录
├── docs/papers/                  # 论文 + landscape.md
├── prompts/                      # 版本化 prompt（_v{NN}.md）
├── scripts/                      # 启动、监控、下载
├── slides/                       # 生成的演示文稿
│   └── references/               # 视觉规范
├── viewer/                       # Flask 分析仪表盘
├── bootstrap.sh                  # 初始化
└── .pipeline-state.json          # 工作流状态机
```

设计原则：agent 最小权限（4/7 只读）；hook 只提醒不拦截；重型输出丢给后台 agent；所有知识进 repo 不留在聊天记录里；先为 agent 可读性优化，再考虑人类审美。

## Research Principles / 搜索原则

1. 先测量再动手，别凭直觉
2. Baseline 不可动摇，每个结论都要有对照
3. 单次实验是轶事不是结论，看方差
4. 多因素改动必须逐个 ablation
5. 负面结论标 ❌，不重复尝试除非有新证据
6. 实验前先写预测数值，跑完对照校准

## Applying to Existing Repos / 迁移已有项目

已经有研究 repo 了？不用从头来。

```bash
# 复制基础设施
cp -r template/.claude/ your-repo/.claude/
cp template/bootstrap.sh your-repo/
cp -r template/slides/references/ your-repo/slides/references/

# 初始化
cd your-repo && bash bootstrap.sh

# 首次知识扫描（会深度扫描现有代码和实验）
/update-project-skill
```

## 这个模板的第一个用户

[PostTrainBench](https://github.com/freemty/PostTrainBench) — 一个迭代 auto post-training 的 agent。它跑实验、分析结果、读论文、更新自己的知识库、决定下一步试什么。

这就是我们说的 scalable 自我觉察：agent 不只是执行你给的任务，它还维护着让自己随时间变聪明的那套基础设施。

## References / 参考

- [OpenAI — Harness Engineering](https://openai.com/zh-Hans-CN/index/harness-engineering/)
- [Anthropic — Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Anthropic — Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Manus — Context Engineering](https://manus.im/blog/Context-Engineering-for-AI-Agents)
- [AReaL / Starcat](https://zhuanlan.zhihu.com/p/2003269671630165191)
- [Superpowers](https://github.com/obra/superpowers)

## License

MIT
