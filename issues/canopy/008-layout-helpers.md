# Layout Helpers

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Provide higher-level layout combinators that compose Trellis flex/grid layouts with common patterns.

## Rationale
Common layout patterns (sidebar + content, header + body + footer, split panes) require repetitive Trellis configuration. Canopy should provide named helpers.

## Affected Files
- `Canopy/Layout/Patterns.lean` (new)
- `Canopy/Layout/Responsive.lean` (new)

## Proposed Helpers
```lean
def sidebarLayout (sidebar content : WidgetBuilder) : WidgetBuilder
def headerBodyFooter (header body footer : WidgetBuilder) : WidgetBuilder
def splitPane (left right : WidgetBuilder) (ratio : Float) : WidgetBuilder
def cardGrid (columns : Nat) (cards : Array WidgetBuilder) : WidgetBuilder
```
