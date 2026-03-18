"""Analyze results for exp00a.

Usage:
    python exp/exp00a/analyze.py
"""
from __future__ import annotations
from pathlib import Path

from exp.lib.analyze_common import load_runs_log, compute_summary_stats


def main() -> None:
    log_path = Path("exp/exp00a/results/runs.log")

    if not log_path.exists():
        print("No runs.log found. Run the experiment first.")
        return

    entries = load_runs_log(log_path.read_text())
    stats = compute_summary_stats(entries)

    summary = "# exp00a Results Summary\n\n"
    summary += f"Total runs: {stats['total']}\n\n"

    if stats.get("labels"):
        summary += "| Label | Count |\n|-------|-------|\n"
        for label, count in stats["labels"].items():
            summary += f"| {label} | {count} |\n"

    summary_path = Path("exp/exp00a/results/summary.md")
    summary_path.write_text(summary)
    print(f"Summary written to {summary_path}")


if __name__ == "__main__":
    main()
