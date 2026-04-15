# Workflow Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a meta-skill that audits cross-session workflow patterns and suggests + implements project-specific automation (hooks, agents, skills).

**Architecture:** Smart Skill (`/workflow-audit`) collects environment data via bash, dispatches `@workflow-auditor` (opus) agent with structured context. Agent reads session `.jsonl` transcripts, cross-analyzes with git history and existing automation, generates prioritized report, and implements approved changes. Stop hook nudges user after productive sessions.

**Tech Stack:** Markdown (agent/skill definitions), Bash (skill data collection, hook logic), Python one-liners (JSON/date parsing in hooks)

**Spec:** `docs/specs/2026-04-15-workflow-audit-design.md`

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `agents/workflow-auditor.md` | Create | Agent: session transcript analysis, pattern classification, report generation, implementation |
| `skills/workflow-audit/SKILL.md` | Create | Skill: mode detection, session path discovery, metadata collection, agent dispatch |
| `hooks/stop-check-workflow` | Modify | Append workflow-audit nudge (session > 2h, commits > 10, 7d cooldown) |
| `.claude-plugin/plugin.json` | Modify | Add `workflow-auditor.md` to agents array |

---

### Task 1: Create @workflow-auditor Agent

**Files:**
- Create: `agents/workflow-auditor.md`

- [ ] **Step 1: Write the agent file**

```markdown
---
name: workflow-auditor
model: opus
description: "Analyze project workflow patterns across sessions and suggest project-specific automation (hooks, agents, skills)"
tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Write
  - Edit
---

# Workflow Auditor Agent

You audit how the user works in THIS project across recent sessions, identify repetitive manual patterns, and propose + implement project-specific automation. Always respond in Chinese (中文).

## Input

You receive structured context from the /workflow-audit skill:

```yaml
mode: full | degraded
session_files: [list of .jsonl paths]
git_summary: |
  <git log output>
automation_inventory:
  hooks: [...]
  agents: [...]
  skills: [...]
pipeline_state: {...} | null
knowhow_files: [...] | null
past_audits: [...] | null
```

## Phase 1: Session Transcript Analysis

Read each `.jsonl` file via the Read tool. For recent sessions (last 3), read thoroughly. For older sessions, sample (first 500 + last 500 lines).

Extract these signals:

| Signal | How to Find | Meaning |
|--------|------------|---------|
| Tool call frequency | Count `"type": "tool_use"` entries | Which tools dominate |
| Repeated command sequences | Bash tool `command` field, find 3+ similar sequences | Automation candidate |
| File touch hotspots | Read/Edit/Write `file_path` parameter frequency | May need auto-format/auto-test |
| Human message patterns | `"type": "human"` with repeated instructions | Should become a hook |
| Agent dispatch | `subagent_type` field presence/absence | Which agents are used vs. idle |
| Error-fix cycles | Bash commands that fail then repeat with slight changes | Error-prone workflow |

## Phase 2: Cross-Analysis

Combine session signals with:
- **Git history**: Correlate commit clusters with session tool patterns
- **Existing automation**: Which hooks/agents/skills exist but have no session evidence of use?
- **Knowhow** (full mode): Do debug-solutions entries match recurring session error patterns?
- **Past audits** (if any): Which previous P0/P1 items are resolved vs. still present?

## Phase 3: Pattern Classification

Classify each pattern into one of 5 categories:

| Category | Signal | Automation Type |
|----------|--------|-----------------|
| Repetitive Sequence | Same command sequence 3+ times | Hook (PostToolUse) |
| Error-Prone Setup | Knowhow entries / repeated error→fix cycles | Validation hook (PreToolUse) |
| Missing Feedback | Output generated without validation step | QA agent + trigger hook |
| Underused Asset | Agent/skill defined but no dispatch evidence | Usage reminder or deprecation |
| Manual Compilation | Build/compile commands repeated | PostToolUse auto-build hook |

Assign priority:
- **P0**: Pattern occurs 5+ times across sessions, or costs > 10 min per occurrence
- **P1**: Pattern occurs 3-4 times, or costs 5-10 min per occurrence
- **P2**: Pattern occurs 2-3 times, or is a quality improvement

## Phase 4: Generate Report

Write the report to `docs/workflow-audits/YYYY-MM-DD.md`. If the file exists, use `YYYY-MM-DD-2.md`.

Report format:

```markdown
# Workflow Audit — {project_name}

Date: {YYYY-MM-DD}
Mode: full | degraded
Period: Last 7 days
Sessions analyzed: {N}
Commits: {M}

## Detected Patterns

