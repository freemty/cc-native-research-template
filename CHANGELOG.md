# Changelog

## Unreleased

## v0.7.0 (2026-03-30)

### 新增
- /update-knowhow skill: 环境知识归档（infrastructure, toolchain, debug-solutions, runbooks）
- post-knowhow-remind hook: 检测环境配置/debug 命令，提示归档（频率控制：5 分钟间隔，session 内最多 3 次）
- init-project: 新增 `docs/knowhow/` 4 个子目录创建
- CLAUDE.md 模板: 新增 Knowhow 索引 section

### 变更
- Plugin 组件数更新：9 → 10 skills, 8 → 9 hooks

## v0.6.0 (2026-03-26)

### 新增
- arxiv-detect hook: UserPromptSubmit 自动检测 arxiv 链接，提示使用 /read-paper
- 9 篇 paper deep-dive notes (cc-architecture, cc-tips, evals, gstack, harness-eng, long-running, notebooklm, skills-design, superpowers)
- cc-advisor skill design spec and publication plan
- CLAUDE.md: Experiment rules (cleanup isolation, smoke test, built-in resume)

### 修复
- post-commit-changelog hook 措辞加强为 IMPORTANT/MUST，防止 Claude 忽略 CHANGELOG 提醒

## v0.4.0 — LabMate (2026-03-19)

### Breaking Changes
- Renamed from `cc-native-research-template` to `labmate`
- README.md is now English (Chinese moved to README_ZH.md)

### Changed
- All references updated (plugin.json, package.json, CLAUDE.md, hooks, gitignore-rules)
- README rewritten with pain-point-first copy, humanized language
- SessionStart hook context tags renamed to `<labmate>`
- GitHub description: "Research Harness for Claude Code. Keep your agent grounded in context, not lost in vibe coding."

## v0.3.0 — Plugin Architecture (2026-03-18)

### Breaking Changes
- Restructured as CC Plugin (no longer a GitHub template)
- agents/, skills/, hooks/ moved to plugin top-level
- scripts/, viewer/ moved to references/ (copied by /init-project)

### Added
- .claude-plugin/plugin.json — plugin manifest
- hooks/hooks.json — hook definitions with ${CLAUDE_PLUGIN_ROOT} paths
- /init-project skill — one-command project initialization
- references/claude-md-template.md — CLAUDE.md generation template
- references/gitignore-rules.md — .gitignore rules for research projects

### Removed
- bootstrap.sh — replaced by /init-project skill

## [0.2.5] - 2026-03-18

### Added
- CLAUDE.md: 6 Research Principles (measure first, baseline sacred, ablation-driven, etc.)
- CLAUDE.md: Session Startup guide (what to read first per task type)
- docs/papers/landscape.md: living literature map maintained by @domain-expert
- docs/plans/TODO-harness-v2.md: gap analysis against research_harness_bootstrap_prompt
- /commit-changelog skill (internalized from global)

### Changed
- All 7 agents deepened with detailed prompts (total: 89-269w → 453-1609w)
- All 7 skills standardized per CC official spec
- All 7 agents standardized per CC subagent spec
- Hooks: jq-based JSON stdin parsing per CC hook protocol

### Removed
- slides-guard hook (no longer needed after visual references internalized)

## [0.2.0] - 2026-03-18

### Added
- template-presenter agent: template meta-tasks (overview slides, architecture docs, onboarding)
- /present-template skill: orchestrates template-presenter → slides-maker
- /weekly-progress skill + Friday hook reminder
- slides/references/frontend-slides.md + agent-slides.md (internalized visual specs)
- slides/project-overview.html: 10-page project overview presentation

### Changed
- slides-maker: dual mode (analysis + presentation), background:true, reads slides/references/
- project-advisor: description narrowed to research content (not template infra)
- analyze-experiment: updated subagent dispatch with @agent-name pattern

## [0.1.0] - 2026-03-18

### Added
- 6 agent definitions with least-privilege boundaries (project-advisor, cc-advisor, domain-expert, exp-manager, slides-maker, viz-frontend)
- 4 repo-local skills (project-skill skeleton, update-project-skill, new-experiment, analyze-experiment)
- 6 hook scripts in 3 layers (pre-compact-remind, stop-check-workflow, post-commit-changelog, slides-guard, brainstorm-remind, worktree-suggest)
- exp/lib/ shared analysis utilities (analyze_common, plot_utils) with 5 tests
- exp/exp00a/ example experiment with full structure (README, config, run.py, analyze.py)
- prompts/ versioned prompt loader with example component and 4 tests
- scripts/ experiment lifecycle (launch_exp.py, monitor_exp.sh, download_results.sh)
- viewer/ Flask analysis frontend skeleton with 2 tests
- bootstrap.sh interactive first-run personalization (4 questions, idempotent)
- CLAUDE.md thin route hub (<80 lines)
- Pipeline state machine with .pipeline-state.json
- Design spec and implementation plan in docs/specs/

### Changed
- bootstrap.sh: rewritten to be truly idempotent — stores config in .pipeline-state.json, re-bootstrap replaces current values (not placeholders)
- Bootstrapped template with own identity (cc-native-research-template)
