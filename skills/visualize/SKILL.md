---
name: visualize
description: "Build results dashboard, comparison view, or project overview. Use when user wants to visualize experiment results or generate project presentations."
disable-model-invocation: true
---

# Visualize

Build a Flask + HTML dashboard for experiment results via @viz-frontend.

## Instructions

When this skill is invoked with optional `<argument>`:

### Step 1: Determine target

- If argument is `compare` → comparison mode (cross-experiment)
- If argument is an exp ID (e.g., `exp01a`) → that experiment
- If no argument → read `.pipeline-state.json` for `current_exp`
- If `current_exp` is null and no argument → ask user which experiment

### Step 2: Gather data

For single experiment:
- Read `exp/{exp_id}/results/summary.md` for quantitative results
- Read `exp/{exp_id}/README.md` for experiment context
- Check if `viewer/app.py` already exists (update vs create)

For compare mode:
- Read `exp/summary.md` for cross-experiment overview

### Step 3: Delegate to @viz-frontend

For single experiment:
> Build a results dashboard for experiment {exp_id}.
> Results data: {summary.md content}
> Experiment context: {README.md content}
> Viewer directory: `viewer/`
> If `viewer/app.py` exists, add/update the view for this experiment. Otherwise create from scratch.

For compare mode:
> Build a cross-experiment comparison dashboard.
> Summary data: {exp/summary.md content}
> Viewer directory: `viewer/`

### Step 4: Report

Tell user: "Dashboard ready. Run `python viewer/app.py` and open http://localhost:5001"
