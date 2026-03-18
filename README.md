# cc-native-research-template

> Claude Code 研究项目生命周期 Plugin — 实验骨架、结果分析、领域专家、工作流强制执行。

[English](README_EN.md)

## 安装

```bash
claude plugin install freemty/cc-native-research-template
```

## 快速开始

1. 在你的项目中运行 `/init-project`
2. 按提示输入项目名称、描述、领域
3. 骨架自动创建，开始研究

## 包含什么

### 7 个 Agent

| Agent | 用途 |
|-------|------|
| @project-advisor | 研究项目顾问 — 实验历史、发现、代码导航 |
| @cc-advisor | Claude Code 最佳实践 |
| @domain-expert | 领域研究 — 读论文、解读实验结果 |
| @exp-manager | 实验监控 — 诊断、重试、检测完成 |
| @slides-maker | 生成 HTML 幻灯片 |
| @viz-frontend | 构建分析仪表盘 |
| @template-presenter | 模板介绍与 onboarding |

### 7 个 Skill

| Skill | 用途 |
|-------|------|
| /init-project | 一键初始化项目骨架 |
| /new-experiment | 搭建新实验 |
| /analyze-experiment | 实验完成后分析 |
| /update-project-skill | 更新项目知识库 |
| /present-template | 生成模板介绍幻灯片 |
| /weekly-progress | 周报总结 |
| /commit-changelog | 提交 + CHANGELOG |

### 5 个 Hook

- PreCompact — 压缩前提醒保存进度
- Stop — 结束时检查工作流状态
- PostToolUse(Bash) — commit 后更新 CHANGELOG
- PreToolUse(Write) — 写文件前提醒 brainstorm
- PreToolUse(Bash) — 建议使用 worktree

## 工作流

```
/init-project → /new-experiment → 跑实验 → /analyze-experiment
  → 提交发现 → /update-project-skill → 重复
```

## 定制化

Plugin 提供通用版本。在项目本地创建同名文件即可 override：

```bash
# 例：定制 domain-expert 为你的领域
mkdir -p .claude/agents
cp 你的定制版本 .claude/agents/domain-expert.md
# 项目本地版本自动覆盖 plugin 版本
```

## 卸载

从 settings.json 移除即可。项目目录结构和本地文件不受影响。

## License

MIT
