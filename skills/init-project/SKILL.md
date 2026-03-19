---
name: init-project
description: "Use when setting up a new research project — initializes directory skeleton, CLAUDE.md, .gitignore, pipeline state, and reference scripts in the user's existing project."
tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# Init Project

Initialize a research project skeleton in the user's existing project. **Idempotent**: safe to run multiple times. Existing files/directories are skipped, never overwritten or deleted.

**Language**: Default to English. If user responds in Chinese, switch to Chinese for the rest of the session.

---

## Execution flow

### Step 1: Detect existing structure

1. Run `git status --porcelain` to check for uncommitted changes:
   - If dirty, warn: "Uncommitted changes detected. Files will be written on top of current state. Continue? (Y/n)"
   - If user says n, stop.

2. Check which of these exist: `CLAUDE.md`, `exp/`, `docs/`, `.pipeline-state.json`, `.gitignore`

3. Print detection summary, e.g.:
   > Detected: CLAUDE.md missing | exp/ exists | docs/ missing | .pipeline-state.json missing | .gitignore exists

---

### Step 1.5: Fuzzy match existing content

Before creating new files, scan for existing content that serves the same purpose but in a different format or location.

**What to scan for:**

| Target | Look for |
|--------|----------|
| `exp/summary.md` | Markdown tables in README or other .md files with columns like Status/Finding/Result. Grep for `experiment`, `trial`, `run`, `baseline` near table syntax. |
| `docs/papers/` | Existing dirs like `docs/notes/`, `docs/references/`, `references/`, `papers/`, `literature/` |
| `docs/papers/landscape.md` | Any .md file with dense occurrences of `arxiv`, `paper`, `doi`, `citation`, or URL patterns to academic sites |
| `exp/` | Existing dirs like `experiments/`, `exps/`, `runs/`, `trials/` |

**How to scan:** Use Grep and Glob to quickly check. Don't read every file — just check filenames and grep for key patterns.

**When a match is found, ask the user:**

```
Found existing content that may overlap:
  → README.md lines 45-62: markdown table with experiment records

  [migrate] Extract and convert to exp/summary.md format
  [skip]    Create fresh exp/summary.md, keep README as-is
  [keep]    Don't create exp/summary.md

Choice:
```

If user picks **migrate**: parse the existing content, convert to labmate format, write to the target file. Do NOT delete or modify the original — user decides cleanup later.

If no matches found, proceed silently.

---

### Step 2: Collect project info

**Auto-detect everything. User only confirms or edits.**

1. Get `{project-name}` from `basename $(pwd)`
2. Set `{compute_env}` to `local` (default)
3. Scan project files (README, code, directory names, dependencies) to infer:
   - `{description}` — one-line project description
   - `{domain}` — research domain (e.g. NLP, computer vision, RL)
4. Present all at once for confirmation:

   > Auto-detected project info:
   > - Name: `{project-name}`
   > - Description: `{description}`
   > - Domain: `{domain}`
   > - Compute: `local`
   >
   > Edit any field, or press Enter to confirm all.

5. User can press Enter to accept, or type corrections (e.g. "description: xxx")

---

### Step 3: Create directory structure

**Principle: only create what doesn't exist. Skip and log existing items.**

#### 3.1 Experiment directory

- `exp/.gitkeep` — create dir if `exp/` doesn't exist
- `exp/summary.md` — if missing, write:

```markdown
# Experiment Summary

Cross-experiment flight recorder. One row per experiment.

| Exp ID | Motivation | Status | Key Finding |
|--------|-----------|--------|-------------|
```

#### 3.2 Documentation directories

Create if missing (with `.gitkeep`):
- `docs/papers/`
- `docs/specs/`
- `docs/weekly/`
- `docs/archive/`

Create `docs/papers/landscape.md` if missing:

```markdown
# Domain Literature Landscape

> Research domain: {domain}

## Key papers

(use @domain-expert to populate)

## Research gaps

(to be filled)
```

Replace `{domain}` with the value from Step 2.

#### 3.3 Other directories

- `slides/.gitkeep` — create if `slides/` doesn't exist

#### 3.4 Script files

**Plugin path**: derive plugin root from this SKILL.md's location.
- This SKILL.md is at `<plugin_root>/skills/init-project/SKILL.md`
- So `<plugin_root>` = two levels up from SKILL.md
- All reference files are in `<plugin_root>/references/`

