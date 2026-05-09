---
name: update-knowhow
description: >
  Alias for /update-docs (knowhow branch). Use when user says '记下来', '归档',
  'save this', or after a <knowhow-hint> prompt. Routes to the unified
  /update-docs workflow with knowhow branch auto-selected.
disable-model-invocation: true
---

# /update-knowhow

This is an alias. Execute `/update-docs` — it will auto-route to Branch A (knowhow) based on context.

All logic lives in `/update-docs`. Do not duplicate workflow here.
