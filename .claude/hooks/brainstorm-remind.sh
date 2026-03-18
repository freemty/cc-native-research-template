#!/bin/bash
# Hook: PreToolUse(Write) — remind to brainstorm before big changes
# Only triggers for new files (not edits), reduces noise

INPUT=$(cat)

# Only remind for new file creation, not edits to existing files
# Check if the file path in the Write call already exists
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"//')

if [ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ]; then
  # Editing existing file — no reminder needed
  exit 0
fi

# Only remind if no recent spec exists (within last 24h)
RECENT_SPEC=$(find docs/specs/ -name "*.md" -mtime -1 2>/dev/null | head -1)

if [ -z "$RECENT_SPEC" ]; then
  echo "Tip: Creating new file without a recent spec. Consider /brainstorming first for big changes."
fi
