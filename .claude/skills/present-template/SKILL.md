---
name: present-template
description: "Use when creating project overview slides, architecture documentation, onboarding guides, or demo scripts for this template."
disable-model-invocation: true
---

# Present Template

Generates presentations or documentation about the template itself.

## Instructions

When this skill is invoked:

1. **Ask user what to generate** (one question):
   - "project-overview" → slides introducing template architecture
   - "onboarding" → 5-minute quickstart guide document
   - "demo-script" → live demo step-by-step script
   - Or a custom topic

2. **Delegate to `@template-presenter`** for content:

   Tell it:
   > Generate a detailed content outline for: {topic}
   > Include slide titles, bullet points, and specific data from actual files.
   > Key numbers: how many agents, skills, hooks, experiments.

3. **If slides requested:** delegate to `@slides-maker`:

   Tell it:
   > mode: presentation
   > topic: {topic}
   > Content outline: {paste template-presenter output}

   slides-maker runs in background. Tell user it's generating.

4. **If docs requested:** write the markdown output to `docs/{topic}.md`.

5. **Report** what was generated and the output path.
