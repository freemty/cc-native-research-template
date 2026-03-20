#!/bin/bash
# Hook: Stop — remind pending pipeline actions and check CHANGELOG compliance
STATE_FILE=".pipeline-state.json"
if [ ! -f "$STATE_FILE" ]; then exit 0; fi

STAGE=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('stage', 'dev'))")
EXP=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('current_exp', 'none') or 'none')")

case "$STAGE" in
  dev)
    echo "Stage: dev. Consider /new-experiment to start next experiment."
    ;;
  skill-update)
    echo "Stage: skill-update. Run /update-project-skill to refresh project knowledge."
    ;;
  experiment)
    echo "Stage: experiment ($EXP). Check exp-manager status or run your experiment."
    ;;
  monitoring)
    echo "Stage: monitoring ($EXP). Monitor loop active. Wait for completion or check manually."
    ;;
  analysis)
    echo "Stage: analysis ($EXP). Analysis done. Run /commit-changelog to persist findings."
    ;;
  commit)
    echo "Stage: commit. Run /update-project-skill to update knowledge base."
    ;;
  *)
    echo "Stage: $STAGE (unknown). Check .pipeline-state.json."
    ;;
esac

# CHANGELOG compliance check
CHANGED=$(git diff --name-only HEAD 2>/dev/null || true)
HAS_PROMPTS=$(echo "$CHANGED" | grep "^prompts/" || true)
HAS_SKILLS=$(echo "$CHANGED" | grep "^\.claude/skills/" || true)

if [ -n "$HAS_PROMPTS" ] || [ -n "$HAS_SKILLS" ]; then
  HAS_CHANGELOG=$(echo "$CHANGED" | grep "CHANGELOG" || true)
  if [ -z "$HAS_CHANGELOG" ]; then
    echo "Warning: prompts/ or .claude/skills/ changed without CHANGELOG entry."
  fi
fi
