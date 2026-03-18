---
name: commit-changelog
description: "Use when creating git commits, updating CHANGELOG.md, or committing changes across nested repos/submodules."
---

# Commit & Changelog

## Quick Reference

### Commit Format

```
<type>(scope)?: <summary>

- what changed
- impact: <module/behavior>
- verification: <cmd or note>
```

### Types

| Type | 用途 | Type | 用途 |
|------|------|------|------|
| `feat` | 新功能 | `fix` | Bug 修复 |
| `docs` | 文档 | `refactor` | 重构 |
| `test` | 测试 | `chore` | 构建/工具链 |
| `perf` | 性能 | `build` | 构建系统 |

Breaking change: `feat!: <summary>`

### Changelog Format

```markdown
## vX.Y.Z @author - YYYY-MM-DD

### 新增
### 变更
### 修复
### 构建与工具链
### 其他
```

## Nested Repo / Submodule Workflow

**MUST commit in BOTH repos, inner first:**

```
1. Inner repo (nested): commit + push
2. Outer repo (parent): commit (references inner change) + push
```

### Decision: Which Repo Gets What

| 变更位置 | Inner commit | Outer commit |
|----------|-------------|-------------|
| Only inner files | Yes | Only if submodule pointer needs updating |
| Only outer files | No | Yes |
| Both repos | Yes (first) | Yes (second, reference inner) |
| Inner is gitignored | Yes (independent) | Describe inner changes in outer message |

## Rules

1. **Inner first** — always commit nested repo before parent
2. **One commit, one concern** — split feature/fix from deps/toolchain
3. **Title ≤72 chars**, imperative mood ("add" not "added")
4. **Body = why**, not what (the diff shows what)
5. **HEREDOC for multi-line** — ensures correct formatting
6. **Co-Authored-By** — always include for AI-assisted commits
