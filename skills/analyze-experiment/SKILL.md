---
name: analyze-experiment
description: >
  Use when an experiment has completed and results need analysis, interpretation,
  or presentation. Triggers on "analyze results", "分析实验", "interpret experiment",
  "what did exp find", "run analysis".
disable-model-invocation: true
---

# Analyze Experiment

Full analysis pipeline for the current experiment.

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
   PYTHONPATH=. python exp/{current_exp}/analyze.py
   ```
   This generates `exp/{current_exp}/results/summary.md`.

3. **Delegate to `@domain-expert`** for interpretation:

   Tell it:
   > Analyze experiment {current_exp}:
   > Read `exp/{current_exp}/results/summary.md` for quantitative results.
   > Read `exp/{current_exp}/README.md` for experiment context.
   > Scan `docs/papers/` for relevant domain papers.
   > Provide ~500 word domain interpretation with paper citations.

   domain-expert has `memory: project`, so it remembers papers from previous sessions.

4. **Merge interpretation** into `exp/{current_exp}/README.md` under the "## Findings" section.

5. **Update `exp/summary.md`** cross-experiment table: update the row for current_exp with status "Analyzed" and key finding summary (one line).

6. **Delegate to `@slides-maker`** for presentation:

   Tell it:
   > mode: analysis
   > exp_id: {current_exp}
   > Generate: slides/{current_exp}-analysis.html

   slides-maker has `background: true`, so it runs in the background. Tell user: "slides-maker is generating slides in the background. You'll be notified when done."

7. **Advance pipeline state:**
   - Set `stage` to "analysis" in `.pipeline-state.json`

8. **Print summary** of generated artifacts:
   - `exp/{current_exp}/results/summary.md` — quantitative analysis
   - `exp/{current_exp}/README.md` — updated with findings
   - `slides/{current_exp}-analysis.html` — presentation (generating in background)
