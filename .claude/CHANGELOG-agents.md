# Agent Definitions Changelog

## [0.2.0] - 2026-03-18

### Added
- template-presenter: Sonnet-powered template meta-presenter (read-only) — generates content outlines for project overview, onboarding, demo scripts

### Changed
- slides-maker: upgraded to dual-mode (analysis + presentation), now references slides/references/ for visual spec
- project-advisor: narrowed description to focus on research content (experiments, findings), not template infrastructure

### Removed
- slides-guard hook deleted (no longer needed with internalized visual references)

## [0.1.0] - 2026-03-18

### Added
- project-advisor: Opus-powered project knowledge advisor (read-only)
- cc-advisor: Sonnet-powered CC workflow best practices advisor (read-only)
- domain-expert: Opus-powered domain research interpreter (read-only)
- exp-manager: Sonnet-powered experiment monitor with retry capability
- slides-maker: Sonnet-powered analysis slides generator (writes to slides/)
- viz-frontend: Sonnet-powered visualization frontend builder (writes to viewer/)
