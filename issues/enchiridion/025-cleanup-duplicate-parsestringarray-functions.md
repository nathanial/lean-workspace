# Duplicate parseStringArray Functions

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
The helper function `parseStringArray` is defined identically in both `Character.lean` and `WorldNote.lean`.

## Rationale
Move the function to `Core/Json.lean` and export it for shared use.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Model/Character.lean` (lines 73-77)
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Model/WorldNote.lean` (lines 114-118)
