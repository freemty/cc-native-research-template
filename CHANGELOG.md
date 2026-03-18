# Changelog

## [0.3.0] - 2026-03-18

### Added
- 7 agents with detailed prompts (cc-advisor, project-advisor, domain-expert, exp-manager, slides-maker, viz-frontend, template-presenter)
- 7 skills (new-experiment, analyze-experiment, update-project-skill, present-template, weekly-progress, commit-changelog, project-skill)
- 5 hooks in 3 layers (pre-compact-remind, stop-check-workflow, post-commit-changelog, brainstorm-remind, worktree-suggest)
- Experiment infrastructure: exp/lib/, exp/exp00a/ template, prompts/ loader, scripts/, viewer/
- slides/references/ internalized visual specs (frontend-slides + agent-slides)
- docs/papers/landscape.md living literature map
- bootstrap.sh interactive personalization (4 questions, idempotent)
- CLAUDE.md with Research Principles + Session Startup guide
- Pipeline state machine with .pipeline-state.json
- 11 tests (exp/lib, prompts, viewer)
