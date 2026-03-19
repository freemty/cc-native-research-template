#!/bin/bash
# Hook: PreCompact — remind to update project skill if stale
STATE_FILE=".pipeline-state.json"
if [ ! -f "$STATE_FILE" ]; then exit 0; fi

UPDATED_AT=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('skill_updated_at', 0))")
NOW=$(date +%s)
HOURS=$(( (NOW - UPDATED_AT) / 3600 ))

if [ "$HOURS" -gt 24 ]; then
  echo "Project skill is ${HOURS}h stale. Run /update-project-skill before context compacts."
fi
