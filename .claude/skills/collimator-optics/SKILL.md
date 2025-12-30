---
name: collimator-optics
description: Use profunctor optics from the Collimator library for Lean 4. Use when working with lenses, prisms, traversals, accessing/modifying nested data structures, or when the user mentions optics, lenses, or Collimator.
---

# Collimator: Profunctor Optics for Lean 4

Collimator is a profunctor optics library enabling composable, type-safe access and modification of nested data structures.

## When to Use Optics

Use optics when:
- Accessing/modifying deeply nested fields in structures
- Working with optional data (Option, sum types)
- Transforming collections of nested values
- Building reusable data access patterns

## Quick Start

```lean
import Collimator.Prelude

open Collimator
open scoped Collimator.Operators
```

## Optic Types Hierarchy

```
        Iso
       /   \
    Lens   Prism
       \   /
   AffineTraversal
         |
     Traversal
```

| Optic | Focus Count | Key Operations |
|-------|-------------|----------------|
| `Iso` | Exactly 1 | `view`, `review`, `over` |
| `Lens` | Exactly 1 | `view`, `set`, `over` |
| `Prism` | 0 or 1 | `preview`, `review`, `over` |
| `AffineTraversal` | 0 or 1 | `preview`, `set`, `over` |
| `Traversal` | 0 to many | `toList`, `traverse`, `over` |

## Creating Lenses

### Manual Definition

```lean
structure Person where
  name : String
  age : Nat

def nameLens : Lens' Person String :=
  lens' (·.name) (fun p n => { p with name := n })

def ageLens : Lens' Person Nat :=
  lens' (·.age) (fun p a => { p with age := a })
```

### Using fieldLens% Elaborator

```lean
def nameLens : Lens' Person String := fieldLens% Person name
def ageLens : Lens' Person Nat := fieldLens% Person age
```

### Using makeLenses (Separate File Required)

```lean
-- In PersonLenses.lean (NOT the same file as Person definition)
import MyTypes.Person
import Collimator.Derive.Lenses

open Collimator.Derive in
makeLenses Person
-- Generates: personName, personAge

-- With options:
makeLenses Person (only := [name])
makeLenses Person (except := [age])
makeLenses Person (namePrefix := "get", nameSuffix := "L")
```

## Creating Prisms

### For Sum Type Variants

```lean
inductive ConfigValue
  | str (s : String)
  | num (n : Int)
  | flag (b : Bool)

def strPrism : Prism' ConfigValue String :=
  prismFromPartial
    (fun | .str s => some s | _ => none)
    ConfigValue.str
```

### Using ctorPrism% Elaborator

```lean
def strPrism : Prism' ConfigValue String := ctorPrism% ConfigValue.str
def numPrism : Prism' ConfigValue Int := ctorPrism% ConfigValue.num
```

## Creating Isomorphisms

```lean
-- Bidirectional transformation
def stringChars : Iso' String (List Char) :=
  iso (forward := String.toList) (back := String.mk)
```

## Operators Reference

| Operator | Name | Type | Example |
|----------|------|------|---------|
| `^.` | view | `s → Lens' s a → a` | `person ^. nameLens` |
| `^?` | preview | `s → Prism' s a → Option a` | `opt ^? somePrism'` |
| `^..` | toList | `s → Traversal' s a → List a` | `list ^.. traversed` |
| `%~` | over | `optic → (a → a) → s → s` | `lens %~ (· + 1)` |
| `.~` | set | `optic → a → s → s` | `lens .~ 42` |
| `&` | pipe | `s → (s → t) → t` | `x & lens .~ v` |
| `∘` | compose | `optic → optic → optic` | `outer ∘ inner` |

## Common Usage Patterns

### View and Modify

```lean
let person := { name := "Alice", age := 30 : Person }

-- View
person ^. nameLens              -- "Alice"

-- Set
person & ageLens .~ 31          -- { name := "Alice", age := 31 }

-- Modify
person & ageLens %~ (· + 1)     -- { name := "Alice", age := 31 }
```

### Composition for Nested Access

```lean
structure Address where
  city : String
  zip : String

structure Employee where
  name : String
  address : Address

def addressLens : Lens' Employee Address := fieldLens% Employee address
def cityLens : Lens' Address String := fieldLens% Address city

-- Compose to access nested city
def employeeCity : Lens' Employee String := addressLens ∘ cityLens

employee ^. employeeCity                    -- "New York"
employee & employeeCity .~ "Boston"         -- updates city
```

### Working with Optionals

```lean
open Collimator.Instances.Option

-- somePrism' focuses on the value inside Some
let opt : Option Int := some 42
opt ^? somePrism'                          -- some 42
opt & somePrism' %~ (· + 1)                -- some 43

-- Compose lens with prism for optional nested access
def maybeCity : AffineTraversal' Employee String :=
  addressLens ∘ cityLens  -- works if address is optional
```

