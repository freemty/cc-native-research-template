# update-knowhow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add hook + skill combo that detects environment knowledge during work and archives it into structured `docs/knowhow/` directories with CLAUDE.md indexing.

**Architecture:** PostToolUse(Bash) hook detects env-related commands and prompts user to archive. `/update-knowhow` skill handles classification, dedup, write, and CLAUDE.md index sync. `init-project` creates the knowhow directory skeleton.

**Tech Stack:** Bash (hook), Markdown (skill SKILL.md), JSON (hooks.json edit)

---

## File Structure

| Action | Path | Responsibility |
|--------|------|---------------|
| Create | `skills/update-knowhow/SKILL.md` | Skill: classify, dedup, write, index |
| Create | `hooks/post-knowhow-remind` | Hook: detect env commands, prompt user |
| Edit | `hooks/hooks.json` | Register new hook |
| Edit | `skills/init-project/SKILL.md` | Add knowhow dir creation to Step 3 |
| Edit | `references/claude-md-template.md` | Add knowhow index section |

---

### Task 1: Create `/update-knowhow` Skill

**Files:**
- Create: `skills/update-knowhow/SKILL.md`

- [ ] **Step 1: Create the skill file**

Write `skills/update-knowhow/SKILL.md` with the following content:

```markdown
---
name: update-knowhow
description: "Use when user says '记下来', '归档', 'save this', or after a knowhow-hint prompt. Archives environment knowledge into docs/knowhow/."
disable-model-invocation: true
---

# Update Knowhow

Archive environment knowledge (infrastructure issues, toolchain tips, debug solutions, runbooks) into structured docs.

## Pre-check

1. Verify `docs/knowhow/` exists with 4 subdirectories:
   - `docs/knowhow/infrastructure/`
   - `docs/knowhow/toolchain/`
   - `docs/knowhow/debug-solutions/`
   - `docs/knowhow/runbooks/`

   If missing, tell user: "docs/knowhow/ 不存在，请先运行 /init-project" and stop.

## Execution

### Step 1: Extract

From the current conversation context, extract:
- **Problem**: What went wrong or what needed to be set up
- **Cause**: Root cause (if debug) or context (if setup)
- **Solution**: Commands, config changes, or steps that resolved it
- **Related commands**: Exact shell commands used

### Step 2: Classify

Determine which category this belongs to:

| Category | Directory | When |
|----------|-----------|------|
| Infrastructure | `docs/knowhow/infrastructure/` | Servers, SSH, networking, disk, GPU, cloud platforms |
| Toolchain | `docs/knowhow/toolchain/` | CLI tools, docker, conda/pip, frameworks, build systems |
| Debug Solutions | `docs/knowhow/debug-solutions/` | Error investigation paths + final fix |
| Runbooks | `docs/knowhow/runbooks/` | Step-by-step procedures ("to do X on Y, first Z") |

If unclear, ask user once: "这条记录属于哪个类别？infrastructure / toolchain / debug-solutions / runbooks"

### Step 3: Dedup Check

1. Use Glob to list all `*.md` files in the target directory
2. Use Grep to search for keywords from the extracted problem/solution across those files
3. If a relevant file exists → **update that file** (append new section or revise existing content)
4. If no match → **create new file** with kebab-case slug name (e.g., `docker-build-cache.md`)

### Step 4: Write

**For new files**, use this template:

```
# {Title}

> {One-line summary}

## Problem
{What went wrong or needed setup}

## Cause
{Root cause or context}

## Solution
{Steps, commands, config changes}

## Commands
\`\`\`bash
{Exact commands used}
\`\`\`

## Notes
- Date: {YYYY-MM-DD}
- Environment: {server/platform if relevant}
```

**For existing files**, append a new `## ` section with date, or update the relevant section if the content overlaps.

### Step 5: Index Sync

1. Read `CLAUDE.md`
2. Search for `docs/knowhow/` in its content
3. If NOT found, append at the end:

```
## Knowhow
- `docs/knowhow/infrastructure/` — Servers, networking, disk, GPU issues
- `docs/knowhow/toolchain/` — CLI tools, docker, conda/pip, framework tips
- `docs/knowhow/debug-solutions/` — Error investigation paths and fixes
- `docs/knowhow/runbooks/` — Step-by-step operational procedures
```

4. If already found, skip (do not duplicate)

### Step 6: Confirm

Output a one-line summary:
> 已归档到 `docs/knowhow/{category}/{slug}.md` — {one-line description}

Or if updated:
> 已更新 `docs/knowhow/{category}/{slug}.md` — {what was added}

