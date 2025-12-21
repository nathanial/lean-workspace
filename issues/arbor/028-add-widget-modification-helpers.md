# Add Widget Modification Helpers

**Priority:** Medium
**Section:** API Ergonomics
**Estimated Effort:** Small (Medium if using Collimator)
**Dependencies:** Optional: Collimator optics library

## Description
Widgets are immutable, but there is no convenient way to modify nested widget properties.

Action required: Add lens-like helpers or use Collimator optics:
```lean
def Widget.withStyle (f : BoxStyle -> BoxStyle) : Widget -> Widget
def Widget.mapChildren (f : Widget -> Widget) : Widget -> Widget
```

## Rationale
More ergonomic widget manipulation.

## Affected Files
- `Arbor/Widget/Core.lean`
