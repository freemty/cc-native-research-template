# Design Spec: claude-code-best-practices Skill

> Date: 2026-03-20
> Status: Draft

## Goal

Publish cc-advisor (currently a personal agent at `~/.claude/agents/cc-advisor.md`) as a standalone, publicly installable skill on GitHub and skills.sh marketplace.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Format | Skill (SKILL.md) | skills.sh marketplace only supports skills; wider distribution across Cursor, Copilot, Cline |
| Content scope | Full (decision framework + knowledge base) | Core competitive advantage is information density |
| Personal refs | Remove all | Only keep universally available skills |
| Name | `claude-code-best-practices` | Matches proven high-install naming pattern on skills.sh |
| Language | English | skills.sh is English-dominant ecosystem |
| Structure | Single file (Plan A) | Hot skills on skills.sh are single SKILL.md; "load once, fully available" |

## SKILL.md Structure

```
---
name: claude-code-best-practices
description: >
  Use when unsure what to do next, starting a new task, needing workflow guidance,
  or asking "how should I approach this". Recommends optimal skill, agent, or
  workflow based on task type and current situation.
---

# Claude Code Best Practices

## Overview
One-liner: Analyze task type -> recommend best workflow -> provide best practice backing.

## Decision Framework
### Classify the Task
Table: task type (feature, bug, refactor, debug, exploration, review, planning, writing, multi-file) + signal keywords

### Recommend Workflow
Decision tree (text-based, not graphviz):
- Planning/Design needed? -> brainstorming -> writing-plans
- Bug/test failure? -> systematic-debugging
- New feature? -> test-driven-development
- 2+ independent tasks? -> dispatching-parallel-agents / subagent-driven-development
- Need isolation? -> using-git-worktrees
- Implementation done? -> verification-before-completion -> requesting-code-review
- Ready to merge? -> finishing-a-development-branch
- Received feedback? -> receiving-code-review

## Skills Quick Reference
### Workflow & Process
Table of universal superpowers:* skills with one-line "when" descriptions

### Content & Presentation
Table: frontend-design (anthropics/skills)

### Utilities
Table: find-skills (vercel-labs/skills), claude-api (anthropics/skills)

(No personal/non-public skills. Removed: commit-changelog, simplify, slides-dispatch,
humanizer, weekly-progress, update-config — these are not publicly installable.)

## Best Practices Knowledge Base

### Source 1: Superpowers Framework
Link + 7 bullet points (English)

### Source 2: AReaL (Vibe Coding)
Link + 10 bullet points (English)

### Source 3: Everything Claude Code
Link + 8 bullet points (English)

### Source 4: Claude Code Official — How It Works
Link + 8 bullet points (English)

### Source 5: Claude Code Official — Hooks Guide
Link + 8 bullet points (English)

### Source 6: Anthropic — Effective Context Engineering
Link + 12 bullet points (English)

### Source 7: Anthropic — Demystifying Evals
Link + 9 bullet points (English)

### Source 8: Manus — Context Engineering for AI Agents
Link + 10 bullet points (English)

### Source 9: Community Resources
Links to skills.sh, openclaw-setup, etc. (curated, no personal tools)

## Synthesized Key Principles

### 1. Think Before Code
### 2. Evidence-Driven
### 3. Context Engineering
### 4. Agent Architecture
### 5. Context Hygiene
### 6. Continuous Improvement
### 7. Parallel Execution
### 8. Hooks as Automation Backbone

Each with 4-7 bullet points synthesized from all sources.
```

## Repo Structure

```
claude-code-best-practices/
  skills/
    claude-code-best-practices/
      SKILL.md              # Main skill file (~320 lines)
  README.md                 # Install + usage + example
  LICENSE                   # MIT
```

Note: `skills/` directory follows skills.sh convention for `npx` installation.

## Content Transformation Rules

### Remove
- All personal project skills: fars-*, hle-solver, rope2sink, agent-exp-orchestration
- All personal tool skills: notion-lifeos, clash-split-routing, agent-reach, munger-observer, nano-banana, notebooklm
- Agent-specific sections: Output Format template, Step 1 Assess (git status diagnosis)
- Chinese language directive ("Always respond in Chinese")
- Model assignment (skill has no model frontmatter)
- Tools declaration (skill has no tools)

### Keep & Transform
- Task Classification table -> English
- Decision tree -> English, remove Step 1 (Assess), start from Classify
- superpowers:* skill references -> keep as-is (publicly installable)
- frontend-design -> keep (anthropics/skills, publicly installable)
- claude-api -> keep (anthropics/skills, publicly installable)
- find-skills -> keep (vercel-labs/skills, publicly installable)
- commit-changelog, simplify, slides-dispatch, humanizer, weekly-progress, update-config -> REMOVE (not publicly installable)
- 9 knowledge base sources -> full content, translate to English
- 8 synthesized principles -> full content, translate to English

### Add
- SKILL.md YAML frontmatter (name + description only)
- README.md with install command, usage scenarios, example interaction

## Behavioral Note

As a skill (not agent), this content is injected into the calling model's context.
Unlike the original cc-advisor agent (pinned to sonnet), the skill runs on whatever
model the user's session uses (opus, sonnet, or haiku). The decision framework is
straightforward enough for any model tier; the knowledge base is passive reference
that benefits from but does not require deep reasoning.

## Token Budget
- Target: ~350-400 lines / ~3500 words
- Within acceptable range for a "loaded on trigger" skill (not always-loaded)
- Trade-off acknowledged: full-load on every trigger, but information density is the core value

## Success Criteria
- Installable via `npx` from skills.sh
- Claude correctly triggers on "how should I approach this" type queries
- Decision framework recommends appropriate workflow for common task types
- Knowledge base provides actionable best practice references