## Constraints

- NEVER create files outside `docs/knowhow/`
- NEVER create new subdirectories beyond the 4 fixed categories
- Prefer updating existing files over creating new ones
- Do NOT call subagents — all info is in current conversation context
- CLAUDE.md index is directory-level (4 entries), not per-file
```

- [ ] **Step 2: Verify skill is discoverable**

Run: `ls skills/update-knowhow/SKILL.md`
Expected: file exists

- [ ] **Step 3: Commit**

```bash
git add skills/update-knowhow/SKILL.md
git commit -m "feat: add /update-knowhow skill for environment knowledge archival"
```

---

### Task 2: Create `post-knowhow-remind` Hook

**Files:**
- Create: `hooks/post-knowhow-remind`

- [ ] **Step 1: Create the hook script**

Write `hooks/post-knowhow-remind` with the following content:

```bash
#!/bin/bash
# Hook: PostToolUse(Bash) — remind to archive environment knowledge
# Detects env-related commands (install, docker, ssh, debug errors) and suggests /update-knowhow

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/hook-utils"

INPUT=$(cat)

# Extract command and output
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
if [ -z "$COMMAND" ]; then exit 0; fi

OUTPUT=$(echo "$INPUT" | jq -r '.tool_output.stdout // empty' 2>/dev/null)
STDERR=$(echo "$INPUT" | jq -r '.tool_output.stderr // empty' 2>/dev/null)

# Skip trivial commands
if echo "$COMMAND" | grep -qE '^(ls|cat|head|tail|pwd|cd|echo|git (log|status|diff|branch|show)|wc|file|which|type) '; then
  exit 0
fi

MATCHED=0

# Signal 1: environment config commands
if echo "$COMMAND" | grep -qiE '(apt(-get)? install|pip install|conda install|docker (build|run|pull|push|compose)|ssh |scp |rsync |mount |umount |systemctl |nvidia-smi|chmod |chown |curl -[oOL]|wget |export [A-Z]|source.*activate|nvm |pyenv |brew install)'; then
  MATCHED=1
fi

# Signal 2: error keywords in output (suggests debug just happened)
if [ "$MATCHED" -eq 0 ]; then
  COMBINED="$OUTPUT $STDERR"
  if echo "$COMBINED" | grep -qiE '(error|failed|permission denied|not found|no such file|connection refused|timeout|CUDA|OOM|out of memory|segfault|killed|errno)'; then
    MATCHED=1
  fi
fi

if [ "$MATCHED" -eq 0 ]; then exit 0; fi

# Frequency control: max 3 per session, 5 min apart
if [ "$(should_remind knowhow_remind 0.083)" != "yes" ]; then exit 0; fi

