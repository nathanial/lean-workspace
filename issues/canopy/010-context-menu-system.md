# Context Menu System

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** Focus Management System

## Description
Add right-click context menu support with nested menus and keyboard navigation.

## Rationale
Desktop applications expect right-click menus. This requires overlay rendering, focus trapping, and menu positioning logic.

## Affected Files
- `Canopy/Menu/Context.lean` (new)
- `Canopy/Menu/Item.lean` (new)
- `Canopy/Menu/Overlay.lean` (new)
