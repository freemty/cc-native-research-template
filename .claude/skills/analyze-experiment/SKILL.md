---
description: "Analyze results from current experiment — runs analysis, domain interpretation, and slides"
---

# Analyze Experiment

Full analysis pipeline for the current experiment. MUST run in main context (spawns subagents).

## Instructions

When this skill is invoked:

1. **Read pipeline state:**
   ```python
   import json
   state = json.load(open('.pipeline-state.json'))
   current_exp = state['current_exp']
   ```
   If `current_exp` is null, ask user which experiment to analyze.

2. **Run analysis script:**
   ```bash
   python exp/{current_exp}/analyze.py
   ```
   This generates `exp/{current_exp}/results/summary.md`.

3. **Spawn domain-expert subagent** (Agent tool, model: opus, read-only):

   Prompt:
   > You are a domain expert in {RESEARCH_DOMAIN}. Analyze this experiment:
   >
   > Read: `exp/{current_exp}/results/summary.md` for quantitative results.
   > Read: `exp/{current_exp}/README.md` for experiment context.
   > Scan: `docs/papers/` for relevant domain papers.
   >
   > Provide a ~500 word domain interpretation:
   > - How do results compare to expectations from literature?
   > - What do the numbers mean in domain context?
   > - What follow-up experiments would you suggest?
   > - Cite specific papers from docs/papers/ (by filename).
   >
   > CRITICAL: Only cite papers that actually exist in docs/papers/. Never invent citations.

4. **Merge interpretation** into `exp/{current_exp}/README.md` under the "## Findings" section.

5. **Update `exp/summary.md`** cross-experiment table: update the row for current_exp with status "Analyzed" and key finding summary (one line).

6. **Spawn slides-maker subagent** (Agent tool, model: sonnet, write to slides/):

   Prompt:
   > Generate analysis slides for experiment {current_exp}.
   >
   > Read: `exp/{current_exp}/results/summary.md` for data.
   > Read: `exp/{current_exp}/README.md` for context and domain interpretation.
   > Read existing files in `slides/` for style reference (if any exist).
   >
   > Use /frontend-slides to create: `slides/{current_exp}-analysis.html`
   >
   > Include slides for:
   > - Experiment overview and motivation
   > - Key metrics and results table
   > - Domain interpretation highlights
   > - Next steps and follow-up experiments

7. **Advance pipeline state:**
   - Set `stage` to "analysis" in `.pipeline-state.json`

8. **Print summary** of generated artifacts:
   - `exp/{current_exp}/results/summary.md` — quantitative analysis
   - `exp/{current_exp}/README.md` — updated with findings
   - `slides/{current_exp}-analysis.html` — presentation
