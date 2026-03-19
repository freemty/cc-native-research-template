#!/bin/bash
# Hook: PreToolUse(Write) — remind to brainstorm before big changes

INPUT=$(cat)

# Extract file path from Write tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Only remind for new file creation, not edits
if [ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ]; then
  exit 0
fi

# Only remind if no recent spec exists (within last 24h)
RECENT_SPEC=$(find docs/specs/ -name "*.md" -mtime -1 2>/dev/null | head -1)

if [ -z "$RECENT_SPEC" ]; then
  echo "Tip: Creating new file without a recent spec. Consider /brainstorming first for big changes."
fi
