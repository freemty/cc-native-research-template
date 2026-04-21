# /todo + /update-docs Design Spec

> Date: 2026-04-21
> Status: Draft
> Replaces: workflow-audit (deleted — subsumed by global meta-audit skill)

## Problem

1. **TODO 管理** — 干活时随手想到的待办事项没有固定归档点，手动建文档容易忘索引、写了也找不到。
2. **面向人的文档维护** — `update-knowhow` 服务于 agent（未来 session），但 system design / getting started / README 等文档服务于人（开发者、协作者），两者混在一起导致职责不清。

## Solution: Two Skills, Shared Index Mechanism

### /todo

轻量级任务追踪，一句话追加。

**核心操作：**
- `add` — 追加一条 TODO（默认操作）
- `done N` — 标记第 N 条完成
- `list` — 列出 pending 项
- `clean` — 移除所有已完成项

**存储：** `docs/TODO.md`

**格式：**
```markdown
# TODO

- [ ] 重构 session-start hook 的 path encoding — 2026-04-21
- [x] ~~删除 workflow-audit skill~~ — 2026-04-21
- [ ] 给 domain-expert 加 Mode 6 (code review) — 2026-04-20
```

**自动索引：** 首次创建时写入 CLAUDE.md 的 Specs/Docs 区域。

**触发词：** "todo", "记一下", "待办", "回头要"

### /update-docs

面向人的结构化文档创建/更新。

**核心操作：**
- 创建新文档（指定类型 + 路径）
- 更新现有文档（基于当前代码/实验状态）
- 自动在 CLAUDE.md 中维护索引条目

**支持的文档类型：**

| Type | 典型路径 | 用途 |
|------|---------|------|
| design | `docs/design/{name}.md` | System design, architecture |
| guide | `docs/guides/{name}.md` | Getting started, how-to |
| readme | `README.md` | Project README |
| changelog | `CHANGELOG.md` | Version changelog |
| custom | 用户指定 | 任意结构化文档 |

**工作流程：**
1. 用户触发 `/update-docs` + 说明意图
2. Skill 检查是否已有目标文档
   - 有 → 读取当前内容 + 收集相关代码/状态 → 生成更新
   - 无 → 根据 type 选择模板 → 生成初稿
3. 写入文档
4. 确保 CLAUDE.md 有对应索引条目（没有则追加）

**触发词：** "update docs", "更新文档", "写 README", "更新 design doc", "getting started"

## Shared: Auto-Index Mechanism

两个 skill 共享 CLAUDE.md 索引维护逻辑：

```bash
# 检查 CLAUDE.md 是否已有该文档的索引
grep -q "$DOC_PATH" CLAUDE.md
if [ $? -ne 0 ]; then
  # 追加到合适的 section
fi
```

规则：
- TODO → 追加到 Specs section 下方（作为 "Docs" 子区域）
- design/guide → 追加到 Specs section
- readme/changelog → 不需要索引（已是顶层文件）

## Non-Goals

- 不替代 `update-knowhow`（那个是 for agent 的环境知识）
- 不做 project management（不跟踪 assignee、priority、sprint）
- TODO 不支持子任务或依赖关系（保持极简）

## File Changes

| Action | Path |
|--------|------|
| Create | `skills/todo/SKILL.md` |
| Create | `skills/update-docs/SKILL.md` |
| Update | `CLAUDE.md` — 添加两个新 skill |
| Update | `plugin.json` — skill count (auto-discovered, no change needed) |
| Update | `hooks/hooks.json` — 可选：PostToolUse 提醒（暂不加，按需） |

## Open Questions

1. TODO 是否需要 priority 字段？（倾向不要，保持一行一条）
2. `/update-docs` 是否需要 agent dispatch？（倾向不需要，skill 本身够用）
3. 是否需要 hook 检测"写了文档但没索引"的情况？（可以后加）
