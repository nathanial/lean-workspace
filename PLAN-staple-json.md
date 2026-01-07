# Plan: Staple JSON - Canonical JSON Library for Lean Workspace

## Goal

Flesh out `Staple.Json` to be the single canonical JSON serialization/deserialization solution across all workspace projects, with support for:
- Round-trip serialization (ToJson + FromJson)
- Configurable field naming (snake_case, camelCase, etc.)
- Deriving macros for automatic implementation
- Full JSON spec compliance

## Current State

### What Staple.Json Has
- `escapeString` - proper JSON escaping with control character handling
- `ToJsonStr` typeclass - serializes values directly to JSON strings
- Base type instances: String, Nat, Int, Bool, Float, UInt*, Int*, Option, Array, List
- `jsonStr!` macro - convenient object literal syntax
- `buildJsonObject` - builds JSON from key-value pairs

### What's Missing
1. **Deserialization** - no `FromJson` equivalent
2. **JSON AST** - no intermediate representation for parsing
3. **Deriving support** - manual instances required for every type
4. **Field naming options** - always uses Lean field names verbatim
5. **Enum support** - no pattern for serializing inductives
6. **Error handling** - no structured parse errors

### Projects Needing Migration
| Project | Current Approach | Files |
|---------|------------------|-------|
| tracker | 3x manual `escapeJson`, string interpolation | `Tracker/Core/Types.lean` |
| chronicle | 1x manual `escapeJson` | `Chronicle/Format.lean` |
| stencil | Incomplete manual escaping | `Stencil/Core/Value.lean` |
| chronos | `Lean.ToJson`/`FromJson` | `Timestamp.lean`, `DateTime.lean`, `Duration.lean` |
| ask | `Lean.ToJson`/`FromJson` | `History.lean` |
| enchiridion | `Lean.ToJson`/`FromJson` | Multiple model files |
| oracle | `Lean.ToJson`/`FromJson` | Request/Response types |
| docgen | `Lean.ToJson`/`FromJson` | `Render/Search.lean` |

---

## Design

### Core Types

```lean
namespace Staple.Json

/-- JSON value AST -/
inductive Value where
  | null
  | bool (b : Bool)
  | num (n : JsonNumber)  -- Or use Float + Int union
  | str (s : String)
  | arr (items : Array Value)
  | obj (fields : Array (String × Value))
  deriving Repr, BEq, Inhabited

/-- Numeric representation supporting both Int and Float -/
structure JsonNumber where
  mantissa : Int
  exponent : Int := 0
  deriving Repr, BEq

end Staple.Json
```

### Serialization Typeclasses

```lean
/-- Serialize a value to JSON AST -/
class ToJson (α : Type) where
  toJson : α → Value

/-- Deserialize a value from JSON AST -/
class FromJson (α : Type) where
  fromJson? : Value → Except String α

/-- Configuration for field naming in derived instances -/
inductive FieldNaming where
  | preserve      -- Use Lean field names as-is
  | camelCase     -- firstName -> firstName (default Lean style)
  | snakeCase     -- firstName -> first_name
  | kebabCase     -- firstName -> first-name
  | screamingSnake -- firstName -> FIRST_NAME
```

### Deriving Macros

```lean
-- Basic deriving (uses preserve naming)
structure Issue where
  id : Nat
  title : String
  blockedBy : Array Nat
  deriving Staple.Json.ToJson, Staple.Json.FromJson

-- With options via attribute
@[json snakeCase]
structure Issue where
  id : Nat
  title : String
  blockedBy : Array Nat  -- Serializes as "blocked_by"
  deriving Staple.Json.ToJson, Staple.Json.FromJson

-- Custom field names via attribute
structure Issue where
  id : Nat
  @[jsonField "blocked_by"] blockedBy : Array Nat
  deriving Staple.Json.ToJson, Staple.Json.FromJson
```

### Enum Serialization

```lean
/-- Strategy for serializing inductives -/
inductive EnumStyle where
  | string           -- Serialize as string: .low -> "low"
  | stringTransform  -- Apply naming transform: .inProgress -> "in-progress" (kebab)
  | object           -- Serialize as {"tag": "low"} or {"tag": "some", "value": x}
  | adjacentTag      -- {"type": "some", "contents": x}

-- Example with custom strings
inductive Status where
  | open_
  | inProgress
  | closed

@[json stringTransform kebabCase]
-- or manual:
instance : ToJson Status where
  toJson
    | .open_ => .str "open"
    | .inProgress => .str "in-progress"
    | .closed => .str "closed"
```

### Output Functions

```lean
/-- Render JSON to compact string -/
def Value.compress : Value → String

/-- Render JSON to pretty-printed string -/
def Value.pretty (indent : Nat := 2) : Value → String

/-- Direct serialization to string (for compatibility) -/
def toJsonString [ToJson α] (a : α) : String :=
  (toJson a).compress
```

---

## Implementation Plan

### Phase 1: Core Types and Parsing
**Files:** `Staple/Json/Value.lean`, `Staple/Json/Parse.lean`

1. Define `Value` inductive (JSON AST)
2. Define `JsonNumber` for numeric precision
3. Implement JSON parser (`String → Except String Value`)
4. Implement `Value.compress` (compact output)
5. Implement `Value.pretty` (formatted output)
6. Add comprehensive test suite