# Session count: track in state file, cap at 3
STATE_FILE=".labmate-hook-state.json"
COUNT=$(python3 -c "
import json
try:
    s = json.load(open('$STATE_FILE'))
    print(s.get('knowhow_session_count', 0))
except:
    print(0)
" 2>/dev/null || echo "0")

if [ "$COUNT" -ge 3 ]; then exit 0; fi

# Increment count and mark reminded
python3 -c "
import json
from datetime import datetime
f = '$STATE_FILE'
try:
    s = json.load(open(f))
except:
    s = {}
s['knowhow_session_count'] = s.get('knowhow_session_count', 0) + 1
s['knowhow_remind'] = datetime.now().isoformat()
json.dump(s, open(f, 'w'), indent=2)
" 2>/dev/null

cat << 'HINT'
<knowhow-hint>
刚才的操作看起来包含值得记录的环境知识。
要归档吗？说"记下来"或 /update-knowhow
</knowhow-hint>
HINT
```

- [ ] **Step 2: Make hook executable**

Run: `chmod +x hooks/post-knowhow-remind`
Expected: no output, exit 0

- [ ] **Step 3: Commit**

```bash
git add hooks/post-knowhow-remind
git commit -m "feat: add post-knowhow-remind hook for env knowledge detection"
```

---

### Task 3: Register Hook in hooks.json

**Files:**
- Modify: `hooks/hooks.json:27-44` (PostToolUse array)

- [ ] **Step 1: Add hook entry to PostToolUse array**

In `hooks/hooks.json`, add a new entry to the `PostToolUse` array, after the existing `post-analyze-remind` entry (line 35). The new entry:

```json
{
  "matcher": "Bash",
  "hooks": [{"type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" post-knowhow-remind", "async": false}]
}
```

The PostToolUse array should now have 5 entries (was 4): post-commit-changelog, post-analyze-remind, **post-knowhow-remind**, post-new-experiment-monitor, post-read-paper-survey.

- [ ] **Step 2: Validate JSON**

Run: `python3 -c "import json; json.load(open('hooks/hooks.json')); print('valid')"`
Expected: `valid`

- [ ] **Step 3: Commit**

```bash
git add hooks/hooks.json
git commit -m "feat: register post-knowhow-remind hook"
```

---

### Task 4: Update init-project Skill

**Files:**
- Modify: `skills/init-project/SKILL.md:59-108` (Step 3 directory creation section)

- [ ] **Step 1: Add knowhow directory creation**

In `skills/init-project/SKILL.md`, after section `#### 3.2 文档目录` (which creates `docs/papers/`, `docs/specs/`, etc.), add a new section `#### 3.3 Knowhow 目录`:

```markdown
#### 3.3 Knowhow 目录

以下目录若不存在则创建并写入 `.gitkeep`：
- `docs/knowhow/infrastructure/`
- `docs/knowhow/toolchain/`
- `docs/knowhow/debug-solutions/`
- `docs/knowhow/runbooks/`
```

Renumber subsequent sections: old 3.3 → 3.4, old 3.4 → 3.5, old 3.5 → 3.6, old 3.6 → 3.7, old 3.7 → 3.8.

- [ ] **Step 2: Verify section numbering is consistent**

Read the file and confirm all `#### 3.x` sections are sequential from 3.1 to 3.8.

- [ ] **Step 3: Commit**

```bash
git add skills/init-project/SKILL.md
git commit -m "feat: add knowhow directory creation to init-project"
```

---

### Task 5: Update CLAUDE.md Template

**Files:**
- Modify: `references/claude-md-template.md:22-26` (after Project knowledge section)

- [ ] **Step 1: Add Knowhow section to template**

In `references/claude-md-template.md`, after the `## Project knowledge` section (which ends around line 26) and before `## Agents`, add:

```markdown
## Knowhow

- `docs/knowhow/infrastructure/` — Servers, networking, disk, GPU issues
- `docs/knowhow/toolchain/` — CLI tools, docker, conda/pip, framework tips
- `docs/knowhow/debug-solutions/` — Error investigation paths and fixes
- `docs/knowhow/runbooks/` — Step-by-step operational procedures
```

- [ ] **Step 2: Update LabMate's own CLAUDE.md**

In the project's own `CLAUDE.md`, add the `/update-knowhow` command to the Quick commands table:

```markdown
| `/update-knowhow` | Archive environment knowledge to docs/knowhow/ |
```

And add the skill to the Skills table:

```markdown
| update-knowhow | Archive env knowledge (infra, toolchain, debug, runbooks) |
```

- [ ] **Step 3: Commit**

```bash
git add references/claude-md-template.md CLAUDE.md
git commit -m "feat: add knowhow section to CLAUDE.md template and project docs"
```

---

### Task 6: Integration Verification

- [ ] **Step 1: Verify all files exist**

Run:
```bash
ls -la skills/update-knowhow/SKILL.md hooks/post-knowhow-remind hooks/hooks.json
```
Expected: all three files exist, hook is executable (`-rwxr-xr-x`)

- [ ] **Step 2: Validate hooks.json structure**

Run:
```bash
python3 -c "
import json
h = json.load(open('hooks/hooks.json'))
post = h['hooks']['PostToolUse']
names = [e['hooks'][0]['command'] for e in post]
assert any('post-knowhow-remind' in n for n in names), 'hook not registered'
print(f'PostToolUse hooks: {len(post)} entries')
print('post-knowhow-remind: registered')
"
```
Expected: `PostToolUse hooks: 5 entries` and `post-knowhow-remind: registered`

- [ ] **Step 3: Verify skill frontmatter**

Run:
```bash
head -5 skills/update-knowhow/SKILL.md
```
Expected: YAML frontmatter with `name: update-knowhow` and `disable-model-invocation: true`

- [ ] **Step 4: Verify init-project has knowhow section**

Run:
```bash
grep -c "knowhow" skills/init-project/SKILL.md
```
Expected: at least 5 matches (directory names + section header)

- [ ] **Step 5: Verify template has knowhow section**

Run:
```bash
grep -c "knowhow" references/claude-md-template.md
```
Expected: at least 4 matches (the 4 directory entries)

- [ ] **Step 6: Final commit if any remaining changes**

```bash
git status
```

If clean, done. If any unstaged changes remain, stage and commit.
