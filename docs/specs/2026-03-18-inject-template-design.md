# cc-native-research-template Plugin Design Spec

**Date:** 2026-03-18
**Status:** Draft v3 (post-validation)
**Author:** sum_young + Claude Opus 4.6

## Problem

cc-native-research-template 当前只支持 `Use this template` 创建全新 repo。但大多数用户已有运行中的研究项目，需要"把缺的补上"而非从零开始。

## Solution: Plugin + /init-project

把模板 repo 重构为 CC Plugin。Plugin 提供 agents + skills + hooks（自动加载）。`/init-project` skill 在目标项目中一次性创建目录结构 + 生成 CLAUDE.md。

## Validated Constraints（已验证）

| 约束 | 来源 | 影响 |
|------|------|------|
| Plugin 无法自动分发 rules/ | everything-claude-code README + CC docs | 研究原则等规则回到 CLAUDE.md |
| Agent: 本地 `.claude/agents/` 覆盖 plugin 同名文件 | CC sub-agents.md 文档 | Agent override 可行 |
| Skill: plugin skill 带命名空间前缀 `plugin-name:skill-name` | CC skills.md 文档 | 项目本地同名 skill 与 plugin skill 并存不冲突 |
| hooks.json 由 CC v2.1+ 按约定自动加载，不在 plugin.json 中声明 | PLUGIN_SCHEMA_NOTES.md | hooks 不进 manifest |
| agents 必须显式列出文件路径，不能用目录 | PLUGIN_SCHEMA_NOTES.md | plugin.json 逐个列 agent |
| Plugin 安装格式: `"name@marketplace": true` | installed_plugins.json 实测 | 需要注册 marketplace 或用 CLI 安装 |

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 交付形式 | CC Plugin | 一行配置即用，agents/skills/hooks 自动加载 |
| Agent 定制 | 项目本地 override | `.claude/agents/x.md` 覆盖 plugin 版本（优先级 2 > 4） |
| Skill 定制 | 项目本地创建同名 skill | 本地 `/skill-name` 与 plugin `plugin:skill-name` 并存 |
| CLAUDE.md | `/init-project` 生成完整版 | 含导航 + 研究原则 + 约定 + 状态，项目完全拥有 |
| hooks | `hooks/hooks.json` 约定加载 | 不在 plugin.json 中声明 |

## Architecture

### Plugin Repo Structure

```
cc-native-research-template/
├── .claude-plugin/
│   └── plugin.json
├── agents/                      # CC 自动加载
│   ├── project-advisor.md
│   ├── cc-advisor.md
│   ├── domain-expert.md
│   ├── exp-manager.md
│   ├── slides-maker.md
│   ├── viz-frontend.md
│   └── template-presenter.md
├── skills/                      # CC 自动加载（带 namespace 前缀）
│   ├── init-project/
│   │   └── SKILL.md
│   ├── new-experiment/
│   │   └── SKILL.md
│   ├── analyze-experiment/
│   │   └── SKILL.md
│   ├── update-project-skill/
│   │   └── SKILL.md
│   ├── present-template/
│   │   └── SKILL.md
│   ├── weekly-progress/
│   │   └── SKILL.md
│   └── commit-changelog/
│       └── SKILL.md
├── hooks/
│   ├── hooks.json
│   ├── pre-compact-remind.sh
│   ├── stop-check-workflow.sh
│   ├── post-commit-changelog.sh
│   ├── brainstorm-remind.sh
│   └── worktree-suggest.sh
├── references/                  # init-project 复制用（不自动加载）
│   ├── claude-md-template.md
│   ├── launch_exp.py
│   ├── viewer-app.py
│   └── viewer-templates/
├── package.json
├── README.md
└── CHANGELOG.md
```

### plugin.json

```json
{
  "name": "cc-native-research-template",
  "version": "0.3.0",
  "description": "Research project lifecycle plugin — experiment scaffold, analysis, domain expertise, workflow enforcement",
  "author": {
    "name": "freemty",
    "url": "https://github.com/freemty"
  },
  "homepage": "https://github.com/freemty/cc-native-research-template",
  "repository": "https://github.com/freemty/cc-native-research-template",
  "license": "MIT",
  "keywords": ["research", "experiment", "claude-code", "agents", "skills"],
  "agents": [
    "./agents/project-advisor.md",
    "./agents/cc-advisor.md",
    "./agents/domain-expert.md",
    "./agents/exp-manager.md",
    "./agents/slides-maker.md",
    "./agents/viz-frontend.md",
    "./agents/template-presenter.md"
  ],
  "skills": ["./skills/"]
}
```

