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

## Skills

All plugin skills use the `labmate:` prefix.

| Skill | Trigger |
|-------|---------|
| /labmate:update-project-skill | After major findings or when stale |
| /labmate:commit-changelog | Commit with CHANGELOG |
| /labmate:update-knowhow | Archive environment knowledge |

## Conventions

- **CHANGELOG rule:** all significant changes must have CHANGELOG entries
- **Worktree rule:** destructive or exploratory changes use git worktree
