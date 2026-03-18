# Alternative Approaches (Discarded)

## Option A: Scaffold + Submodule
A CLI tool (`cc-research init`) that scaffolds projects and stays connected via git submodule for updates.

**Rejected because:** Update mechanism is fragile (merge conflicts between template updates and project customizations). Submodule dependency creates ongoing maintenance burden. Users can't freely modify generated files without worrying about upstream conflicts.

## Option C: Meta-Agent Package (pip install)
Python package that provides agents and skills as importable modules.

**Rejected because:** Over-engineers the distribution problem. CC skills/agents are just markdown files — they don't need a package manager. pip dependency adds friction and version conflicts. The "service" we provide is skill generation, not pre-built skills.
