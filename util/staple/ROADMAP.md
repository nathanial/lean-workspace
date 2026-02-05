# Roadmap

This document tracks potential improvements, new features, and code cleanup opportunities for the Staple utilities library.

## Feature Proposals

### [Status: COMPLETED] Hex Encoding/Decoding Utilities (Staple.Hex)

**Implemented in:** `Staple/Hex.lean`

Provides hex encoding and decoding utilities for characters, bytes, and byte arrays.

**API:**
- `hexCharToNat : Char → Option Nat` - Convert hex char to numeric value
- `nibbleToHexChar : Nat → Char` - Convert 0-15 to hex char
- `isHexDigit : Char → Bool` - Check if valid hex digit
- `hexPairToUInt8 : Char → Char → Option UInt8` - Parse two hex chars as byte
- `uint8ToHex : UInt8 → String` - Encode byte as two hex chars
- `ByteArray.toHex : ByteArray → String` - Encode bytes as hex string
- `ByteArray.fromHex : String → Option ByteArray` - Decode hex string to bytes
- `hexByteToNat : UInt8 → Option Nat` - UInt8 variant of hexCharToNat
- `isHexDigitByte : UInt8 → Bool` - UInt8 variant of isHexDigit

**TODO comments added to:**
- `util/tracer/Tracer/Core/TraceId.lean`
- `util/tracer/Tracer/Core/SpanId.lean`
- `graphics/tincture/Tincture/Parse.lean`
- `data/chisel/Chisel/Parser/Lexer.lean`
- `data/totem/Totem/Parser/Primitives.lean`
- `web/herald/Herald/Parser/Primitives.lean`

---

### [Status: COMPLETED] ASCII Character Classification (Staple.Ascii)

**Implemented in:** `Staple/Ascii.lean`

Provides comprehensive ASCII character classification and case conversion utilities.

**API:**
- `isWhitespace : Char → Bool` - space, tab, newline, carriage return
- `isAlpha : Char → Bool` - a-z, A-Z
- `isDigit : Char → Bool` - 0-9
- `isAlphaNum : Char → Bool` - alpha or digit
- `isOctalDigit : Char → Bool` - 0-7
- `isBinaryDigit : Char → Bool` - 0-1
- `isPrintable : Char → Bool` - 0x20-0x7E
- `toLower : Char → Char` - uppercase to lowercase
- `toUpper : Char → Char` - lowercase to uppercase
- `String.toLowerAscii : String → String` - convert string to lowercase
- `String.toUpperAscii : String → String` - convert string to uppercase
- `isDigitByte : UInt8 → Bool` - byte variant
- `isAlphaByte : UInt8 → Bool` - byte variant
- `isWhitespaceByte : UInt8 → Bool` - byte variant

**Candidates for TODO comments:**
- `web/markup/Markup/Core/Ascii.lean`
- `data/totem/Totem/Parser/Primitives.lean`
- `web/herald/Herald/Parser/Primitives.lean`

---

### [Status: COMPLETED] String Padding Utilities

**Implemented in:** `Staple/String.lean`

Added string padding and trimming utilities.

**API:**
- `String.padLeft : String → Nat → Char → String` - left-pad to width (default: space)
- `String.padRight : String → Nat → Char → String` - right-pad to width (default: space)
- `String.dropRightWhile : String → (Char → Bool) → String` - trim from right
- `String.dropLeftWhile : String → (Char → Bool) → String` - trim from left
- `String.containsSubstr : String → String → Bool` - substring search (existing)

**Candidates for TODO comments:**
- `data/totem/Totem/Core/Value.lean`
- `graphics/arbor/Arbor/Text/Renderer.lean`

---

### [Priority: Medium] Conversion Utilities (Staple.Conversion)

**Description:** Add common type conversion utilities.

**Rationale:** Several projects implement similar conversion patterns:

| Project | Location |
|---------|----------|
| chisel | `Chisel/Parser/Lexer.lean:91-93` |
| terminus | `Terminus/Widgets/BigText.lean:17-18` |

**Proposed API:**
```lean
namespace Staple

/-- Convert a list of characters to a string efficiently. -/
def String.ofCharList (cs : List Char) : String

/-- Convert a list to an array. -/
def Array.ofList {α : Type} (xs : List α) : Array α

end Staple
```

**Affected Files:**
- `Staple/Conversion.lean` (new file)
- `Staple.lean` (add import)

**Estimated Effort:** Small

---

### [Priority: Medium] JSON Unescape Function

**Description:** Add `unescapeString` as complement to existing `escapeString`.

**Rationale:** Projects doing JSON parsing (loom, oracle, homebase-app) need to unescape JSON strings. Currently only escaping is provided.

**Proposed API:**
```lean
namespace Staple.Json

/-- Unescape a JSON string value, handling \\", \\\\, \\n, \\r, \\t, \\uXXXX. -/
def unescapeString (s : String) : Option String

end Staple.Json
```

