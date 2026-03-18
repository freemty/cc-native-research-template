---
description: "Scaffold a new experiment directory with standard structure"
---

# New Experiment

Scaffolds a new experiment directory under `exp/`.

## Instructions

When this skill is invoked:

1. **Gather inputs** (ask user one at a time):
   - Parent experiment ID (or "none" for first experiment)
   - Variant letter (auto-suggest: scan `exp/` for existing experiments, suggest next available letter)
   - One-line motivation
   - Config base: copy from parent experiment's config.yaml, or use blank template

2. **Compute experiment ID:**
   - If parent is `exp01a`, next variant is `exp01b`
   - If no parent or new major, increment number: `exp02a`
   - Format: `exp{NN}{x}` where NN is zero-padded number, x is lowercase letter

3. **Create directory structure:**

   ```
   exp/{exp_id}/
   ├── README.md
   ├── config.yaml
   ├── run.py
   ├── analyze.py
   └── results/
       ├── .gitkeep
       └── runs.log
   ```

   **README.md template:**
   ```markdown
   # {exp_id}: {motivation}

   ## Motivation
   {motivation}

   ## Relation to Previous
   {parent description or "First experiment — no predecessor."}

   ## Settings
   See `config.yaml` for configuration.

   ## Findings
   (populated by /analyze-experiment)

   ## Pitfalls
   (append lessons learned here)
   ```

   **config.yaml:** Copy from parent or use blank template with experiment name filled in.

   **run.py:** Skeleton script:
   ```python
   """Run experiment {exp_id}."""
   import argparse
   import yaml
   from pathlib import Path
   from datetime import datetime

   def main():
       parser = argparse.ArgumentParser(description="Run {exp_id}")
       parser.add_argument("--config", default="exp/{exp_id}/config.yaml")
       parser.add_argument("--dry-run", action="store_true")
       parser.add_argument("--resume", type=str, help="Resume from RUNID")
       args = parser.parse_args()

       config = yaml.safe_load(Path(args.config).read_text())

       if args.dry_run:
           print(f"[DRY RUN] Would run {exp_id} with config: {config}")
           return

       # TODO: Implement experiment logic here
       run_id = f"run_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
       log_entry = f"# {datetime.now().isoformat()} {config.get('experiment', {}).get('name', 'unknown')} {run_id} results/{run_id}.json"

       log_path = Path("exp/{exp_id}/results/runs.log")
       with open(log_path, "a") as f:
           f.write(log_entry + "\n")

       print(f"Completed {run_id}")

   if __name__ == "__main__":
       main()
   ```

   **analyze.py:** Skeleton script:
   ```python
   """Analyze results for {exp_id}."""
   from pathlib import Path
   from exp.lib.analyze_common import load_runs_log, compute_summary_stats

   def main():
       log_path = Path("exp/{exp_id}/results/runs.log")
       entries = load_runs_log(log_path.read_text())
       stats = compute_summary_stats(entries)

       summary = f"# {exp_id} Results Summary\n\n"
       summary += f"Total runs: {stats['total']}\n"
       for label, count in stats.get('labels', {}).items():
           summary += f"- {label}: {count}\n"

       summary_path = Path("exp/{exp_id}/results/summary.md")
       summary_path.write_text(summary)
       print(f"Summary written to {summary_path}")

   if __name__ == "__main__":
       main()
   ```

   **runs.log:** Empty with format header:
   ```
   # Format: {timestamp} {label} {task_id} {result_path}
   ```

4. **Append row to `exp/summary.md`:**
   ```
   | {exp_id} | {motivation} | In Progress | — |
   ```

5. **Update `.pipeline-state.json`:**
   - Set `current_exp` to new exp_id
   - Set `stage` to "experiment"

6. **Remind** about prompt version bump if `prompts/` directory has content.
