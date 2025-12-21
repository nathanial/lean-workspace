# Duplicated innerArea Pattern

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Every widget has the same boilerplate for handling optional blocks and computing inner areas.

## Rationale
Extract common pattern into a helper function. Consider a Widget wrapper that handles block rendering.

## Affected Files
- All widget files in `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Widgets/`
