# NotebookLM 教授工作流: 从零构建完整课程

> Source: https://x.com/ihtesham2005/status/2035035410758619428
> Author: Ihtesham Ali (@ihtesham2005)
> Type: Practitioner report (Twitter thread), not peer-reviewed
> Date read: 2026-03-21
> Tags: NotebookLM, AI-assisted pedagogy, source-grounded generation, curriculum design, knowledge management

## Summary

汇总 NYU、Stanford、Case Western、Arizona State、Northeastern 等高校教授使用 Google NotebookLM 构建课程的七步工作流。核心卖点是 source-grounded generation — 所有输出可追溯到上传的原始材料，内联引用可点击验证。

## Seven-Step Workflow

```
Step 1: LOAD(reading_list + syllabus + past_exams + primary_sources) → notebook_per_unit
Step 2: PROMPT("curriculum map") → structured_roadmap[concept → introduce/deepen/challenge sources]
Step 3: PROMPT("day-by-day lesson plan") → session_plans[objective, concepts, example, question, time]
Step 4: GENERATE(study_guides + comprehension_questions + flashcards + practice_quizzes)
Step 5: GENERATE(audio_overview) → 10-15 min podcast-style pre-reading summary
Step 6: DEEP_RESEARCH(existing_sources + web_search) → cited_literature_review
Step 7: SHARE(notebook → Google Classroom) → students interact with same source base
```

## Key Technical Enablers

- 50 sources/notebook (free tier), 500K words/source, 1M token context window
- Multi-modal input: PDF, Google Docs, URL, YouTube, audio, OCR images
- Deep Research: autonomous web search to fill gaps in existing sources
- Google Classroom integration: one-click import, View Only sharing

## Claims & Evidence

| Claim | Evidence | Quality |
|-------|----------|---------|
| Professors at NYU, Stanford, Case Western using it | Indirect reference, no linked docs | Weak — "publicly documented" but no sources |
| "Biggest shift in academic research in 20 years" | Single anonymous quote | Anecdotal |
| Literature review time reduced 70% | Single Pitt researcher | Anecdotal — no baseline, no control |
| Walter Isaacson used it for Marie Curie research | Celebrity endorsement | Medium — verifiable but no methodology detail |
| "No hallucinated citations" | Product claim | Needs verification — source-grounded != zero hallucination |

## Assumptions & Limitations

1. **Source-grounded = faithful** — citation traceability != content accuracy; reasoning chains can still mislead
2. **Uploaded sources are complete** — system inherits biases/gaps in reading list without flagging
3. **Notebook-per-unit is correct partition** — cross-unit concept links and prerequisites hard to express
4. **AI study aids supplement rather than replace reading** — unverified; Case Western case suggests students use audio to avoid dense readings
5. **Institutional data governance allows Google + AI data flow** — many universities have strict policies

### Missing

- No A/B testing or quasi-experimental design comparing NotebookLM-assisted vs traditional
- No student learning outcome data (test scores, deep understanding, critical thinking)
- No prompt engineering analysis (only two template prompts given)
- No scale discussion (50 source / 500K word limits for large comprehensive courses)
- No failure cases

## Bridge Analysis (vs LabMate)

### Architectural Isomorphism

| Pattern | NotebookLM | LabMate |
|---------|-----------|---------|
| Knowledge partition | 1 notebook = 1 teaching unit | 1 `exp/` dir = 1 experiment |
| Source-grounding | Product-level engine, inline clickable citations | Prompt-level Hard Rules in domain-expert |
| Multi-output derivation | 5 outputs from same sources (map, plan, materials, audio, review) | 3 outputs (analysis, slides, dashboard) |
| Gap-filling search | Deep Research (autonomous web search) | `/survey-literature` (domain-expert Mode 5) |
| Collaboration | Google Classroom View Only sharing | Git-native (no dedicated read-only mode) |

### LabMate's Key Advantage

NotebookLM has no `landscape.md` equivalent — each notebook is an isolated knowledge island with no cross-notebook evolution map. LabMate's three-layer literature system (depth + breadth + consumption) with persistent `landscape.md` + `exp/summary.md` + agent memory provides cross-session knowledge accumulation.

### Borrowable Ideas

1. **Structured citation links** — format domain-expert paper references as `[short-name](docs/papers/short-name.md)` markdown links
2. **Multi-modal derivation pattern** — strengthen "one ingestion, multiple derivations" pipeline
3. **Structured briefing** — generate experiment briefing text (analogous to Audio Overview)

### Triangle with gstack

| Tool | Optimization target | Knowledge management |
|------|---------------------|---------------------|
| gstack | Code output speed | `/retro` only, no persistence |
| NotebookLM | Course/literature digestion | Notebook-level, no cross-notebook evolution |
| LabMate | Research cognition accumulation | Three-layer literature + experiment history + cross-session memory |
