# Add Crucible Test Framework

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
The project has no test infrastructure.

Proposed change: Add crucible dependency and create a test directory structure.

## Rationale
Enables TDD for new features, regression testing.

## Affected Files
- `lakefile.lean` - Add crucible dependency and test target
- `CanopyTests/Main.lean` (new)
