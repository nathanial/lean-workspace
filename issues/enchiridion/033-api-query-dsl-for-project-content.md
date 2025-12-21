# Query DSL for Project Content

**Priority:** Low
**Section:** API Enhancements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add a simple query DSL for finding content in the project (e.g., scenes containing a character name, notes by category).

## Rationale
Example:
```lean
project.findScenes (fun s => s.content.containsSubstr "Sarah")
project.findNotes (·.category == .location)
```

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Model/Project.lean`
