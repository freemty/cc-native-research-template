---
name: commit-changelog
description: "Use when creating git commits, updating CHANGELOG.md, committing across nested repos/submodules, or generating weekly progress summaries."
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

## Weekly Progress Mode

When invoked as `/commit-changelog --weekly` or when user asks for a weekly summary:

1. **Determine week range:**
   - Current ISO week number and date range (Monday-Sunday)
   - Check if `docs/weekly/YYYY-WNN.md` already exists (append mode if so)

2. **Gather data** from real files (never fabricate):
   a. **CHANGELOG.md** — entries since last weekly (or all if first)
   b. **git log** — `git log --oneline --since="last monday"` for commit history
   c. **exp/summary.md** — experiment status changes
   d. **exp/*/README.md** — any new findings sections populated
   e. **.pipeline-state.json** — current stage and experiment

3. **Write structured summary to `docs/weekly/YYYY-WNN.md`:**

   ```markdown
   # Weekly Progress — Week {NN} ({date_range})

   ## Overview
   One paragraph summarizing the week's main achievements.

   ## Key Changes
   (from CHANGELOG.md + git log, grouped by type: Features / Fixes / Docs)

   ## Experiments
   | Exp | Status | Change This Week |
   |-----|--------|-----------------|

   ## Next Week
   (inferred from pipeline state + TODOs in exp READMEs)
   ```

4. **Prompt user:** "Review the weekly summary, then commit? (Y/n)"
