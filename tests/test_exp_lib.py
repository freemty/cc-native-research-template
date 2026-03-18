import pytest
from exp.lib.analyze_common import load_runs_log, compute_summary_stats


def test_load_runs_log_empty():
    """Empty log returns empty list."""
    result = load_runs_log("")
    assert result == []


def test_load_runs_log_parses_entries():
    """Parses well-formed runs.log lines."""
    log_content = "# 2026-03-18T10:00:00 baseline task_001 results/001.json\n# 2026-03-18T10:05:00 baseline task_002 results/002.json"
    result = load_runs_log(log_content)
    assert len(result) == 2
    assert result[0]["label"] == "baseline"
    assert result[0]["task_id"] == "task_001"


def test_load_runs_log_skips_blank_lines():
    """Blank lines and non-entry lines are skipped."""
    log_content = "\n# 2026-03-18T10:00:00 baseline task_001 results/001.json\n\n"
    result = load_runs_log(log_content)
    assert len(result) == 1


def test_compute_summary_stats_empty():
    """Empty entries returns empty stats."""
    result = compute_summary_stats([])
    assert result == {"total": 0, "labels": {}}


def test_compute_summary_stats_counts_labels():
    """Counts entries by label."""
    entries = [
        {"label": "baseline", "task_id": "t1"},
        {"label": "baseline", "task_id": "t2"},
        {"label": "variant", "task_id": "t3"},
    ]
    result = compute_summary_stats(entries)
    assert result["total"] == 3
    assert result["labels"] == {"baseline": 2, "variant": 1}
