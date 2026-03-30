# update-knowhow Design Spec

> 自动归档环境知识（踩坑、工具链、debug 经验、操作手册），防止信息散落在一次性文档中。

Date: 2026-03-30

## Problem

在研究项目的实验过程中，用户不断积累环境知识——新服务器配置、工具链踩坑、debug 解决方案、操作手册等。当前 agent 的行为是：

1. 每次创建新文档而非更新已有文档
2. 新文档不被索引到 CLAUDE.md，下个 session 读不到
3. 用户需要反复手动要求"更新已有文档"和"加索引"

## Solution

Hook + Skill 组合（复用 LabMate 已有的 hook→skill 模式）：

- **Hook**（`post-knowhow-remind`）：检测 + 提醒
- **Skill**（`/update-knowhow`）：执行归档
- **init-project 改动**：初始化 knowhow 目录结构 + CLAUDE.md 索引

## Components

### 1. 目标文档结构

```
docs/knowhow/
├── infrastructure/     # 服务器、SSH、网络、磁盘、GPU
│   └── {slug}.md
├── toolchain/          # CLI 工具、docker、conda/pip、框架
│   └── {slug}.md
├── debug-solutions/    # error 排查路径 + 最终解决方案
│   └── {slug}.md
└── runbooks/           # "在 X 上跑 Y 需要先做 Z" 操作手册
    └── {slug}.md
```

每个文件按主题/工具命名（kebab-case slug），如 `docker-build-cache.md`、`aliyun-a100.md`。

一个目录下可以有多个文件，每个文件聚焦一个具体主题。

### 2. `/update-knowhow` Skill

**触发方式**：用户说"记下来" / "归档" / `/update-knowhow`，或 agent 提醒后用户确认。

**执行流程**：

1. **提取** — 从当前对话上下文提取关键信息（问题、原因、解决方案、相关命令）
2. **分类** — 判断属于 infrastructure / toolchain / debug-solutions / runbooks 哪个类别。如果不确定，问用户一次
3. **去重检查** — 在目标目录下搜索是否已有相关文件（按文件名 + 内容关键词匹配）。如果有，**更新该条目**而非新增
4. **写入** — 追加或更新到对应文件，格式为结构化内容（问题/原因/解决方案/相关命令）
5. **索引同步** — 检查 CLAUDE.md 中是否已有 `docs/knowhow/` 相关索引条目。如果没有，追加目录级索引（4 条）；如果有，不重复添加
6. **确认** — 输出归档摘要，如："已更新 `docs/knowhow/toolchain/docker.md` → 镜像构建缓存问题"

**关键约束**：

- 永远不在 `docs/knowhow/` 之外创建文件
- 如果用户项目没有 `docs/knowhow/`，提示先跑 `/init-project`
- Skill 内不调用 subagent，直接由当前 agent 执行（内容都在对话上下文里）
- 去重优先：已有相关文件就更新，不创建新文件
- CLAUDE.md 索引粒度是目录级（4 个目录 = 4 条索引），不逐个文件索引

### 3. `post-knowhow-remind` Hook

**类型**：`PostToolUse(Bash)`

**检测逻辑**：检查刚执行的 Bash 命令及输出，匹配以下信号：

- **error/fix 信号** — 输出包含 `error`、`failed`、`permission denied`、`not found` 等关键词
- **环境配置信号** — 命令包含 `apt install`、`pip install`、`docker`、`conda`、`ssh`、`mount`、`export`、`systemctl`、`nvidia-smi`、`chmod`、`curl -o` 等
- **不触发** — 普通的 `ls`、`cat`、`git`、`cd`、`pwd` 操作

**提醒内容**：

```
<knowhow-hint>
刚才的操作看起来包含值得记录的环境知识。
要归档吗？说"记下来"或 /update-knowhow
</knowhow-hint>
```

**频率控制**：

- 使用 `hook-utils` 的 `should_remind`
- 同一 session 内最多提醒 3 次
- 两次提醒之间至少间隔 5 分钟

**约束**：Hook 只负责提醒，不做任何写入操作。用户忽略则跳过，不追问。

### 4. `init-project` 改动

在现有 init-project skill 中追加：

1. **创建目录结构** — 如果 `docs/knowhow/` 不存在，创建 4 个子目录各放 `.gitkeep`
2. **CLAUDE.md 模板** — 在 `references/claude-md-template.md` 文档索引区域追加 knowhow 索引
3. **幂等性** — 目录/索引已存在则跳过

CLAUDE.md 索引内容：

```markdown
## Knowhow
- `docs/knowhow/infrastructure/` — 服务器、网络、磁盘、GPU 踩坑
- `docs/knowhow/toolchain/` — CLI 工具、docker、conda/pip、框架经验
- `docs/knowhow/debug-solutions/` — error 排查路径与解决方案
- `docs/knowhow/runbooks/` — 操作手册（在 X 上跑 Y 需要先做 Z）
```

## Hook Registration

在 `hooks/hooks.json` 中新增：

```json
{
  "type": "PostToolUse",
  "matcher": "Bash",
  "hook_path": "hooks/post-knowhow-remind"
}
```

## Plugin Registration

在 `skills/` 目录下创建 `update-knowhow/SKILL.md`，自动被 plugin.json 发现（已有 `"./skills/"` glob）。

无需修改 `plugin.json`。

## File Manifest

| Action | Path |
|--------|------|
| Create | `skills/update-knowhow/SKILL.md` |
| Create | `hooks/post-knowhow-remind` |
| Edit | `hooks/hooks.json` (add hook entry) |
| Edit | `skills/init-project/SKILL.md` (add knowhow dirs) |
| Edit | `references/claude-md-template.md` (add knowhow index) |

## Out of Scope

- 自动检测对话中的环境知识并无提醒直接归档（全自动模式）
- 跨项目共享 knowhow（每个项目独立维护）
- knowhow 内容的版本控制（依赖 git）
- 与 `update-project-skill` 的联动（project-skill 扫描已有的 docs/ 目录，自然会覆盖）