### [P0] {pattern_name}
- **Evidence**: {specific session ID + tool calls, or git commit hashes}
- **Current flow**: step 1 → step 2 → ... → step N
- **Friction**: {what takes time or goes wrong}
- **Recommendation**: hook | agent | skill
- **Implementation sketch**:
  ```json
  // hook config or agent frontmatter preview
  ```

### [P1] ...

## Automation Health

| Name | Type | Status | Evidence |
|------|------|--------|----------|
| {name} | hook/agent/skill | ✅ active / ⚠️ unused / ❌ broken | {evidence} |

## Actions

1. [P0] Create `{name}` — {one-line description}
2. [P1] ...

## Trend (vs previous audit)

{If docs/workflow-audits/ has previous reports:}
- {P0 from YYYY-MM-DD}: "{pattern}" → ✅ resolved / ❌ still present
- New: {newly discovered patterns}

{If first audit: "First audit — no trend data."}
```

### Evidence Requirement

Every pattern MUST cite concrete evidence. Acceptable evidence:
- Session file name + approximate line range showing the pattern
- Git commit hash showing repeated edits
- Tool call count from transcript analysis

Do NOT report patterns based on speculation or general assumptions.

## Phase 5: Implementation (on user request)

When the user says "implement N" or "implement all P0":

1. **Hook**: Write bash script to project's `.claude/hooks/` directory. Update `.claude/settings.json` by reading existing content first, then merging (never replace). Validate JSON with `python3 -c "import json; json.load(open('.claude/settings.json'))"`.

2. **Agent**: Write `.claude/agents/{name}.md` with proper frontmatter (name, model, description, tools).

3. **Skill**: Write `.claude/skills/{name}/SKILL.md` with proper frontmatter (name, description, disable-model-invocation).

4. After each implementation, commit:
   ```bash
   git add <created files>
   git commit -m "feat: add {name} {type} from workflow audit"
   ```

### Implementation Constraints

- Always read existing settings.json before writing (merge, don't replace)
- Validate JSON syntax after writing settings
- Frequent hooks (PostToolUse) must have timeout < 10s
- New hooks default to advisory (additionalContext), not blocking
- Follow project's naming conventions (kebab-case hooks, lowercase agents)
- If mode is degraded, only create .claude/ local automation (no labmate-specific features)

## Anti-Patterns

- Don't suggest automation for one-off tasks (require 3+ occurrences minimum)
- Don't automate things the user explicitly does manually for control reasons
- Don't create hooks that slow down every Edit/Write
- Don't duplicate automation that already exists
- Don't recommend labmate-specific features in degraded mode
```

- [ ] **Step 2: Verify frontmatter matches labmate conventions**

Run: `head -6 agents/workflow-auditor.md`

Expected output:
```
---
name: workflow-auditor
model: opus
description: "Analyze project workflow patterns across sessions and suggest project-specific automation (hooks, agents, skills)"
tools:
  - Read
```

Verify: `name` field is lowercase kebab-case, `model` is `opus`, `tools` is a YAML list (matching `domain-expert.md` pattern).

- [ ] **Step 3: Commit**

```bash
git add agents/workflow-auditor.md
git commit -m "feat: add @workflow-auditor agent for cross-session pattern analysis"
```

---

### Task 2: Create /workflow-audit Skill

**Files:**
- Create: `skills/workflow-audit/SKILL.md`

- [ ] **Step 1: Write the skill file**

```markdown
---
name: workflow-audit
description: >
  Meta-skill that audits project workflow patterns across recent sessions and
  suggests project-specific automation. Use when user says "workflow audit",
  "what should I automate", "what hooks do I need", "review my workflow",
  "audit", or at end of long sessions.
disable-model-invocation: true
---

# Workflow Audit

Analyze cross-session work patterns, find repetitive manual workflows, and suggest + implement automation.

## Step 1: Detect Mode

Check if this is a labmate-initialized project:

```bash
if [ -f ".pipeline-state.json" ]; then
  # Full mode: all data sources available
else
  # Degraded mode: git + sessions + .claude/ only
fi
```

## Step 2: Locate Session Transcripts

Find recent session `.jsonl` files for this project:

```bash
PROJECT_PATH=$(pwd)
ENCODED=$(echo "$PROJECT_PATH" | sed 's|/|-|g')
SESSION_DIR="$HOME/.claude/projects/${ENCODED}"

# List .jsonl files modified in last 7 days, max 10, newest first
find "$SESSION_DIR" -maxdepth 1 -name "*.jsonl" -mtime -7 2>/dev/null | sort -r | head -10
```

If no session files found, report: "No session transcripts found for this project in the last 7 days. The audit will rely on git history only."

## Step 3: Collect Metadata

Run these commands via Bash tool and capture output:

### Both modes:

```bash
# Git summary (last 7 days)
git log --oneline --stat --since="7 days ago" 2>/dev/null | head -200

