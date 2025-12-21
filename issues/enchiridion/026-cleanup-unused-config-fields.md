# Unused Config Fields

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small (removal) or Medium (implementation)
**Dependencies:** None

## Description
`autoSaveEnabled` and `autoSaveIntervalMs` config fields are parsed and saved but never used.

## Rationale
Either implement auto-save feature or remove the unused fields.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Core/Config.lean` (lines 17-18)
