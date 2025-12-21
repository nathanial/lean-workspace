# Improve Test Name Collision Handling

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description

In `Crucible/Macros.lean` lines 62-77, test name collisions are handled by appending numeric suffixes. This happens silently.

## Proposed Change

Add a warning when duplicate test names are detected, or make the generated name more predictable (include line number).

## Benefits

Better debugging experience, clearer test identification.

## Affected Files

- `Crucible/Macros.lean`