### Traversing Collections

```lean
open Collimator.Instances.List

-- Modify all elements
[1, 2, 3] & traversed %~ (· * 2)           -- [2, 4, 6]

-- Set all elements
[1, 2, 3] & traversed .~ 0                 -- [0, 0, 0]

-- Collect all elements through composed path
let employees : List Employee := ...
employees ^.. (traversed ∘ employeeCity)   -- ["NYC", "Boston", ...]
```

### Chained Updates

```lean
config
  & databaseHost .~ "localhost"
  & serverPort .~ 8080
  & loggingLevel .~ "debug"
  & (cache ∘ enabled) .~ false
```

## Built-in Traversals and Prisms

### List Operations

```lean
import Collimator.Combinators

-- Safe head/last access
[1, 2, 3] ^? _head                         -- some 1
[] ^? _head                                -- none
[1, 2, 3] & _last %~ (· * 10)              -- [1, 2, 30]

-- Partial traversals
over (taking 2) (· * 10) [1, 2, 3, 4]      -- [10, 20, 3, 4]
over (dropping 2) (· * 10) [1, 2, 3, 4]    -- [1, 2, 30, 40]

-- Filtered traversal
over (filteredList (· > 0)) (· * 2) [-1, 2, -3, 4]  -- [-1, 4, -3, 8]
```

### Pair Operations

```lean
import Collimator.Combinators.Bitraversal

(1, 2) ^. _1                               -- 1
(1, 2) & _2 .~ 99                          -- (1, 99)

-- Traverse both components
over both String.toUpper ("a", "b")        -- ("A", "B")
```

## Fold Operations

```lean
-- Collect all foci
toListOf traversed [1, 2, 3]               -- [1, 2, 3]

-- Aggregate operations
Fold.sumOf traversed [1, 2, 3]             -- 6
Fold.lengthOf traversed [1, 2, 3]          -- 3
Fold.anyOf traversed (· > 2) [1, 2, 3]     -- true
Fold.allOf traversed (· > 0) [1, 2, 3]     -- true
Fold.findOf traversed (· > 1) [1, 2, 3]    -- some 2
```

## Type Annotations for Composed Optics

When defining named composed optics, add type annotations:

```lean
-- Explicit type annotation helps inference
def allUserNames : Traversal' (List User) String :=
  traversed ∘ userNameLens

-- Or use optic% macro
def allUserNames := optic%
  traversed ∘ userNameLens : Traversal' (List User) String
```

## Debug Commands

```lean
import Collimator.Commands

#optic_info Lens        -- Shows lens capabilities and usage
#optic_info Prism       -- Shows prism capabilities
#optic_matrix           -- Shows composition result matrix
#optic_caps Traversal   -- Shows what operations work with Traversal
```

## Common Patterns

### JSON-like Navigation

```lean
-- Define prisms for each variant
def _string : Prism' JsonValue String := ctorPrism% JsonValue.string
def _array : Prism' JsonValue (List JsonValue) := ctorPrism% JsonValue.array

-- Define affine traversal for field access
def field (key : String) : AffineTraversal' JsonValue JsonValue := ...

-- Compose for deep access
let path := field "users" ∘ _array ∘ traversed ∘ field "name" ∘ _string
data ^.. path                              -- ["Alice", "Bob", ...]
```

### Configuration Updates

```lean
def applyDevConfig (config : AppConfig) : AppConfig :=
  config
    & (database ∘ host) .~ "localhost"
    & (logging ∘ level) .~ "debug"
    & (cache ∘ enabled) .~ false

def scaleUp (factor : Nat) (config : AppConfig) : AppConfig :=
  config
    & (database ∘ maxConnections) %~ (· * factor)
    & (cache ∘ maxSize) %~ (· * factor)
```

### Recursive Structures (Plated)

```lean
import Collimator.Combinators

-- For types with recursive structure
instance : Plated Expr where
  plate := traversal fun f e => match e with
    | .add a b => .add <$> f a <*> f b
    | .mul a b => .mul <$> f a <*> f b
    | other => pure other

-- Transform bottom-up
transform simplify expr

-- Collect all subexpressions
universeList expr
```

## Import Guide

```lean
-- Full prelude (recommended)
import Collimator.Prelude

-- Or selective imports:
import Collimator.Optics       -- Core optic types and operations
import Collimator.Operators    -- Infix operators (^., %~, .~, etc.)
import Collimator.Combinators  -- _head, _last, filtered, Plated, etc.
import Collimator.Instances    -- List.traversed, Option.somePrism', etc.
import Collimator.Derive.Lenses -- makeLenses command
```

## Build Commands

```bash
cd data/collimator
lake build
lake build collimator_tests && .lake/build/bin/collimator_tests
```