Copy each file (skip if target exists):

| Target path | Source (relative to plugin root) |
|------------|--------------------------------|
| `scripts/launch_exp.py` | `references/launch_exp.py` |
| `scripts/monitor_exp.sh` | `references/monitor_exp.sh` |
| `scripts/download_results.sh` | `references/download_results.sh` |
| `viewer/app.py` | `references/viewer-app.py` |
| `viewer/static/index.html` | `references/viewer-static/index.html` |

Steps:
1. Read source file content from plugin references/
2. If target doesn't exist, Write it
3. Create parent directories with `mkdir -p` if needed

#### 3.5 Pipeline state

If `.pipeline-state.json` doesn't exist, write:

```json
{
  "project_name": "{project-name}",
  "description": "{description}",
  "domain": "{domain}",
  "compute_env": "{compute_env}",
  "current_exp": null,
  "stage": "dev",
  "skill_updated_at": null
}
```

Replace placeholders with Step 2 values.

#### 3.6 Project skill

If `.claude/skills/project-skill/SKILL.md` doesn't exist, create it:

```markdown
---
name: project-skill
description: "Use when advising on project architecture, experiment history, codebase navigation, or research findings."
user-invocable: false
---

# {project-name} — Project Knowledge

> {description}

## Project overview
(run /labmate:update-project-skill to populate)

## Experiment history
(none yet)

## Key findings
(none yet)
```

Replace `{project-name}` and `{description}` with Step 2 values. Ensure `.claude/skills/project-skill/` directory exists.

#### 3.7 CHANGELOG

If `CHANGELOG.md` doesn't exist, write:

```markdown
# Changelog

## Unreleased

- Project initialized with LabMate
```

---

### Step 4: Generate CLAUDE.md

**Read template from plugin:**

1. Read `<plugin_root>/references/claude-md-template.md`
2. Replace placeholders:
   - `{project-name}` → project name from Step 2
   - `{description}` → description from Step 2
   - `{date}` → today's date (YYYY-MM-DD)
   - `{current_exp}` → `null`

**Write rules:**

- **If `CLAUDE.md` doesn't exist**: write the full replaced template.

- **If `CLAUDE.md` exists**:
  1. Read existing CLAUDE.md
  2. Parse existing `## ` headings (h2 sections)
  3. Parse template `## ` headings
  4. Find template sections missing from existing file
  5. Append only missing sections to the end
  6. **Never delete or modify** existing sections
  7. If all sections exist, print "CLAUDE.md already has all template sections, skipping"

---

### Step 5: Append .gitignore rules

1. Read `<plugin_root>/references/gitignore-rules.md`
2. If `.gitignore` doesn't exist, create an empty one
3. Read existing `.gitignore` lines into a set
4. Process each line from gitignore-rules.md:
   - **Empty lines**: append (formatting)
   - **Comment lines** (`#`): always append (section markers)
   - **Rule lines**: strip whitespace, append only if not already present
5. Append all new content to `.gitignore` at once

---

### Step 6: Output summary

Print a structured summary:

```
=== init-project complete ===

Created:
  + exp/summary.md
  + docs/papers/landscape.md
  + .claude/skills/project-skill/SKILL.md
  + .pipeline-state.json
  + CLAUDE.md
  + CHANGELOG.md
  ...

Skipped (already exists):
  ~ exp/ (directory exists)
  ~ docs/papers/landscape.md (file exists)

Updated:
  ~ CLAUDE.md (appended 2 missing sections)
  ~ .gitignore (appended 8 rules)

=== Next steps ===

1. Review changes:
   git diff

2. Commit:
   git add -A && git commit -m "chore: init research skeleton with labmate"

3. Start first experiment:
   /labmate:new-experiment
```

Fill in created/skipped/updated based on actual results.

---

## Error handling

- Failed to read plugin references: print error, skip that file, continue
- Failed to write file (permissions): print error, skip, mark as `! write failed` in summary
- No step failure stops the overall flow. All errors collected and shown in summary.

---

## Idempotency guarantees

- Existing files: read-only, never overwritten
- `.gitignore` rules: deduplicated per line
- `CLAUDE.md` sections: only append missing ones
- Directories: skip if exists
- `.pipeline-state.json`: skip entirely if exists
