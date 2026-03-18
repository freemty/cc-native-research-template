#!/bin/bash
# Hook: PreToolUse(Bash) — block direct /frontend-slides invocation
# This is the ONLY hard-blocking hook in the template.
# Prevents: (1) context pollution from ~60KB HTML, (2) enforces analysis-first workflow
#
# Strategy: Since CC has no "Skill" tool matcher, we intercept via Bash matcher
# and check if the command is invoking frontend-slides skill indirectly.
# Also adds a soft guard in analyze-experiment skill instructions.

INPUT=$(cat)

# Check if the bash command involves frontend-slides
if echo "$INPUT" | grep -q "frontend-slides"; then
  echo "BLOCK: Direct /frontend-slides usage detected."
  echo "Use /analyze-experiment instead — it handles slides generation via the slides-maker agent,"
  echo "keeping heavy HTML output out of your main context."
  exit 2
fi
