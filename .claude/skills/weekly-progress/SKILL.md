---
name: weekly-progress
description: "Use when summarizing the week's work — gathers CHANGELOG entries, git log, and experiment status into docs/weekly/YYYY-WNN.md."
disable-model-invocation: true
---

# Weekly Progress

Summarize this week's work into `docs/weekly/YYYY-WNN.md`.

## Instructions

When this skill is invoked:

1. **Determine week range:**
   - Current ISO week number and date range (Monday–Sunday)
   - Check if `docs/weekly/YYYY-WNN.md` already exists (append mode if so)

2. **Gather data** from real files (never fabricate):

   a. **CHANGELOG.md** — entries since last weekly (or all if first)
   b. **git log** — `git log --oneline --since="last monday"` for commit history
   c. **exp/summary.md** — experiment status changes
   d. **exp/*/README.md** — any new findings sections populated
   e. **.pipeline-state.json** — current stage and experiment

3. **Write structured summary:**

   ```markdown
   # Weekly Progress — Week {NN} ({date_range})

   ## Overview
   One paragraph summarizing the week's main achievements and current state.

   ## Key Changes
   (from CHANGELOG.md + git log, grouped by type)

   ### Features
   - ...

   ### Fixes
   - ...

   ### Docs / Infra
   - ...

   ## Experiments
   (from exp/summary.md, only experiments with status changes this week)

   | Exp | Status | Change This Week |
   |-----|--------|-----------------|
   | ... | ... | ... |

   ## Next Week
   (inferred from pipeline state + any TODOs in exp READMEs)
   - ...
   ```

4. **Write to** `docs/weekly/YYYY-WNN.md`

5. **Prompt:** "Review the weekly summary, then run /commit-changelog? (Y/n)"
