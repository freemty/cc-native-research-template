# Changelog

## v0.8.0 (2026-04-15)

### 新增
- /workflow-audit skill: 跨 session 工作流审计 meta-skill，分析 session transcript + git history，发现可自动化的重复模式
- @workflow-auditor agent (opus): 读取 `.jsonl` session 文件，5 类模式分类（Repetitive Sequence / Error-Prone / Missing Feedback / Underused Asset / Manual Compilation），生成 P0/P1/P2 优先级报告
- workflow-audit 报告持久化到 `docs/workflow-audits/YYYY-MM-DD.md`，支持趋势对比
- 降级模式: 非 labmate 项目也可使用 /workflow-audit（仅 git + sessions + .claude/ 数据源）
- Stop hook 增加审计提醒: session > 2h 且 commits > 10 时建议 /workflow-audit（7 天冷却）
- "implement N" 交互: 用户可直接从审计报告中选择自动化项目，agent 自动创建 hook/agent/skill

### 修复
- Session 目录路径编码: `sed 's|/|-|g'` 改为 `sed 's|[^A-Za-z0-9]|-|g'`（匹配 Claude Code 实际编码规则）

### 变更
- Plugin 组件数更新: 5 → 6 agents, 10 → 11 skills
- CLAUDE.md: 新增 workflow-audit 条目 + Knowhow section

## v0.9.0 (2026-04-21)

### 新增
- /todo skill: 轻量级任务追踪（add/done/list/clean），存储于 docs/TODO.md，首次创建自动索引到 CLAUDE.md
- /update-docs skill: 面向人的结构化文档创建与更新（design/guide/readme/changelog/custom），自动维护 CLAUDE.md 索引
- /update-docs: 无参数时从对话上下文自动推断文档类型，不再询问用户
- init-project: 支持 general/research 项目类型选择（默认 general）
- references/claude-md-template-general.md: 轻量 CLAUDE.md 模板（knowhow + project-skill + changelog）
- scripts/release.sh: 一键发版脚本（merge→main, push, sync marketplace, fix installed_plugins.json, clean cache）
- .github/workflows/sync-marketplace.yml: main push 自动同步 marketplace.json 版本
- docs/guides/releasing.md: 开发端发版流程指南
- docs/guides/installing.md: 用户端安装/更新指南

### 修复
- new-experiment: analyze.py 不再导入不存在的 exp.lib.analyze_common 模块，改为内联实现
- commit-changelog: `--since="last monday"` 改为 `--since="7 days ago"`（合法 git 语法）
- new-experiment: 删除 step 6 对不存在的 prompts/ 目录引用
- update-project-skill: "5-segment" 标签与实际 9 个 section 不符，已修正
- init-project/monitor: 统一 skill 命名空间为 `/labmate:` 前缀
- release.sh: gitCommitSha 现在从 marketplace repo 取（而非源码 repo），修复 plugin loader fallback 到旧版本的问题

### 变更
- 删除 /workflow-audit skill + @workflow-auditor agent + stop-check-workflow hook（功能已被全局 meta-audit skill 覆盖）
- Plugin 组件数: 6 → 5 agents, 11 → 12 skills, 9 → 8 hooks
- 全部 12 个 skill description 增加双语 trigger phrases，提升触发准确性
- init-project: Step 3 目录创建按类型分流，general 跳过 exp/scripts/viewer/slides/papers
- init-project: .pipeline-state.json 新增 `type` 字段
- references/claude-md-template.md → claude-md-template-research.md（改名）
- research 模板: 删除废弃 agent（@cc-advisor, @template-presenter）和 skill（present-template, weekly-progress）
- research 模板: 补充 commit-changelog, update-knowhow, visualize, monitor 到 Quick commands 和 Skills 表

## v0.7.1 (2026-04-02)

### 新增
- TODO.md integration: session-start hook 提醒 P0 数量/过期天数（24h 频率限制）
- stop-check hook: 检测 exp/plan/agent 变更但 TODO.md 未更新，提醒用户
- project-advisor: TODO.md 作为首要数据源，"what to try" 先查 P0 blocking items

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
