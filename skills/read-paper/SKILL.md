---
name: read-paper
description: >
  Deep-dive a single paper — methodology, assumptions, implications. Triggers on
  "read this paper", "读论文", "explain this PDF", "arxiv.org/abs/", paper URLs,
  "what does this paper say", "paper deep-dive".
disable-model-invocation: true
---

# Read Paper

Deep-dive a single paper with interactive Q&A. Outputs a structured analysis, then lets the user ask follow-up questions.

## Instructions

When this skill is invoked with `<input>`:

### Step 1: Parse input and fetch paper content

Determine input type and fetch accordingly:

| Input type | Detection | Action |
|-----------|-----------|--------|
| Local PDF | `<input>` ends with `.pdf` and is a file path | Use Read tool. If PDF exceeds 20 pages, read pages 1-20 first, then ask user which sections to focus on. |
| arXiv PDF URL | `<input>` matches `arxiv.org/pdf/` | Convert to abstract URL (replace `/pdf/` with `/abs/`, remove `.pdf` suffix), then fetch with Jina Reader: `curl -s "https://r.jina.ai/{abstract_url}" -H "Accept: text/markdown"` |
| arXiv URL | `<input>` matches `arxiv.org` (non-PDF) | Fetch with Jina Reader: `curl -s "https://r.jina.ai/{url}" -H "Accept: text/markdown"` |
| Other URL | `<input>` starts with `http://` or `https://` | Try WebFetch first. If it fails or returns insufficient content, fall back to Jina Reader: `curl -s "https://r.jina.ai/{url}" -H "Accept: text/markdown"` |
| Pasted text | None of the above | Use `<input>` directly as paper content |

If fetching fails entirely, tell the user and suggest an alternative input method.

### Step 2: Gather research context

Read the following files if they exist (skip silently if not found):
- `docs/papers/landscape.md` — user's literature map
- `exp/summary.md` — user's experiment history

### Step 3: Delegate to @domain-expert

Invoke `@domain-expert` with this prompt:

> **Mode 4: Paper Deep-Dive**
>
> Paper content:
> {fetched paper content}
>
> Research context:
> - Literature landscape: {landscape.md content or "not available"}
> - Experiment history: {exp/summary.md content or "not available"}
>
> Provide your structured deep-dive analysis (Methodology Skeleton, Assumptions & Limitations, Bridge Analysis), then enter interactive Q&A mode.

The user will then interact directly with domain-expert for follow-up questions. When the user says "save" / "archive" / "store" / "存档" / "保存" (with optional "as {name}"), domain-expert handles archival via its Mode 4 archive sub-flow.