### Phase 2: Serialization Typeclasses
**Files:** `Staple/Json/ToJson.lean`, `Staple/Json/FromJson.lean`

1. Define `ToJson` typeclass
2. Define `FromJson` typeclass
3. Implement instances for base types:
   - Primitives: Bool, Nat, Int, Float, String
   - Integers: UInt8/16/32/64, Int8/16/32/64
   - Containers: Option, Array, List
   - Maps: (later) AssocList, HashMap
4. Port existing `ToJsonStr` instances to new system
5. Maintain backward compatibility with `ToJsonStr`

### Phase 3: Field Naming
**Files:** `Staple/Json/Naming.lean`

1. Implement `FieldNaming` enum
2. Implement naming transform functions:
   - `toSnakeCase : String → String`
   - `toCamelCase : String → String`
   - `toKebabCase : String → String`
   - `toScreamingSnake : String → String`
3. Add tests for edge cases (acronyms, numbers, etc.)

### Phase 4: Deriving Macros
**Files:** `Staple/Json/Derive.lean`

1. Implement `deriving ToJson` for structures
2. Implement `deriving FromJson` for structures
3. Add `@[json <naming>]` attribute for struct-level config
4. Add `@[jsonField "name"]` attribute for field-level override
5. Implement enum deriving with configurable style
6. Handle nested types and recursive structures

### Phase 5: Migration Helpers
**Files:** `Staple/Json/Compat.lean`

1. Bridge to/from `Lean.Json` for interop
2. Deprecation warnings for old `ToJsonStr` usage
3. Migration guide documentation

### Phase 6: Project Migrations
Migrate each project to use `Staple.Json`:

1. **tracker** - Replace 3 `escapeJson` + manual toJson with deriving
2. **chronicle** - Replace manual escaping
3. **stencil** - Fix incomplete escaping, use ToJson
4. **chronos** - Migrate from Lean.ToJson
5. **ask** - Migrate from Lean.ToJson
6. **enchiridion** - Migrate from Lean.ToJson
7. **oracle** - Migrate from Lean.ToJson
8. **docgen** - Migrate from Lean.ToJson

---

## API Examples

### Basic Usage

```lean
import Staple.Json

structure User where
  id : Nat
  name : String
  email : Option String
  deriving Staple.Json.ToJson, Staple.Json.FromJson

def user := { id := 1, name := "Alice", email := some "alice@example.com" }

-- Serialize
#eval Staple.Json.toJsonString user
-- {"id": 1, "name": "Alice", "email": "alice@example.com"}

-- Parse and deserialize
#eval do
  let json ← Staple.Json.parse "{\"id\": 2, \"name\": \"Bob\", \"email\": null}"
  let user : User ← Staple.Json.fromJson? json
  return user.name
-- "Bob"
```

### Snake Case Fields

```lean
@[json snakeCase]
structure Issue where
  id : Nat
  createdAt : String
  blockedBy : Array Nat
  deriving Staple.Json.ToJson, Staple.Json.FromJson

-- Serializes to: {"id": 1, "created_at": "2024-01-01", "blocked_by": [2, 3]}
```

### Custom Enum Strings

```lean
inductive Priority where
  | low | medium | high | critical
  deriving Staple.Json.ToJson, Staple.Json.FromJson
-- Default: "low", "medium", "high", "critical"

@[json kebabCase]
inductive Status where
  | open_
  | inProgress
  | closed
  deriving Staple.Json.ToJson, Staple.Json.FromJson
-- Produces: "open", "in-progress", "closed"
```

### Mixed Custom Fields

```lean
structure ApiResponse where
  @[jsonField "user_id"] userId : Nat
  @[jsonField "created_at"] createdAt : String
  data : Value  -- Raw JSON passthrough
  deriving Staple.Json.ToJson, Staple.Json.FromJson
```

---

## File Structure

```
Staple/
├── Json.lean                 # Re-exports all JSON modules
├── Json/
│   ├── Value.lean            # JSON AST type
│   ├── Number.lean           # JsonNumber type
│   ├── Parse.lean            # JSON parser
│   ├── Render.lean           # compress/pretty output
│   ├── ToJson.lean           # ToJson typeclass + instances
│   ├── FromJson.lean         # FromJson typeclass + instances
│   ├── Naming.lean           # Field naming transforms
│   ├── Derive.lean           # Deriving macros
│   └── Compat.lean           # Lean.Json bridge
```

---

## Success Criteria

1. All 8 projects using single `Staple.Json` implementation
2. Zero manual `escapeJson` functions in workspace
3. All types use `deriving` where possible
4. snake_case support working for tracker's `blocked_by` field
5. Round-trip tests passing for all migrated types
6. No regression in JSON output format (existing APIs stable)

---

## Open Questions

1. **JsonNumber precision**: Use `Int × Int` (mantissa/exponent) or `Float`?
   - Recommendation: Support both via union, default to Int for whole numbers

2. **Lean.Json interop**: Full bridge or one-way conversion?
   - Recommendation: Two-way bridge in Compat module for gradual migration

3. **Streaming support**: Should we support streaming parse/render?
   - Recommendation: Not in v1, add later if needed for large documents

4. **Schema validation**: Add JSON Schema support?
   - Recommendation: Out of scope for initial implementation