# Hook inventory
cat .claude/settings.json 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    hooks = data.get('hooks', {})
    for event, entries in hooks.items():
        for e in entries:
            matcher = e.get('matcher', '*')
            for h in e.get('hooks', []):
                cmd = h.get('command', '')
                print(f'  {event} [{matcher}]: {cmd}')
except: print('  (no hooks)')
"

# Agent inventory
ls .claude/agents/*.md 2>/dev/null || echo "(no project agents)"

# Skill inventory
ls .claude/skills/*/SKILL.md 2>/dev/null || echo "(no project skills)"
```

### Full mode only:

```bash
# Pipeline state
cat .pipeline-state.json 2>/dev/null || echo "(no pipeline state)"

# Knowhow index
ls docs/knowhow/*/*.md 2>/dev/null || echo "(no knowhow)"

# Project memory
cat ~/.claude/projects/$(pwd | sed 's|/|-|g')/memory/MEMORY.md 2>/dev/null | head -50

# Past audit reports
ls docs/workflow-audits/*.md 2>/dev/null || echo "(no previous audits)"
```

## Step 4: Dispatch @workflow-auditor

Use the Agent tool to dispatch @workflow-auditor with subagent_type "labmate:workflow-auditor":

```
Prompt template:

Analyze this project's workflow patterns and generate an audit report.

## Context

Mode: {full | degraded}

### Session Transcript Files (read these via Read tool)
{list of .jsonl paths, one per line}

### Git History (last 7 days)
{git log output}

### Existing Automation
Hooks:
{hook inventory output}

Agents:
{agent inventory output}

Skills:
{skill inventory output}

{if full mode:}
### Pipeline State
{pipeline state JSON}

### Knowhow Files
{knowhow file list}

### Past Audits
{past audit file list — read these to compare trends}
{end if}

{if degraded mode:}
### Degraded Mode Notice
This is not a labmate-initialized project. Do NOT recommend labmate-specific
features (pipeline-state hooks, knowhow archival, exp-manager integration).
Only recommend: hooks (.claude/settings.json), agents (.claude/agents/),
skills (.claude/skills/).
{end if}

Follow the analysis framework in your agent instructions.
Write the report to docs/workflow-audits/{today's date}.md.
Then present the report summary to the user.
```

## Step 5: Present Results

After the agent returns, show the user:
1. Summary of detected patterns (P0 items highlighted)
2. Automation health status
3. Prompt: "Say `implement N` to create a specific item, or `implement all P0` for batch."

## Step 6: Implementation (if requested)

If the user says "implement N" or "implement all P0", dispatch @workflow-auditor again with:

```
The user wants to implement the following items from the audit report at
docs/workflow-audits/{date}.md:

{specific items to implement}

Read the report, then create the hook/agent/skill files as specified.
Follow the Implementation Constraints in your agent instructions.
```

## Common Mistakes

- **Skipping session transcript analysis** — Session .jsonl files are the primary signal source. Always attempt to locate and read them.
- **Reporting speculative patterns** — Every pattern needs concrete evidence (session ID, git hash, tool call count).
- **Recommending labmate features in degraded mode** — Check mode before dispatching.
- **Replacing settings.json** — Always merge with existing content.
- **Creating docs/workflow-audits/ in init-project** — This directory is created on first audit only.
```

- [ ] **Step 2: Verify skill auto-discovery**

```bash
# Skill directory convention: skills/{name}/SKILL.md
ls skills/workflow-audit/SKILL.md
```

Expected: file exists. Plugin.json `"skills": ["./skills/"]` will auto-discover it.

- [ ] **Step 3: Verify frontmatter matches labmate conventions**

```bash
head -7 skills/workflow-audit/SKILL.md
```

Expected:
```
---
name: workflow-audit
description: >
  Meta-skill that audits project workflow patterns across recent sessions and
  suggests project-specific automation. Use when user says "workflow audit",
```

Verify: has `disable-model-invocation: true`, description is trigger-rich.

- [ ] **Step 4: Commit**

```bash
git add skills/workflow-audit/SKILL.md
git commit -m "feat: add /workflow-audit skill for cross-session pattern analysis"
```

---

### Task 3: Extend Stop Hook with Audit Nudge

**Files:**
- Modify: `hooks/stop-check-workflow` (append after existing logic)

- [ ] **Step 1: Read current hook**

```bash
cat hooks/stop-check-workflow
```

Verify the file ends with the CHANGELOG compliance check block.

- [ ] **Step 2: Append audit nudge logic**

Add the following block at the end of `hooks/stop-check-workflow`, after the existing CHANGELOG compliance check:

```bash
# Workflow audit nudge — suggest /workflow-audit after productive sessions
ENCODED_PATH=$(pwd | sed 's|/|-|g')
SESSION_DIR="$HOME/.claude/projects/${ENCODED_PATH}"
CURRENT_SESSION=$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | head -1)
if [ -n "$CURRENT_SESSION" ]; then
  SESSION_START=$(stat -f%m "$CURRENT_SESSION" 2>/dev/null || stat -c%Y "$CURRENT_SESSION" 2>/dev/null || echo "0")
  NOW=$(date +%s)
  SESSION_AGE_HOURS=$(( (NOW - SESSION_START) / 3600 ))
  RECENT_COMMITS=$(git log --oneline --since="${SESSION_AGE_HOURS} hours ago" 2>/dev/null | wc -l | tr -d ' ')

  if [ "$SESSION_AGE_HOURS" -ge 2 ] && [ "$RECENT_COMMITS" -ge 10 ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    source "${SCRIPT_DIR}/hook-utils"
    if [ "$(should_remind 'workflow_audit' 168)" = "yes" ]; then
      echo "Productive session (${SESSION_AGE_HOURS}h, ${RECENT_COMMITS} commits). Consider running /workflow-audit to find automation opportunities."
      mark_reminded "workflow_audit"
    fi
  fi
fi
```

- [ ] **Step 3: Verify hook syntax**

```bash
bash -n hooks/stop-check-workflow && echo "OK"
```

Expected: `OK` (no syntax errors).

- [ ] **Step 4: Verify hook-utils sourcing works**

```bash
# hook-utils must be in same directory
ls hooks/hook-utils
```

Expected: file exists. The `source "${SCRIPT_DIR}/hook-utils"` call will find it.

- [ ] **Step 5: Commit**

```bash
git add hooks/stop-check-workflow
git commit -m "feat: add workflow-audit nudge to stop hook"
```

---

### Task 4: Register Agent in plugin.json

**Files:**
- Modify: `.claude-plugin/plugin.json`

- [ ] **Step 1: Add workflow-auditor to agents array**

In `.claude-plugin/plugin.json`, add `"./agents/workflow-auditor.md"` to the `agents` array:

```json
"agents": [
    "./agents/project-advisor.md",
    "./agents/domain-expert.md",
    "./agents/exp-manager.md",
    "./agents/slides-maker.md",
    "./agents/viz-frontend.md",
    "./agents/workflow-auditor.md"
]
```

- [ ] **Step 2: Validate JSON**

```bash
python3 -c "import json; json.load(open('.claude-plugin/plugin.json')); print('Valid JSON')"
```

Expected: `Valid JSON`

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "chore: register workflow-auditor agent in plugin.json"
```

---

### Task 5: Integration Verification

**Files:** None (verification only)

- [ ] **Step 1: Verify file layout**

```bash
echo "=== Agent ===" && head -6 agents/workflow-auditor.md
echo "=== Skill ===" && head -6 skills/workflow-audit/SKILL.md
echo "=== Plugin ===" && python3 -c "
import json
p = json.load(open('.claude-plugin/plugin.json'))
print('Agents:', len(p['agents']))
print('workflow-auditor registered:', any('workflow-auditor' in a for a in p['agents']))
"
echo "=== Hook ===" && tail -5 hooks/stop-check-workflow
```

Expected:
- Agent frontmatter shows `name: workflow-auditor`, `model: opus`
- Skill frontmatter shows `name: workflow-audit`, `disable-model-invocation: true`
- Plugin shows 6 agents, workflow-auditor registered: True
- Hook ends with the audit nudge block

- [ ] **Step 2: Verify session .jsonl discovery works for this project**

```bash
ENCODED=$(pwd | sed 's|/|-|g')
SESSION_DIR="$HOME/.claude/projects/${ENCODED}"
echo "Session dir: $SESSION_DIR"
ls "$SESSION_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' '
```

Expected: session directory exists, at least 1 `.jsonl` file found.

- [ ] **Step 3: Verify CLAUDE.md is up to date**

```bash
grep "workflow-audit" CLAUDE.md
```

Expected: entries in Quick commands, Agents, Skills, and Specs tables (already added during brainstorming).

- [ ] **Step 4: Bump version**

```bash
# Update version in plugin.json: 0.7.0 → 0.8.0
python3 -c "
import json
p = json.load(open('.claude-plugin/plugin.json'))
print('Current version:', p['version'])
"
```

Update version to `0.8.0` in `.claude-plugin/plugin.json`, then:

```bash
git add .claude-plugin/plugin.json
git commit -m "chore: bump version to v0.8.0"
```
