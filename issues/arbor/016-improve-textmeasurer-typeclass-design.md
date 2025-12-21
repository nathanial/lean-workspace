# Improve TextMeasurer Typeclass Design

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The `TextMeasurer` typeclass uses a monad parameter `M`:
```lean
class TextMeasurer (M : Type -> Type) where
  measureText : String -> FontId -> M TextMetrics
```

This requires carrying the monad type through many function signatures.

Proposed change: Consider a simpler interface or effect system integration:
```lean
structure TextMeasurerHandle where
  measureText : String -> FontId -> IO TextMetrics
```

## Rationale
Simpler API, easier backend integration.

## Affected Files
- `Arbor/Core/TextMeasurer.lean`
- `Arbor/Widget/Measure.lean`
- `Arbor/Widget/TextLayout.lean`