### hooks.json

```json
{
  "hooks": {
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/pre-compact-remind.sh\"",
          "async": false
        }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/stop-check-workflow.sh\"",
          "async": false
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/post-commit-changelog.sh\"",
          "async": false
        }]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [{
          "type": "command",
          "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/brainstorm-remind.sh\"",
          "async": false
        }]
      },
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/worktree-suggest.sh\"",
          "async": false
        }]
      }
    ]
  }
}
```

### 用户安装

```bash
claude plugin install freemty/cc-native-research-template
```

安装后 agents/skills/hooks 立即可用。`/init-project` 创建项目骨架。

## /init-project Skill

### 触发

用户在已有项目中执行 `/init-project`（或 `/cc-native-research-template:init-project`）。

### 行为

**Step 1: 检测现状**
- 扫描项目根目录已有结构
- 检查 git status，如有未提交变更则警告 + 确认继续

**Step 2: 收集项目信息**
- 项目名称
- 一行描述
- 研究领域
- 计算环境（local / remote-gpu / cloud）

**Step 3: 创建目录结构**

只创建不存在的目录/文件，已存在的跳过：

```
exp/
  .gitkeep
  summary.md
docs/
  papers/
    .gitkeep
    landscape.md          # placeholder
  specs/.gitkeep
  weekly/.gitkeep
  archive/.gitkeep
scripts/
  launch_exp.py           # 从 plugin references/ 读取写入
viewer/
  app.py                  # 从 plugin references/ 读取写入
  templates/.gitkeep
slides/.gitkeep
.pipeline-state.json      # 初始状态
```

**Step 4: 生成 CLAUDE.md**

如果 CLAUDE.md 不存在：从 `references/claude-md-template.md` 生成完整版本，用 Step 2 信息填充。

如果 CLAUDE.md 已存在：按 h2 标题检测缺失 section，只追加不存在的，不修改已有。

**生成的 CLAUDE.md 完整结构：**

```markdown
# {project-name}

> {description}

## Quick Commands

| Command | Purpose |
|---------|---------|
| /init-project | Initialize research skeleton |
| /new-experiment | Scaffold new experiment |
| /analyze-experiment | Analyze results |
| /update-project-skill | Refresh project knowledge |
| python scripts/launch_exp.py --exp <id> | Launch experiment |

## Session Startup

| 要做什么 | 先读什么 |
|---------|--------|
| 了解当前进展 | .claude/skills/project-skill/SKILL.md |
| 查阅领域文献 | docs/papers/landscape.md |
| 运行实验 | exp/{current_exp}/README.md |

## Project Knowledge

- **Primary skill hub:** .claude/skills/project-skill/SKILL.md
- **Experiment log:** exp/summary.md
- **Domain papers:** docs/papers/

## Agents

| Agent | Model | Purpose | Source |
|-------|-------|---------|--------|
| project-advisor | opus | 研究项目顾问 | plugin |
| cc-advisor | sonnet | CC 最佳实践 | plugin |
| domain-expert | opus | 领域研究专家 | plugin |
| exp-manager | sonnet | 实验监控 | plugin |
| slides-maker | sonnet | 幻灯片生成 | plugin |
| viz-frontend | sonnet | 可视化仪表盘 | plugin |
| template-presenter | sonnet | 模板介绍 | plugin |

## Skills

| Skill | Trigger | Source |
|-------|---------|--------|
| init-project | 初始化项目骨架 | plugin |
| new-experiment | 开始新实验 | plugin |
| analyze-experiment | 实验完成后分析 | plugin |
| update-project-skill | 更新项目知识 | plugin |
| present-template | 生成模板介绍 | plugin |
| weekly-progress | 周报总结 | plugin |
| commit-changelog | 提交 + CHANGELOG | plugin |

## Workflow

dev -> /new-experiment -> run experiment -> /analyze-experiment
  -> commit findings -> /update-project-skill -> repeat

Pipeline state tracked in .pipeline-state.json.

## Research Principles

1. **Measure first** — 攻击实测最大瓶颈，不凭直觉
2. **Baseline 不可侵犯** — 每个 claim 必须有可复现 baseline 对比
3. **统计显著性** — 单次结果不下结论，关注方差
4. **Ablation 驱动** — 多因素改动逐一隔离
5. **尊重负面结论** — 方向不重复，除非有新证据
6. **预测先行** — 实验前记录预期数值范围，实验后校准

## Conventions

- **Exp naming:** exp{NN}{x} — number=major, letter=variant
- **Prompt versioning:** prompts/{component}/_v{NN}.md — never overwrite
- **CHANGELOG rule:** all iterating artifacts must have CHANGELOG entries
- **Worktree rule:** destructive/exploratory changes use git worktree

## Current State

- **current_exp:** null
- **stage:** dev
- **skill_updated_at:** {date}
```

