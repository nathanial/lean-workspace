# Lazy Widget Loading

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** Scroll container improvements

## Description
Support for lazy/virtualized lists that only instantiate visible items.

## Rationale
Large lists would benefit from virtualization to avoid creating thousands of widget nodes.

## Affected Files
- `Arbor/Widget/Virtualized.lean` (new file)
- `Arbor/Widget/Measure.lean` - virtual measurement
