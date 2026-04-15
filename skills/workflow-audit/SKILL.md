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

## When to Use

- End of a productive session (you just did a lot of manual work)
- Weekly retrospective
- User asks "what am I doing manually that should be automated?"
- After noticing you've done the same sequence 3+ times

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
