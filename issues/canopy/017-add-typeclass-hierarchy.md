# Add TypeClass Hierarchy

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
No typeclasses defined.

Proposed change: Define typeclasses for common widget behaviors:
```lean
class Focusable (w : Type) where
  canFocus : w -> Bool
  tabIndex : w -> Int

class Themed (w : Type) where
  applyTheme : Theme -> w -> w

class Validatable (a : Type) where
  validate : a -> ValidationResult
```

## Rationale
Polymorphic widget behavior, consistent API.

## Affected Files
- `Canopy/Typeclass/Focusable.lean` (new)
- `Canopy/Typeclass/Themed.lean` (new)