**Affected Files:**
- `Staple/Json.lean`

**Estimated Effort:** Small

---

### [Status: COMPLETED] include_bytes% Macro for Binary File Embedding

**Implemented in:** `Staple/IncludeBytes.lean`

Companion macro to `include_str%` that embeds binary files as `ByteArray` at compile time.

**API:**
- `include_bytes% "path/to/file"` - embed binary file as ByteArray literal

**Usage:**
```lean
def myIcon : ByteArray := include_bytes% "assets/icon.png"
```

---

### [Status: COMPLETED] Additional ToJsonStr Instances

**Implemented in:** `Staple/Json.lean`

Expanded the `ToJsonStr` typeclass with instances for commonly used types.

**New instances:**
- `Option α` - renders as `null` or the wrapped value
- `Array α` - renders as JSON array
- `List α` - renders as JSON array
- `UInt8`, `UInt16`, `UInt32` - numeric types
- `Int8`, `Int16`, `Int32`, `Int64` - signed integer types

---

### [Status: COMPLETED] Test Suite

**Implemented in:** `Tests.lean`, `Tests/Hex.lean`, `Tests/Ascii.lean`, `Tests/String.lean`, `Tests/Json.lean`

Comprehensive Crucible test suite with 47 tests covering all modules.

---

### [Priority: Medium] Additional String Utilities

**Description:** Add string manipulation functions beyond padding (see String Padding Utilities above).

**Rationale:** Analysis of the workspace shows repeated patterns that could be consolidated.

**Proposed Functions:**
- `String.splitFirst : String -> String -> Option (String × String)` - split at first occurrence
- `String.splitLast : String -> String -> Option (String × String)` - split at last occurrence
- `String.removePrefix : String -> String -> String` - remove prefix if present
- `String.removeSuffix : String -> String -> String` - remove suffix if present
- `String.truncate : String -> Nat -> String -> String` - truncate with ellipsis

**Affected Files:**
- `Staple/String.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] include_dir% Macro for Directory Embedding

**Description:** Add a macro that embeds all files from a directory as an `Array (String x String)` of (filename, contents) pairs.

**Rationale:** Projects like afferent embed multiple shader files individually. A directory embedding macro would simplify this pattern.

**Affected Files:**
- `Staple/IncludeDir.lean` (new file)
- `Staple.lean` (add import)

**Estimated Effort:** Medium

**Implementation Notes:**
```lean
-- Proposed API
def shaders : Array (String x String) := include_dir% "shaders/"
-- Returns: #[("basic.metal", "..."), ("text.metal", "..."), ...]
```

---

### [Priority: Medium] Result/Either Type and Utilities

**Description:** Add a polymorphic `Result` type with common combinators.

**Rationale:** While Lean has `Except`, a lightweight `Result` type with ergonomic combinators would be useful for error handling in pure code without the full `ExceptT` machinery.

**Proposed API:**
- `Result.map`, `Result.mapError`
- `Result.flatMap`, `Result.flatten`
- `Result.toOption`, `Result.fromOption`
- `Result.unwrapOr`, `Result.unwrapOrElse`
- `Result.isOk`, `Result.isErr`

**Affected Files:**
- `Staple/Result.lean` (new file)
- `Staple.lean` (add import)

**Estimated Effort:** Small

---

### [Priority: Low] Memoization Utilities

**Description:** Add simple memoization helpers for pure functions.

**Rationale:** Several projects perform repeated computations that could benefit from memoization. A simple caching utility would reduce boilerplate.

**Affected Files:**
- `Staple/Memo.lean` (new file)
- `Staple.lean` (add import)

**Estimated Effort:** Medium

---

### [Priority: Low] Debug/Trace Utilities

**Description:** Add debugging helpers that can be easily enabled/disabled.

**Rationale:** Consistent debugging patterns across projects would improve development experience.

**Proposed Functions:**
- `dbgTrace : String -> α -> α` (conditional based on compile flag)
- `dbgTime : String -> IO α -> IO α` (timing wrapper)
- `assertM : Bool -> String -> m Unit` (monadic assertion)

**Affected Files:**
- `Staple/Debug.lean` (new file)
- `Staple.lean` (add import)

**Estimated Effort:** Small

---

## Code Improvements

### [Priority: High] Optimize String.containsSubstr Implementation

**Current State:** The current implementation uses `splitOn` which allocates a list of substrings just to check for existence:
```lean
def String.containsSubstr (haystack needle : String) : Bool :=
  (haystack.splitOn needle).length > 1
```

**Proposed Change:** Use a more efficient substring search that returns early without allocating:
```lean
def String.containsSubstr (haystack needle : String) : Bool :=
  haystack.findSubstr? needle |>.isSome
