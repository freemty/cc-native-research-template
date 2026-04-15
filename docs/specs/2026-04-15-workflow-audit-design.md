# Spec: Workflow Audit — Meta-Skill for Project Harness Evolution

> Analyzes cross-session work patterns and suggests + implements project-specific automation.
> Target: labmate skill (#11) + agent (#6), with degraded mode for non-labmate projects.
> Date: 2026-04-15

---

## Problem

Users develop repetitive manual workflows over time that should be automated, but:
1. They don't notice the repetition (boiling frog)
2. They don't know what automation primitives are available (hooks, agents, skills)
3. Even when they notice, the effort to set up automation feels too high

Claude Code's built-in "insights" feature surfaces behavioral patterns but doesn't act on them. We need a **proactive system** that detects patterns AND implements fixes.

### Evidence (from rope2sink prototype)

In a single 12-hour session, the prototype identified:

| Manual Pattern | Frequency | Wasted Time | Fix |
|---------------|-----------|-------------|-----|
| SSH + conda + scp + nohup + tail log | 8x | ~20 min | exp-launch hook |
| plot -> Read PDF -> find issues -> fix -> replot | 12x | ~40 min | figure-qa agent |
| Manual pdflatex after .tex edits | 8x | ~10 min | paper-compile hook |
| scp individual files to/from server | 10x | ~15 min | server-sync script |
| Check which JSONs are stale/missing | 5x | ~10 min | data manifest |

Total: **~1.5 hours of automatable work in one session**.

---

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Session data | Agent reads `.jsonl` directly | Maximum flexibility, opus can judge relevance |
| Cross-project | Single project only | Clean scope, no privacy leakage |
| Trigger | Manual + Stop hook nudge (7d cooldown) | Low noise, user-initiated |
| Placement | Labmate plugin + degraded mode | Full ecosystem integration, but usable anywhere |
| Report persistence | `docs/workflow-audits/YYYY-MM-DD.md` | Enables trend tracking |
| Architecture | Smart Skill + Focused Agent | Cheap data collection in bash, expensive analysis in opus |
| Implementation phase | Same agent call | Natural conversational flow |

---

## Architecture

```
+-----------------------------------------------------------+
|  /workflow-audit  (skill, SKILL.md)                       |
|  Entry point + environment detection + data collection    |
|                                                           |
|  1. Detect labmate mode (full / degraded)                 |
|  2. Locate session .jsonl paths (last 7d, max 10)         |
|  3. Collect metadata (git, hooks, agents, skills, ...)    |
|  4. Assemble structured context -> dispatch agent         |
+---------------------------+-------------------------------+
                            |
                            v
+-----------------------------------------------------------+
|  @workflow-auditor  (agent, opus)                         |
|  Pattern analysis + report generation + implementation    |
|                                                           |
|  Input: structured context + .jsonl paths from skill      |
|  1. Read session .jsonl -> extract tool call patterns     |
|  2. Cross-analyze git + sessions + existing automation    |
|  3. Classify (5 categories) + prioritize (P0/P1/P2)      |
|  4. Generate Audit Report                                 |
|  5. Write to docs/workflow-audits/YYYY-MM-DD.md           |
|  6. [on demand] "implement N" -> create hook/agent/skill  |
+-----------------------------------------------------------+

+-----------------------------------------------------------+
|  Stop hook extension  (stop-check-workflow)                |
|  Condition: session > 2h AND commits > 10 AND 7d cooldown |
|  Output: "Consider running /workflow-audit"               |
+-----------------------------------------------------------+
```

---

## Skill: /workflow-audit

### Mode Detection

```bash
if [ -f ".pipeline-state.json" ]; then
  MODE="full"     # labmate project, all data sources available
else
  MODE="degraded"  # non-labmate project, git + sessions + .claude/ only
fi
```

### Session .jsonl Location

```bash
PROJECT_PATH=$(pwd)
ENCODED=$(echo "$PROJECT_PATH" | sed 's|[^A-Za-z0-9]|-|g')
SESSION_DIR="$HOME/.claude/projects/${ENCODED}"

# Last 7 days, max 10 sessions, sorted by modification time
find "$SESSION_DIR" -maxdepth 1 -name "*.jsonl" -mtime -7 |
  sort -t/ -k1 | tail -10
```

### Metadata Collection

All done in bash (zero LLM token cost):

| Data | Command | Mode |
|------|---------|------|
| Git summary | `git log --oneline --stat --since=7d` | both |
| Hook inventory | `cat .claude/settings.json \| jq '.hooks'` + `ls hooks/` | both |
| Agent inventory | `ls .claude/agents/` | both |
| Skill inventory | `ls .claude/skills/*/SKILL.md` | both |
| Pipeline state | `cat .pipeline-state.json` | full only |
| Knowhow index | `ls docs/knowhow/*/*.md` | full only |
| Memory index | `cat memory/MEMORY.md` | full only |
| Past audits | `ls docs/workflow-audits/*.md` | full only |

### Dispatch Context Format

```yaml
---
mode: full | degraded
session_files:
  - /path/to/session1.jsonl
  - /path/to/session2.jsonl
git_summary: |
  <git log output>
automation_inventory:
  hooks: [...]
  agents: [...]
  skills: [...]
pipeline_state: {...} | null
knowhow_files: [...] | null
past_audits: [...] | null
---
```

---

## Agent: @workflow-auditor

### Model: opus

### Tools: Read, Bash, Glob, Grep, Write, Edit

### Session Transcript Analysis

Agent reads `.jsonl` files via Read tool, extracting:

| Signal | Extraction | Meaning |
|--------|-----------|---------|
| Tool call frequency | `type: "tool_use"` count | Which tools are used most |
| Repeated command sequences | Bash tool `command` field, 3+ similar sequences | Automation candidate |
| File touch hotspots | Read/Edit/Write `file_path` parameter | Frequent edits = may need auto-format/auto-test |
| Human message patterns | `type: "human"` repeated instructions | User repeatedly asking for same thing = should be hook |
| Agent dispatch | `subagent_type` field | Which agents are used vs. never invoked |

Agent decides how deeply to read each session (e.g., recent 3 sessions fully, older ones sampled).

### Pattern Classification (5 categories)

| Category | Signal | Automation Type |
|----------|--------|-----------------|
| Repetitive Sequence | Same command sequence 3+ times | Hook (PostToolUse) |
| Error-Prone Setup | Knowhow entries / repeated error->fix cycles | Validation hook (PreToolUse) |
| Missing Feedback | Output generated without validation step | QA agent + trigger hook |
| Underused Asset | Agent/skill defined but no dispatch evidence | Usage reminder or deprecation |
| Manual Compilation | Build/compile commands repeated | PostToolUse auto-build hook |

### Report Format

```markdown
# Workflow Audit -- {project_name}

Date: {YYYY-MM-DD}
Mode: full | degraded
Period: Last 7 days
Sessions analyzed: {N}
Commits: {M}

## Detected Patterns

### [P0] {pattern_name}
- **Evidence**: {specific session/git evidence}
- **Current flow**: step 1 -> step 2 -> ... -> step N
- **Friction**: {what's wrong}
- **Recommendation**: hook | agent | skill
- **Implementation sketch**: (brief code or config)

### [P1] ...

## Automation Health

| Name | Type | Status | Evidence |
|------|------|--------|----------|
| post-knowhow-remind | hook | active | triggered 3x in session abc123 |
| @exp-manager | agent | unused | no dispatch in 7 days |

## Actions

1. [P0] Create `{name}` -- {one-line}
2. [P1] ...

## Trend (vs previous audit)

{If docs/workflow-audits/ has history, compare:}
- P0 from YYYY-MM-DD: "SSH dance" -> resolved (exp-launch hook added)
- P1 from YYYY-MM-DD: "manual pdflatex" -> still present
- New: {patterns found for the first time}

{If first audit: "First audit -- no trend data."}
```

### Report Persistence

- Write to `docs/workflow-audits/YYYY-MM-DD.md`
- If same-day report exists, append sequence number: `YYYY-MM-DD-2.md`
- Directory created on first use (not by /init-project)

### Evidence Requirement

Every pattern MUST reference concrete evidence (session ID + tool call, or git commit hash). No speculative patterns.

### Implementation Phase

When user says "implement N" or "implement all P0":
1. Agent creates hook/agent/skill files
2. Merges into existing settings.json (never replaces)
3. Validates JSON syntax
4. Commits with descriptive message

---

## Degraded Mode

### Data Source Availability

| Data Source | Full | Degraded |
|------------|------|----------|
| Session `.jsonl` | yes | yes |
| `git log --since=7d` | yes | yes |
| `.claude/settings.json` hooks | yes | yes |
| `.claude/agents/` | yes | yes |
| `.claude/skills/` | yes | yes |
| `.pipeline-state.json` | yes | no |
| `docs/knowhow/` | yes | no |
| project memory | yes | no |
| `docs/workflow-audits/` history | yes | yes (if exists) |

### Agent Prompt Difference

Same `@workflow-auditor` agent, different context injection:

For degraded mode, skill adds to context:
```
Mode: degraded
Available automation primitives:
- Hooks (.claude/settings.json)
- Agents (.claude/agents/)
- Skills (.claude/skills/)

Do NOT recommend: pipeline-state hooks, knowhow archival,
exp-manager integration, or any labmate-specific features.
```

---

## Stop Hook Extension

Added to existing `stop-check-workflow` hook (not a new hook):

### Trigger Conditions

```bash
# Condition 1: session > 2 hours
# Estimate via current session .jsonl creation time
SESSION_DIR="$HOME/.claude/projects/${ENCODED}"
CURRENT_SESSION=$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | head -1)
if [ -n "$CURRENT_SESSION" ]; then
  SESSION_AGE_HOURS=$(( ($(date +%s) - $(stat -f%m "$CURRENT_SESSION")) / 3600 ))
fi

# Condition 2: commits > 10 in session period
COMMIT_COUNT=$(git log --oneline --since="${SESSION_AGE_HOURS} hours ago" | wc -l)

# Both conditions + 7-day cooldown
if [ "$SESSION_AGE_HOURS" -ge 2 ] && [ "$COMMIT_COUNT" -ge 10 ]; then
  if [ "$(should_remind 'workflow_audit' 168)" = "yes" ]; then
    echo "Productive session (${SESSION_AGE_HOURS}h, ${COMMIT_COUNT} commits). Consider /workflow-audit."
    mark_reminded "workflow_audit"
  fi
fi
```

### Constraints

- Reuses existing `hook-utils` (`should_remind` / `mark_reminded`)
- 7-day cooldown via `.labmate-hook-state.json`
- Only fires in labmate-initialized projects (`.pipeline-state.json` guard)
- Non-labmate projects never see this nudge (hook is in labmate plugin)

---

## File Layout

### New files

| File | Purpose |
|------|---------|
| `agents/workflow-auditor.md` | Agent: pattern analysis + report + implementation |
| `skills/workflow-audit/SKILL.md` | Skill: data collection + dispatch |
| `docs/specs/2026-04-15-workflow-audit-design.md` | This spec |

### Modified files

| File | Change |
|------|--------|
| `hooks/stop-check-workflow` | Append audit nudge logic |
| `.claude-plugin/plugin.json` | Add `workflow-auditor.md` to agents array |
| `CLAUDE.md` | Add skill/agent entries |

### Not modified

- `hooks/hooks.json` — no new hook registration needed
- `plugin.json` skills field — directory convention auto-discovers
- `init-project` — does not pre-create `docs/workflow-audits/`

---

## Relationship to Existing Components

| Component | Relationship |
|-----------|-------------|
| `/retro` (superpowers) | Retro = code quality + work patterns. Audit = automation opportunities. Complementary, not chained. |
| `/daily-summary` | Summary = what was done. Audit = how it was done and what to automate. |
| `/commit-changelog` | Changelog documents changes. Audit uses commit patterns as input signal. |
| `/update-knowhow` | Knowhow = environment knowledge. Audit may recommend knowhow entries become hooks. |
| `@project-advisor` | Advisor = project history navigation. Auditor = workflow pattern detection. Different concern. |
