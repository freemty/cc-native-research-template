# General Project Support — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make init-project support general (non-research) software projects via a type selection mechanism.

**Architecture:** Add `type` field (research/general) to project info gathering. Branch directory creation, template selection, and gitignore rules by type. Two separate CLAUDE.md templates.

**Tech Stack:** Markdown (SKILL.md, templates)

---

### Task 1: Rename existing CLAUDE.md template

**Files:**
- Rename: `references/claude-md-template.md` → `references/claude-md-template-research.md`

- [ ] **Step 1: Rename the file**

```bash
cd /Users/sum_young/code/projects/labmate
git mv references/claude-md-template.md references/claude-md-template-research.md
```

- [ ] **Step 2: Commit**

```bash
git add references/
git commit -m "refactor: rename claude-md-template to claude-md-template-research"
```

---

### Task 2: Create general CLAUDE.md template

**Files:**
- Create: `references/claude-md-template-general.md`

- [ ] **Step 1: Write the general template**

Create `references/claude-md-template-general.md` with this content:

```markdown
# {project-name}

> {description}

## Quick commands

| Command | Purpose |
|---------|---------|
| /labmate:update-project-skill | Refresh project knowledge |
| /labmate:commit-changelog | Commit with CHANGELOG |
| /labmate:update-knowhow | Archive environment knowledge |

## Session startup

| What to do | Read first |
|-----------|-----------|
| Catch up on progress | .claude/skills/project-skill/SKILL.md |

## Project knowledge

- **Skill hub:** .claude/skills/project-skill/SKILL.md

## Knowhow

- `docs/knowhow/infrastructure/` — Servers, networking, disk, GPU issues
- `docs/knowhow/toolchain/` — CLI tools, docker, conda/pip, framework tips
- `docs/knowhow/debug-solutions/` — Error investigation paths and fixes
- `docs/knowhow/runbooks/` — Step-by-step operational procedures

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| @project-advisor | opus | Project history, codebase navigation |
| @domain-expert | opus | Domain knowledge, design advice |

## Conventions

- **CHANGELOG rule:** all significant changes must have CHANGELOG entries
- **Worktree rule:** destructive or exploratory changes use git worktree
```

- [ ] **Step 2: Commit**

```bash
git add references/claude-md-template-general.md
git commit -m "feat: add general CLAUDE.md template for non-research projects"
```

---

### Task 3: Update init-project SKILL.md

**Files:**
- Modify: `skills/init-project/SKILL.md`

This is the main task. All changes are in the SKILL.md markdown file.

- [ ] **Step 1: Add type selection to Step 2**

After the existing info gathering (project name, description, domain, compute_env), add type selection. Insert after line 55 (the "用户可以直接回车确认" line), before the `---` separator:

Add a new item 6 to Step 2:

```markdown
6. 自动推断项目类型：
   - 若项目已有 `exp/` 目录，或 README 中包含 experiment/benchmark/training 关键词 → 默认 `research`
   - 否则默认 `general`
   - 在确认信息中增加一行：
     > - 项目类型：`general`（可选：research / general）
```

- [ ] **Step 2: Branch Step 3 directory creation by type**

Restructure Step 3 into shared + type-specific sections:

**Shared (both types):**
- 3.1 Knowhow 目录 (4 subdirs)
- 3.2 其他文档目录: `docs/specs/.gitkeep` only
- 3.3 pipeline 状态文件 (add `"type": "{type}"` as first field)
- 3.4 project-skill 空模板
- 3.5 CHANGELOG.md

**Research only (skip if type=general):**
- 3.6 实验目录: `exp/` + `summary.md`
- 3.7 文档目录 (research): `docs/papers/` + `landscape.md`, `docs/weekly/`, `docs/archive/`
- 3.8 脚本文件: `scripts/launch_exp.py`, `scripts/monitor_exp.sh`, `scripts/download_results.sh`
- 3.9 Viewer: `viewer/app.py`, `viewer/static/index.html`
- 3.10 Slides: `slides/.gitkeep`

- [ ] **Step 3: Branch Step 4 template selection by type**

Change the template reading logic:

```markdown
1. 根据项目类型选择模板：
   - `general` → 用 Read 读取 `<plugin_root>/references/claude-md-template-general.md`
   - `research` → 用 Read 读取 `<plugin_root>/references/claude-md-template-research.md`
2. 替换占位符（同原逻辑）
```

- [ ] **Step 4: Branch Step 5 gitignore rules by type**

Change the gitignore logic:

```markdown
**若类型为 `general`：**
仅追加以下规则（跳过 references/gitignore-rules.md 中的实验相关规则）：

# labmate rules
.pipeline-state.json
.labmate-hook-state.json

**若类型为 `research`：**
按原逻辑读取并追加完整的 `<plugin_root>/references/gitignore-rules.md`
```

- [ ] **Step 5: Update .pipeline-state.json template**

In the pipeline state JSON template (Step 3.3), add `type` field:

```json
{
  "type": "{type}",
  "project_name": "{project-name}",
  "description": "{description}",
  "domain": "{domain}",
  "compute_env": "{compute_env}",
  "current_exp": null,
  "stage": "dev",
  "skill_updated_at": null
}
```

- [ ] **Step 6: Update Step 6 summary output**

The summary should reflect type — general projects won't list exp/, scripts/, viewer/, slides/ in the output. Add a note:

```markdown
项目类型：{type}
```

- [ ] **Step 7: Commit**

```bash
git add skills/init-project/SKILL.md
git commit -m "feat: add general/research type selection to init-project"
```

---

### Task 4: Update SKILL.md references to template path

**Files:**
- Verify: `skills/init-project/SKILL.md` — ensure no hardcoded reference to old `claude-md-template.md` path remains

- [ ] **Step 1: Grep for old template path**

```bash
grep -r "claude-md-template.md" /Users/sum_young/code/projects/labmate/
```

If any references found outside `references/` directory (e.g., in other skills or docs), update them.

- [ ] **Step 2: Commit if changes needed**

```bash
git add -A
git commit -m "fix: update stale references to renamed claude-md-template"
```

Skip if no stale references found.
