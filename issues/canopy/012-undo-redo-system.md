# Undo/Redo System

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Provide a command pattern-based undo/redo stack for reversible operations.

## Rationale
Applications with editing capabilities need undo/redo. A generic command stack can be shared across widgets.

## Affected Files
- `Canopy/History/Command.lean` (new)
- `Canopy/History/Stack.lean` (new)