-- Or implement a direct Boyer-Moore/KMP if findSubstr? doesn't exist
```

**Benefits:** Reduced memory allocations, faster early termination on match.

**Affected Files:**
- `Staple/String.lean`

**Estimated Effort:** Small

---

### [Status: COMPLETED] Add Error Handling to include_str% and include_bytes%

**Implemented in:** `Staple/IncludeStr.lean`, `Staple/IncludeBytes.lean`

Both macros now check if the file exists before attempting to read, providing a clear error message with:
- The resolved file path
- The original path argument
- The source file location

Tests added in `Tests/Include.lean` (4 tests).

---

### [Priority: Medium] escapeString Performance

**Current State:** The `escapeString` function in `Json.lean` iterates character-by-character and builds up a string with repeated concatenation.

**Proposed Change:** Use a more efficient approach:
- Pre-scan to determine if escaping is needed at all
- Use `String.Builder` or array-based accumulation
- Handle the common case (no escaping needed) with an early return

**Benefits:** Improved performance for JSON generation in hot paths.

**Affected Files:**
- `Staple/Json.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Consolidate Duplicate escapeString Implementations

**Current State:** Multiple projects have their own `escapeString` implementations:
- `Staple/Json.lean`
- `Chisel/Core/Literal.lean`
- `Ledger/Persist/JSON.lean`

**Proposed Change:** Export `Staple.Json.escapeString` more prominently and update other projects to use it.

**Benefits:** Reduced code duplication, single source of truth for JSON escaping.

**Affected Files:**
- `Staple/Json.lean` (documentation)
- External projects (chisel, ledger) would need updates

**Estimated Effort:** Small (Staple changes) + Medium (coordinating downstream)

---

## Code Cleanup

### [Priority: High] Update Documentation for New Modules

**Issue:** The CLAUDE.md and README.md only document `IncludeStr.lean` but the library now includes all modules.

**Location:**
- `/Users/Shared/Projects/lean-workspace/util/staple/CLAUDE.md`
- `/Users/Shared/Projects/lean-workspace/util/staple/README.md`

**Action Required:**
1. Update CLAUDE.md project structure to list all modules
2. Update README.md to document all features
3. Add usage examples for all features

**Estimated Effort:** Small

---

### [Status: COMPLETED] Add Test Suite

**Implemented in:** `Tests.lean`, `Tests/*.lean`

Added Crucible test framework with 47 tests covering:
- Hex encoding/decoding (10 tests)
- ASCII classification and case conversion (14 tests)
- String padding and trimming (9 tests)
- JSON escaping and ToJsonStr instances (14 tests)

All tests passing (100%).

---

### [Priority: Medium] Add Module-Level Documentation

**Issue:** The modules have brief header comments but lack comprehensive documentation for the public API.

**Location:**
- `Staple/IncludeStr.lean`
- `Staple/String.lean`
- `Staple/Json.lean`

**Action Required:**
1. Add docstrings to all public functions
2. Add module-level documentation with examples
3. Consider adding a `#check` example block

**Estimated Effort:** Small

---

### [Priority: Low] Namespace Consistency

**Issue:** The library uses mixed namespace patterns:
- `include_str%` is defined in `Staple` namespace (good, short access)
- `jsonStr!` is defined outside namespace (in `Staple.Json`)
- `String.containsSubstr` is defined in `Staple` namespace

**Location:**
- `Staple/IncludeStr.lean`
- `Staple/String.lean`
- `Staple/Json.lean`

**Action Required:**
1. Decide on consistent namespace strategy
2. Either move all macros to root for ergonomic access, or document the full paths
3. Consider re-exporting common functions in the root `Staple` namespace

**Estimated Effort:** Small

---

## Architecture Considerations

### Tier 0 Dependency Status

Staple is a Tier 0 (leaf) dependency with no external requirements. This is intentional and should be preserved. Any new features should:

1. Not add external dependencies
2. Remain focused on compile-time utilities and essential helpers
3. Avoid domain-specific functionality that belongs in specialized libraries

### Downstream Impact

As of the analysis, 15 projects depend on staple:
- apps: homebase-app, enchiridion
- graphics: arbor, raster, grove, tincture, afferent
- web: loom, citadel
- data: chisel, ledger, quarry
- network: wisp
- util: docgen, parlance

Any breaking changes require coordinated updates across all downstream projects.

### Feature Boundary Guidelines

**Should be in Staple:**
- Compile-time macros (`include_str%`, `include_bytes%`)
- Universal string utilities
- Basic JSON string generation
- General-purpose debugging helpers

**Should NOT be in Staple:**
- Parsing logic (belongs in specialized parsers)
- I/O utilities beyond file embedding
- Type-specific serialization (belongs in domain libraries)
- Complex data structures (belongs in batteries or specialized libs)
