# Drag and Drop

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** Stateful Widget Abstractions

## Description
Add drag-and-drop support with drag sources, drop targets, and transfer data.

## Rationale
Desktop applications commonly need drag-and-drop for reordering lists, moving items between containers, and file dropping. Arbor has pointer capture for dragging but no structured DnD API.

## Affected Files
- `Canopy/DnD/Source.lean` (new)
- `Canopy/DnD/Target.lean` (new)
- `Canopy/DnD/State.lean` (new)
