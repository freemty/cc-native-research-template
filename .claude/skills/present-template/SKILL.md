---
description: "Generate template overview slides or documentation — orchestrates template-presenter and slides-maker agents"
---

# Present Template

Generates presentations or documentation about the template itself. Orchestrates two subagents: template-presenter (read-only, generates content) and slides-maker (writes slides).

## Instructions

When this skill is invoked:

1. **Ask user what to generate** (one question):
   - "project-overview" → slides introducing template architecture and workflow
   - "onboarding" → 5-minute quickstart guide document
   - "demo-script" → live demo step-by-step script
   - Or a custom topic

2. **Spawn template-presenter subagent** (Agent tool, model: sonnet, read-only):

   > You are the template meta-presenter. Generate a detailed content outline for: {topic}
   >
   > Read these files to gather real data:
   > - CLAUDE.md (route hub overview)
   > - docs/specs/*.md (design specifications)
   > - .claude/agents/*.md (all agent definitions)
   > - .claude/skills/*/SKILL.md (all skill definitions)
   > - .claude/hooks/*.sh (all hook scripts)
   > - .pipeline-state.json (current state)
   > - exp/summary.md (experiment history)
   >
   > Return a structured outline with:
   > - Slide titles (for slides) or section headers (for docs)
   > - Specific bullet points with real data from files
   > - File paths, agent names, config values — all from actual files
   > - Key numbers: how many agents, skills, hooks, experiments
   >
   > Format: {format based on output type}

3. **If slides requested:** Spawn slides-maker subagent (Agent tool, model: sonnet, write slides/):

   > mode: presentation
   > topic: {topic}
   >
   > Content outline from template-presenter:
   > {paste template-presenter output here}
   >
   > Read slides/references/frontend-slides.md for visual spec.
   > Check slides/ for existing style reference.
   > Generate: slides/{topic}.html
   >
   > IMPORTANT: Follow viewport fitting strictly. Single self-contained HTML file.

4. **If docs requested:** Write the template-presenter's markdown output to `docs/{topic}.md`.

5. **Report** what was generated and the output path.
