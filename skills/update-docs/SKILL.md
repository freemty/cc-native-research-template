---
name: update-docs
description: >
  Create or update human-facing structured documents (design docs, guides,
  README, changelog) with automatic CLAUDE.md indexing. Use when user says
  "update docs", "更新文档", "写 README", "update design doc", "getting started",
  or wants to maintain project documentation for humans. Also triggers when
  conversation context implies documentation should be created or updated.
disable-model-invocation: true
---

# /update-docs

Create or update human-facing structured documents with automatic CLAUDE.md indexing.

## Usage

```
/update-docs                     — Auto-detect from conversation context
/update-docs <description>       — Natural language description of what to document
/update-docs <path>              — Update existing doc at path
/update-docs <type> <name>       — Create new doc of given type
```

## Step 1: Determine Intent

### With args

Parse user input to identify:
- **Target path** — explicit path, or derived from type + name
- **Operation** — create (new file) or update (existing file)
- **Natural language** — infer type, path, and content from description

### Without args (context-driven)

Analyze the conversation context to determine what documentation is needed. Look for:
- Discussions about design decisions → `docs/design/` or `docs/specs/`
- Step-by-step procedures discussed → `docs/guides/`
- Feature implementations completed → README update or new guide
- Version bumps or releases → CHANGELOG update
- User explicitly asked to "document this" or "write this up"

Produce a one-line summary of what you plan to create/update and proceed immediately. Do NOT ask the user to choose a type.

### Document Types

| Type | Default Path | Template |
|------|-------------|----------|
| design | `docs/design/{name}.md` | System design with sections: Overview, Architecture, API, Trade-offs |
| guide | `docs/guides/{name}.md` | How-to with sections: Prerequisites, Steps, Troubleshooting |
| readme | `README.md` | Project README |
| changelog | `CHANGELOG.md` | Version changelog |
| custom | user-specified | Minimal: title + content |

## Step 2: Gather Context

Before writing, collect relevant information:

```bash
# Project structure
ls -la

# Recent changes (for changelog/readme)
git log --oneline -20

# Existing doc content (for updates)
# Read the target file if it exists
```

For **updates**: read the current file, identify what's stale or missing based on current code state.

For **creates**: scan the codebase for relevant code to document.

## Step 3: Write Document

### Create Mode

1. Generate content based on type template + gathered context
2. Write the file
3. Index in CLAUDE.md (see Step 4)

### Update Mode

1. Read existing content
2. Identify sections that need updating (compare against current code/state)
3. Edit the file — preserve user-written sections, update generated sections
4. Verify CLAUDE.md index exists (add if missing)

## Step 4: Auto-Index in CLAUDE.md

After writing, ensure CLAUDE.md has an entry for the document.

Rules:
- `docs/specs/*.md` or `docs/design/*.md` → add to Specs section as `- \`{path}\` — {one-line description}`
- `docs/guides/*.md` → add to a Guides section (create if absent)
- `README.md`, `CHANGELOG.md` → skip indexing (top-level, already discoverable)
- Custom paths → add to the most relevant existing section, or create a "Docs" section

Check before adding:
```bash
grep -q "<path>" CLAUDE.md
```

Only add if not already present. If present but description is stale, update the description.

## Step 5: Report

Output:
- What was created/updated
- What sections changed (for updates)
- Confirm index entry status

## Common Mistakes

| Mistake | Correct |
|---------|---------|
| Asking user to pick a type when context is clear | Infer from context, state plan, execute |
| Overwriting user-written content | Only update generated/stale sections |
| Creating docs/ subdirs without checking | Use `ls` first, create dir if needed |
| Writing agent-facing knowledge here | That belongs in /update-knowhow |
| Forgetting CLAUDE.md index | Always check + add/update |
| Huge monolithic docs | Keep focused — one concern per doc |
| Adding README/CHANGELOG to index | Skip — they're already top-level |
