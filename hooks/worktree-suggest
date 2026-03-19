#!/bin/bash
# Hook: PreToolUse(Bash) — suggest worktree for destructive git ops

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if echo "$COMMAND" | grep -qE "git (reset --hard|checkout -- \.|clean -f|clean -fd|branch -D)"; then
  echo "Tip: Consider using 'git worktree' for destructive/exploratory changes."
  echo "Usage: git worktree add ../experiment-branch experiment-branch"
fi
