---
name: monitor
description: >
  Check experiment status and diagnose failures via exp-manager. Triggers on
  "check status", "看看实验", "how's the run", "any failures", "is it done",
  "monitor experiment", "experiment status".
disable-model-invocation: true
---

# Monitor

One-command experiment status check via @exp-manager.

## Instructions

When this skill is invoked with optional `<exp_id>`:

### Step 1: Determine target experiment

- If argument provided → use as exp_id
- If no argument → read `.pipeline-state.json` for `current_exp`
- If `current_exp` is null and no argument → ask user which experiment

### Step 2: Verify experiment exists

- Check `exp/{exp_id}/` directory exists
- Check `exp/{exp_id}/results/runs.log` exists
- If not → tell user: "Experiment {exp_id} not found. Run `/labmate:new-experiment` first."

### Step 3: Delegate to @exp-manager

> Check experiment {exp_id} status.
> Read `exp/{exp_id}/results/runs.log` and `.pipeline-state.json`.
> Diagnose any failures, auto-retry if appropriate, report status.

### Step 4: Suggest continuous monitoring

After the check completes, tell user:

> For continuous monitoring, run: `/loop 5m /monitor {exp_id}`
