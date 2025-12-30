---
name: collimator-optics
description: Use profunctor optics from the Collimator library for Lean 4. Use when working with lenses, prisms, traversals, or nested data access.
---

# Collimator Optics Quick Reference

## Setup

```lean
import Collimator
import Collimator.Derive.Lenses
open Collimator.Derive
open scoped Collimator.Operators
```

## Generate Lenses (Preferred)

```lean
-- In separate Optics.lean file (to avoid circular imports)
makeLenses Person      -- Generates: personName, personAge, etc.
makeLenses Address     -- Generates: addressCity, addressZip, etc.
```

## Operators

| Op | Name | Example |
|----|------|---------|
| `^.` | view | `person ^. personName` |
| `^?` | preview | `val ^? _someVariant` |
| `.~` | set | `person & personAge .~ 30` |
| `%~` | over | `person & personAge %~ (· + 1)` |
| `&` | pipe | `x & lens .~ v` |
| `∘` | compose | `outer ∘ inner` |

## Prisms for Sum Types

```lean
def _left : Prism' (Either A B) A := ctorPrism% Either.left
def _right : Prism' (Either A B) B := ctorPrism% Either.right

-- Usage
either ^? _left          -- Option A
either & _left %~ f      -- modify if Left
```

## Common Patterns

```lean
-- Nested access
employee ^. (employeeAddress ∘ addressCity)

-- Chained updates
config
  & configHost .~ "localhost"
  & configPort .~ 8080

-- Conditional via prism
if (val ^? _error).isSome then handleError else continue
```

## File Organization

To avoid circular imports:
1. Put structures in `Types.lean`
2. Put `makeLenses` calls in `Optics.lean` (imports Types)
3. Put methods in other files (import Optics)
