"""Run experiment exp00a.

Usage:
    python exp/exp00a/run.py
    python exp/exp00a/run.py --dry-run
    python exp/exp00a/run.py --resume <RUNID>
"""
from __future__ import annotations
import argparse
from datetime import datetime
from pathlib import Path

import yaml


def main() -> None:
    parser = argparse.ArgumentParser(description="Run exp00a")
    parser.add_argument("--config", default="exp/exp00a/config.yaml")
    parser.add_argument("--dry-run", action="store_true", help="Print plan without executing")
    parser.add_argument("--resume", type=str, help="Resume from RUNID")
    args = parser.parse_args()

    config = yaml.safe_load(Path(args.config).read_text())
    exp_name = config.get("experiment", {}).get("name", "unknown")

    if args.dry_run:
        print(f"[DRY RUN] Would run {exp_name} with config:")
        print(f"  Model: {config.get('model', {}).get('name', 'unset')}")
        print(f"  Metrics: {config.get('eval', {}).get('metrics', [])}")
        return

    if args.resume:
        print(f"Resuming from {args.resume}")

    # TODO: Implement experiment logic here
    run_id = f"run_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    timestamp = datetime.now().isoformat()
    log_entry = f"# {timestamp} {exp_name} {run_id} results/{run_id}.json"

    log_path = Path("exp/exp00a/results/runs.log")
    with open(log_path, "a") as f:
        f.write(log_entry + "\n")

    print(f"Completed {run_id}")


if __name__ == "__main__":
    main()
