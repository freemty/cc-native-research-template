# labmate rules
# Instance-specific: paper notes
docs/papers/*.md
!docs/papers/landscape.md

# Instance-specific: pipeline runtime state
.pipeline-state.json

# Instance-specific: generated slides
slides/*.html

# Instance-specific: experiment plans & progress
docs/plans/
docs/weekly/

# Experiment results (large, machine-generated)
exp/*/results/*
!exp/*/results/.gitkeep
!exp/*/results/runs.log
