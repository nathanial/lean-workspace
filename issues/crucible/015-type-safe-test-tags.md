# Type-Safe Test Tags

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description

No tagging system exists for categorizing tests.

## Proposed Change

Add a tag system using a custom type or string array, enabling test filtering by category (unit, integration, slow, etc.).

## Benefits

Better organization, selective test runs.

## Affected Files

- `Crucible/Core.lean` - Add tags to `TestCase`
- `Crucible/Macros.lean` - Add tag syntax
