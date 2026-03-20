# LabMate

![version](https://img.shields.io/badge/version-0.4.3-blue)
![license](https://img.shields.io/badge/license-MIT-green)
![agents](https://img.shields.io/badge/agents-7-orange)
![skills](https://img.shields.io/badge/skills-7-orange)
<!-- TODO: 30s demo GIF — record with VHS or asciinema -->

Claude Code 的研究工作台。让你的 agent 扎根在实验上下文里，别在 vibe coding 里迷路。

[English](README.md)

## 问题

你用 Claude 开始一个研究项目。三小时后你在 debug 一个 CUDA kernel，完全忘了自己在验证什么假设。

你的 agent 也好不到哪去——不知道你上周试过什么，看不了你的参考论文，每次开会话都像第一天上班。

LabMate 两边都管。agent 这边：持久化的实验上下文、领域论文知识、7 个各司其职的专用 agent。你这边：一套研究生命周期，假设、baseline、发现始终在视野里，写代码的时候不会忘了自己其实在做研究。

## 安装

```bash
# 添加 marketplace
/plugin marketplace add freemty/labmate-marketplace

# 安装（user scope，所有项目通用）
/plugin install labmate@labmate-marketplace
```

## 快速开始

1. 在你的项目里跑 `/labmate:init-project`
2. LabMate 自动检测项目名、描述、领域——确认就行
3. 骨架建好，开始研究

完整教程见 [Tutorial: your first experiment](docs/tutorial.md)（英文）。

## 里面有什么

7 个 agent，各管一块：

- `@domain-expert` 读论文、解读结果、把发现和文献连起来
- `@project-advisor` 记得你的实验历史，引导下一步
- `@exp-manager` 监控跑着的实验，诊断失败，检测完成
- `@slides-maker` 把分析变成可演示的 HTML 幻灯片
- 另外还有 `@cc-advisor`、`@viz-frontend`、`@template-presenter`

7 个 skill（plugin skill 带 `labmate:` 前缀）：

- `/labmate:new-experiment` 搭建实验骨架（config、README、运行脚本、分析脚本）
- `/labmate:analyze-experiment` 领域解读 + 跨实验对比 + 幻灯片
- `/labmate:update-project-skill` 把发现压缩进持久化的项目记忆
- 另外还有 `/labmate:init-project`、`/labmate:present-template`、`/labmate:weekly-progress`、`/labmate:commit-changelog`

6 个 hook，后台自动运行：

- SessionStart 检测项目状态，注入当前实验上下文
- PreCompact 在上下文压缩前提醒保存进度
- Stop 在会话结束时检查工作流状态

## 工作流

```
/labmate:init-project → /labmate:new-experiment → 跑实验 → /labmate:analyze-experiment
  → 提交发现 → /labmate:update-project-skill → 重复
```

Pipeline 状态记在 `.pipeline-state.json` 里。下次开 session，agent 从断点继续。

## 横向对比

| 功能 | labmate | [K-Dense](https://github.com/K-Dense-AI/claude-scientific-skills) | [Orchestra](https://github.com/Orchestra-Research/AI-Research-SKILLs) | [ARIS](https://github.com/conglu1997/ARIS) |
|------|---------|---------|-----------|------|
| 论文深度阅读 | Yes | No | No | No |
| 实验设计 | Yes | No | Partial | No |
| 研究记忆/上下文 | Yes | No | No | No |
| ML 实验追踪 | Yes | No | Yes | Yes |
| 论文写作 pipeline | Partial | No | Partial | Partial |
| 跨学科支持 | Yes | 生物/化学 | 仅 ML/AI | 仅 ML |

## 定制

在项目本地创建同名文件就能覆盖 plugin 默认：

```bash
# 例：给 domain-expert 换成你自己领域的版本
mkdir -p .claude/agents
# 写你的 .claude/agents/domain-expert.md
# 项目本地版本自动覆盖 plugin 版本
```

Agent、skill、hook 都能覆盖。

## 路线图

下一步：Auto Research Agent 模式——让 agent 自主跑完从假设到分析的完整循环。

## 致谢

- [superpowers](https://github.com/obra/superpowers) — skills 框架、subagent-driven development、SessionStart hook 模式
- [frontend-slides](https://github.com/zarazhangrui/frontend-slides) — slides-maker agent 的幻灯片生成能力
- [Agent-Reach](https://github.com/Panniantong/Agent-Reach) — domain-expert agent 的多平台内容抓取能力

## 引用

```bibtex
@software{labmate2026,
  title   = {LabMate: Research Harness for Claude Code},
  author  = {freemty},
  year    = {2026},
  version = {0.4.3},
  url     = {https://github.com/freemty/labmate}
}
```

## License

MIT
