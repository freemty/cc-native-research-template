---
name: survey-literature
description: >
  Systematic literature survey for a research topic. Triggers on "survey the
  literature", "文献调研", "find papers about", "what's been done on",
  "literature review", "related work for".
disable-model-invocation: true
---

# Survey Literature

Systematically search and synthesize relevant literature for a research question. Outputs a structured survey document.

## Instructions

When this skill is invoked with `<topic>`:

### Step 1: Gather research context

Read the following files if they exist (skip silently if not found):
- `docs/papers/landscape.md` — user's existing literature map
- `exp/summary.md` — user's experiment history

### Step 2: Delegate to @domain-expert

Invoke `@domain-expert` with this prompt:

> **Mode 5: Literature Survey**
>
> Research question: {topic}
>
> Research context:
> - Literature landscape: {landscape.md content or "not available"}
> - Experiment history: {exp/summary.md content or "not available"}
>
> Execute your full survey pipeline: Scope → Search → Filter → Synthesize → Output → Update landscape.md.
> Write the survey to `docs/papers/{slugified-topic}-survey.md`.

### Step 3: Report results

After domain-expert completes, tell the user:
- Path to the generated survey file
- Number of papers found
- Any coverage limitations encountered
- Suggest: "Use `/read-paper` to deep-dive any paper from this survey."
