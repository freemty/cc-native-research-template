#!/bin/bash
# Hook: PostToolUse(Bash) — check CHANGELOG compliance after git commits
# Only triggers when the Bash command was actually a git commit

# Read the tool call info from stdin
INPUT=$(cat)

# Guard: only act if this was a git commit command
if ! echo "$INPUT" | grep -q "git commit"; then exit 0; fi

# Check what files changed in the most recent commit
CHANGED=$(git diff --name-only HEAD~1 HEAD 2>/dev/null)
if [ -z "$CHANGED" ]; then exit 0; fi

HAS_PROMPTS=$(echo "$CHANGED" | grep "^prompts/" || true)
HAS_SKILLS=$(echo "$CHANGED" | grep "^\.claude/skills/" || true)
HAS_CHANGELOG=$(echo "$CHANGED" | grep "CHANGELOG" || true)

if [ -n "$HAS_PROMPTS" ] || [ -n "$HAS_SKILLS" ]; then
  if [ -z "$HAS_CHANGELOG" ]; then
    echo "Changed prompts/ or .claude/skills/ without CHANGELOG entry. Consider updating CHANGELOG.md."
  fi
fi
