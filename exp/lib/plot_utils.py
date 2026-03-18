"""Shared plotting utilities for experiment visualization."""
from __future__ import annotations

try:
    import matplotlib.pyplot as plt
except ImportError:
    plt = None


def save_bar_chart(data: dict[str, float], title: str, output_path: str) -> str:
    """Save a simple bar chart. Returns the output path."""
    if plt is None:
        raise ImportError("matplotlib is required for plotting. Install with: pip install matplotlib")
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.bar(list(data.keys()), list(data.values()))
    ax.set_title(title)
    ax.set_ylabel("Value")
    fig.tight_layout()
    fig.savefig(output_path, dpi=150)
    plt.close(fig)
    return output_path
