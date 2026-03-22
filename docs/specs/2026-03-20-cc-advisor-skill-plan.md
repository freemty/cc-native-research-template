# claude-code-best-practices Skill Publication Plan

> **For agentic workers:** Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish cc-advisor as a standalone, publicly installable skill `claude-code-best-practices` on GitHub.

**Architecture:** Single SKILL.md file containing decision framework + knowledge base, packaged in a GitHub repo compatible with skills.sh `npx` installation.

**Tech Stack:** Markdown, Git, GitHub

**Source spec:** `docs/specs/2026-03-20-cc-advisor-skill-design.md`
**Source agent:** `~/.claude/agents/cc-advisor.md`

---

### Task 1: Create repo and scaffold

**Files:**
- Create: `~/code/projects/claude-code-best-practices/skills/claude-code-best-practices/SKILL.md`
- Create: `~/code/projects/claude-code-best-practices/README.md`
- Create: `~/code/projects/claude-code-best-practices/LICENSE`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p ~/code/projects/claude-code-best-practices/skills/claude-code-best-practices
cd ~/code/projects/claude-code-best-practices
git init
```

- [ ] **Step 2: Create MIT LICENSE**

Standard MIT license with author "sum_young", year 2026.

- [ ] **Step 3: Commit scaffold**

```bash
git add LICENSE
git commit -m "chore: init repo with LICENSE"
```

---

### Task 2: Write SKILL.md — Decision Framework section

This is the top half of the skill: frontmatter + overview + task classification + workflow decision tree + skills quick reference.

**Files:**
- Create: `~/code/projects/claude-code-best-practices/skills/claude-code-best-practices/SKILL.md`

**Source:** `~/.claude/agents/cc-advisor.md` lines 1-151

**Transformation rules:**
- Frontmatter: `name` + `description` only (no model, no tools)
- Remove: Step 1 Assess (git status diagnosis), Output Format section
- Remove: all personal/non-public skills from inventory tables
- Keep skills: `superpowers:*`, `frontend-design`, `claude-api`, `find-skills`
- Decision tree: start from "Classify the Task", no "Assess the Situation"
- Language: all English

- [ ] **Step 1: Write YAML frontmatter**

```yaml
---
name: claude-code-best-practices
description: >
  Use when unsure what to do next, starting a new task, needing workflow guidance,
  or asking "how should I approach this". Recommends optimal skill, agent, or
  workflow based on task type and current situation.
---
```

- [ ] **Step 2: Write Overview section**

One-liner purpose + core principle (2-3 sentences max).

- [ ] **Step 3: Write Classify the Task table**

Translate the task type table (lines 38-49 of source) to English.

- [ ] **Step 4: Write Recommend Workflow decision tree**

Translate decision tree (lines 53-95 of source) to English. Remove Step 1 (Assess). Keep text-based format (no graphviz).

- [ ] **Step 5: Write Skills Quick Reference tables**

Three tables, public skills only:
- Workflow & Process: superpowers:* series (~14 entries)
- Content & Presentation: frontend-design
- Utilities: find-skills, claude-api

- [ ] **Step 6: Review top half for completeness**

Verify: no personal refs, all English, frontmatter valid, decision tree coherent.

---

### Task 3: Write SKILL.md — Knowledge Base section

Bottom half: 9 sources + 8 synthesized principles.

**Files:**
- Modify: `~/code/projects/claude-code-best-practices/skills/claude-code-best-practices/SKILL.md`

**Source:** `~/.claude/agents/cc-advisor.md` lines 152-343

**Transformation rules:**
- Translate all Chinese bullet points to English
- Keep source links and attributions
- Source 9 (Notion notes): remove personal tools (Notion LifeOS, Agent Reach, Clash), keep only public community resources (skills.sh, openclaw-setup, happy)
- Synthesized principles: translate to English, keep all 8 sections

- [ ] **Step 1: Write Sources 1-3** (Superpowers, AReaL, Everything Claude Code)

Translate bullet points to English. Keep original links.

- [ ] **Step 2: Write Sources 4-5** (Claude Code Official: How It Works, Hooks Guide)

Translate bullet points to English. Keep original links.

- [ ] **Step 3: Write Sources 6-7** (Anthropic: Context Engineering, Evals)

Translate bullet points to English. Keep original links.

- [ ] **Step 4: Write Source 8** (Manus: Context Engineering)

Translate bullet points to English. Keep original link.

- [ ] **Step 5: Write Source 9** (Community Resources)

Explicit keep/remove list:
- KEEP: skills.sh, openclaw-setup (public GitHub repo)
- KEEP: happy (public GitHub repo — mobile/web client)
- REMOVE: OpenClaw LifeOS Skill (Notion-specific, niche)
- REMOVE: Agent Reach (personal tool ecosystem)
- REMOVE: Manim Skill (unrelated to Claude Code workflow)
- REMOVE: B站教程 links (Chinese-only, not universal)
- REMOVE: Haiku MCP limitation note (implementation detail, not best practice)

- [ ] **Step 6: Write Synthesized Key Principles (all 8)**

Translate all 8 principle sections to English. Each with 4-7 bullet points.

- [ ] **Step 7: Verify total line count**

Target: 350-400 lines. If over, compress verbose bullet points. If under, content is naturally concise — that's fine.

- [ ] **Step 8: Commit SKILL.md**

```bash
git add skills/claude-code-best-practices/SKILL.md
git commit -m "feat: add claude-code-best-practices skill"
```

---

### Task 4: Write README.md

**Files:**
- Create: `~/code/projects/claude-code-best-practices/README.md`

- [ ] **Step 1: Write README**

Sections:
- Title + one-line description
- Install command (`npx` format)
- What it does (3 bullets)
- When it triggers (3 bullets)
- What's inside (brief TOC of SKILL.md sections)
- Sources credited (list of 9 sources with links)
- Example interaction
- License

- [ ] **Step 2: Commit README**

```bash
git add README.md
git commit -m "docs: add README with install instructions"
```

---

### Task 5: Create GitHub repo and push

- [ ] **Step 1: Create GitHub repo**

```bash
gh repo create claude-code-best-practices --public --description "Claude Code workflow advisor — recommends the right skill, agent, or workflow for any task" --source . --push
```

- [ ] **Step 2: Verify repo is accessible**

```bash
gh repo view claude-code-best-practices
```

---

### Task 6: Verify installation

- [ ] **Step 1: Test install in a temp project**

```bash
cd /tmp && mkdir test-skill && cd test-skill && git init
# Install using skills.sh npx command (exact command TBD based on skills.sh format)
```

- [ ] **Step 2: Verify SKILL.md is in expected location after install**

- [ ] **Step 3: Manual trigger test**

Start a Claude Code session in the test project, ask "how should I approach adding a new feature?" and verify the skill triggers and provides workflow guidance.
