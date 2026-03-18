"""Shared analysis utilities for experiment results."""
from __future__ import annotations


def load_runs_log(content: str) -> list[dict]:
    """Parse runs.log content into structured entries.

    Format: # {timestamp} {label} {task_id} {result_path}
    """
    entries = []
    for line in content.strip().splitlines():
        line = line.strip()
        if not line or not line.startswith("#"):
            continue
        parts = line[2:].split()
        if len(parts) < 4:
            continue
        entries.append({
            "timestamp": parts[0],
            "label": parts[1],
            "task_id": parts[2],
            "result_path": parts[3],
        })
    return entries


def compute_summary_stats(entries: list[dict]) -> dict:
    """Compute summary statistics from parsed log entries."""
    if not entries:
        return {"total": 0, "labels": {}}
    labels: dict[str, int] = {}
    for entry in entries:
        label = entry.get("label", "unknown")
        labels[label] = labels.get(label, 0) + 1
    return {"total": len(entries), "labels": labels}
