---
description: "Regenerate project knowledge skill from current codebase state"
---

# Update Project Skill

Refreshes `.claude/skills/project-skill/SKILL.md` by scanning the entire project.

## Instructions

When this skill is invoked:

1. **Spawn an Opus subagent** via the Agent tool (read-only) with this prompt:

   > You are a project knowledge generator. Scan the following and produce an updated SKILL.md:
   >
   > - Code structure: key files, modules, entry points (use Glob + Read)
   > - `exp/`: all experiments, their status, key findings (read each README.md)
   > - `docs/papers/`: domain knowledge inventory (list all papers)
   > - `prompts/`: current versions and evolution (read CHANGELOGs)
   > - Previous `.claude/skills/project-skill/SKILL.md` (preserve user-added custom sections)
   > - Recent git log: `git log --oneline -20` (changes since last update)
   >
   > Output format: complete SKILL.md content with these sections:
   > - Project Overview & Current State
   > - Architecture (code structure, data flow)
   > - Experiment History Table (exp → status → key finding)
   > - Key Pitfalls & Lessons Learned (APPEND-ONLY — keep all existing entries, add new ones)
   > - Active Prompt Versions & Trade-offs
   > - Quick Reference (commands, paths, env vars)
   >
   > CRITICAL: Never remove entries from "Key Pitfalls & Lessons Learned". Never downgrade experiment status ("Done" stays "Done"). Preserve any user-added custom sections unchanged.

2. **Show diff** between current and proposed SKILL.md to user for approval.

3. **On approval:** Write the updated SKILL.md.

4. **Append CHANGELOG entry** to `.claude/skills/project-skill/CHANGELOG.md` with date and summary of changes.

5. **Update pipeline state:** Set `skill_updated_at` in `.pipeline-state.json` to current Unix timestamp:
   ```python
   import json, time
   state = json.load(open('.pipeline-state.json'))
   state['skill_updated_at'] = int(time.time())
   json.dump(state, open('.pipeline-state.json', 'w'), indent=2)
   ```

6. **Prompt:** "Also run /commit-changelog? (Y/n)"