**Step 5: 追加 .gitignore 规则**

strip 后去重追加。注释行作为 section 标记总是追加。

**Step 6: 输出摘要 + 下一步**

## Override 机制

| 组件 | 机制 | 用法 |
|------|------|------|
| Agent | 本地 `.claude/agents/x.md` 覆盖 plugin | 想定制 domain-expert 领域时创建本地版 |
| Skill | 本地 `.claude/skills/x/SKILL.md` 与 plugin 并存（不同 namespace） | 本地 `/skill` 优先于 `plugin:skill` |
| Hook | 项目 settings.local.json 与 plugin hooks 合并 | 本地同 matcher hook 覆盖 |
| CLAUDE.md | 项目完全拥有 | 自由修改，plugin 不碰 |
| project-skill | 项目本地 `.claude/skills/project-skill/` | 累积知识，/init-project 创建空模板 |

### Skill Namespace 说明

Plugin skills 调用格式为 `/cc-native-research-template:new-experiment`。CC 的 `/` 菜单会列出所有可用 skill（含 plugin 和本地），用户可直接选择。

如果用户希望用短名调用（`/new-experiment`），可以在项目本地创建一个同名 skill 作为 proxy：

```markdown
# /new-experiment (项目本地 .claude/skills/new-experiment/SKILL.md)
Read and follow the plugin skill at ${CLAUDE_PLUGIN_ROOT}/skills/new-experiment/SKILL.md
```

或直接在 `/init-project` 时自动创建这些 proxy skill。**v1 暂不实现**，先用 namespace 前缀。

## 迁移步骤

1. 创建 `.claude-plugin/plugin.json`
2. 移动 `.claude/agents/` → `agents/`
3. 移动 `.claude/skills/` → `skills/`（排除 project-skill，那是实例数据）
4. 移动 `.claude/hooks/` → `hooks/` + 创建 `hooks/hooks.json`
5. 创建 `skills/init-project/SKILL.md`
6. 移动 `scripts/`、`viewer/` → `references/`
7. 创建 `references/claude-md-template.md`
8. 更新 README.md 为 plugin 安装说明

### 分支策略

- **main** = Plugin 发布版本
- **dev** = 开发 + 自用（含 override、实验数据等实例内容）

## Edge Cases

1. **重复执行 /init-project** — 幂等。只创建不存在的文件，CLAUDE.md 按 h2 去重追加。
2. **git dirty state** — 警告 + 确认继续。
3. **Plugin 更新后** — agents/skills/hooks 自动更新。CLAUDE.md 不受影响（项目拥有）。Agents/Skills 表中的条目可能需要手动更新。
4. **卸载 plugin** — 项目目录结构和 CLAUDE.md 保留。Plugin agents/skills/hooks 不再可用，但不损坏。
5. **多 plugin 同名 agent** — 项目本地 > plugin（按启用顺序）。

## Out of Scope (v1)

- Marketplace 发布（先用 GitHub URL）
- Skill proxy 自动生成（先用 namespace 前缀）
- 自动迁移已有零散 agents/skills

## Success Criteria

1. `claude plugin install` 即可启用
2. `/init-project` < 2 分钟完成骨架创建
3. @domain-expert、/new-experiment 等在目标项目可用
4. 项目本地 `.claude/agents/domain-expert.md` 成功 override
5. Plugin 更新后未 override 的 agents 自动更新
6. 卸载后项目不损坏
