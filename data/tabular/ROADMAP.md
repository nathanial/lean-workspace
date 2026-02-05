# Roadmap

This document outlines potential improvements, new features, and code cleanup opportunities for the Tabular library.

## Feature Proposals

### [Priority: High] Streaming/Lazy Row Iterator

**Description:** Add support for lazily parsing CSV rows without loading the entire file into memory.

**Rationale:** Currently, `parse` reads the entire input string and produces all rows at once. For large CSV files (hundreds of MB or GB), this can cause memory issues. A streaming API would allow processing one row at a time.

**Proposed API:**
```lean
def parseStream (reader : IO.FS.Handle) (config : Config) : IO (Stream Row)
def forEachRow (input : String) (config : Config) (f : Row → IO Unit) : IO Unit
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Parser/Document.lean`
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: High] File I/O Integration

**Description:** Add convenience functions to parse CSV directly from file paths.

**Rationale:** Currently users must read the file themselves and pass the string to `parse`. File-based parsing is the most common use case.

**Proposed API:**
```lean
def parseFile (path : System.FilePath) (config : Config := Config.csv) : IO Table
def parseFileRows (path : System.FilePath) (config : Config) : IO (Array Row)
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular.lean` (add new module)
- New file: `Tabular/IO.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: High] CSV Writing/Serialization

**Description:** Add the ability to write `Table` and rows back to CSV format.

**Rationale:** A complete CSV library should support both reading and writing. This enables round-trip operations and data export.

**Proposed API:**
```lean
class ToCsv (α : Type) where
  toCsv : α → String

def Table.toCsv (t : Table) (config : Config := Config.csv) : String
def Row.toCsv (r : Row) (delimiter : Char := ',') : String
def writeFile (path : System.FilePath) (table : Table) (config : Config) : IO Unit
```

**Affected Files:**
- New file: `Tabular/Write.lean`
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Typed Row/Record Deserialization

**Description:** Add a typeclass-based approach for deserializing entire rows into user-defined structures.

**Rationale:** Currently users must extract each column individually. A `FromRow` typeclass would allow automatic deserialization of entire rows into custom types.

**Proposed API:**
```lean
class FromRow (α : Type) where
  fromRow : Row → ExtractResult α

-- With deriving handler:
structure Person derives FromRow where
  name : String
  age : Int
  active : Bool

def Table.extractAll [FromRow α] (t : Table) : ExtractResult (Array α)
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Extract.lean`
- New file: `Tabular/Derive.lean` (for deriving handler)

**Estimated Effort:** Large

**Dependencies:** None

---

### [Priority: Medium] Column Type Inference

**Description:** Analyze column values to suggest/infer column types.

**Rationale:** Useful for exploratory data analysis and schema discovery. Could suggest whether columns are numeric, boolean, date, etc.

**Proposed API:**
```lean
inductive InferredType where
  | string | int | float | bool | date | empty | mixed

def Table.inferColumnTypes (t : Table) : Array (String × InferredType)
def Table.columnStats (t : Table) (idx : Nat) : ColumnStats
```

**Affected Files:**
- New file: `Tabular/Infer.lean`
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Date/Time Parsing Support

**Description:** Add `FromCsv` instances for date and time types.

**Rationale:** Date columns are very common in CSV data. Currently users must parse dates manually.

**Proposed API:**
```lean
instance : FromCsv Chronos.DateTime where ...
instance : FromCsv Chronos.Timestamp where ...

-- With configurable date formats
def Row.getDateAs (row : Row) (name : String) (format : String) : ExtractResult DateTime
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Extract.lean`
- `/Users/Shared/Projects/lean-workspace/data/tabular/lakefile.lean` (add chronos dependency)

**Estimated Effort:** Medium

**Dependencies:** chronos library

---

### [Priority: Medium] Table Transformation Operations

**Description:** Add common table manipulation operations like select, filter, map, sort.

**Rationale:** Users often need to transform data after parsing. Basic operations would reduce boilerplate.

**Proposed API:**
```lean
def Table.select (t : Table) (columns : Array String) : Table
def Table.filter (t : Table) (pred : Row → Bool) : Table
def Table.map (t : Table) (f : Row → Row) : Table
def Table.sortBy [Ord α] [FromCsv α] (t : Table) (column : String) : Table
def Table.take (t : Table) (n : Nat) : Table
def Table.drop (t : Table) (n : Nat) : Table
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Core/Table.lean`
- New file: `Tabular/Transform.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] BOM (Byte Order Mark) Handling

**Description:** Detect and skip UTF-8 BOM at the start of CSV files.

**Rationale:** Many tools (especially Excel on Windows) prepend a BOM to CSV files. The current parser would include the BOM in the first header name, causing lookup failures.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Parser/Document.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Medium] Comment Line Support

**Description:** Add configuration option to skip comment lines (lines starting with # or other configurable character).

**Rationale:** Some CSV files contain comment lines for documentation or metadata. These should be skippable.

**Proposed Config Addition:**
```lean
structure Config where
  ...
  commentChar : Option Char := none  -- e.g., some '#'
```

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Core/Config.lean`
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Parser/Document.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Low] Excel XLSX Support

**Description:** Add support for reading Excel .xlsx files.

**Rationale:** Many datasets are distributed as Excel files. However, this would require significant FFI work or a pure-Lean XML/ZIP parser.

**Affected Files:**
- New module: `Tabular/Excel/`

**Estimated Effort:** Large

**Dependencies:** XML parser, ZIP decompression

---

### [Priority: Low] JSON Output

**Description:** Add ability to convert Table/Rows to JSON format.

**Rationale:** JSON is a common interchange format. This would enable easy integration with web APIs.

**Affected Files:**
- New file: `Tabular/Json.lean`

**Estimated Effort:** Small

**Dependencies:** None (use Lean.Json or simple string building)

---

### [Priority: Low] SQL Table Generation

**Description:** Generate CREATE TABLE SQL statements from inferred CSV schema.

**Rationale:** Useful for database import workflows. Could integrate with the chisel library.

**Affected Files:**
- New file: `Tabular/Schema.lean`

**Estimated Effort:** Small

**Dependencies:** Type inference feature, optionally chisel library

---

## Code Improvements

### [Priority: High] Fix Deprecated String.get Usage

**Current State:** The parser uses `String.get` which is deprecated in Lean 4.26.0.

**Proposed Change:** Update to use the recommended `String.Pos.Raw.get` or `s[pos]` syntax.

**Benefits:** Eliminates deprecation warnings, ensures compatibility with future Lean versions.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Parser/State.lean` (lines 42, 55)

**Estimated Effort:** Small

---

### [Priority: High] Replace String Concatenation with StringBuilder

**Current State:** The parser uses `result := result.push c` in loops for building strings, which creates O(n^2) string allocations.

**Proposed Change:** Use a `String.Builder` or accumulate into an array and join at the end.

**Benefits:** Significant performance improvement for large fields and files.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Parser/Primitives.lean` (readWhile function, line 25-26)
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Parser/Field.lean` (parseQuotedField, parseUnquotedField)

**Estimated Effort:** Small

---

### [Priority: Medium] Add Inline Annotations for Performance

**Current State:** Hot path functions like `peek?`, `next`, `atFieldEnd` are not marked inline.

**Proposed Change:** Add `@[inline]` annotations to frequently called parser primitives.

**Benefits:** Reduced function call overhead in parsing hot paths.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Parser/State.lean`
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Parser/Primitives.lean`
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Parser/Field.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Improve Float Parsing

**Current State:** The `parseFloat?` function manually parses float strings with a custom algorithm that doesn't support scientific notation (1e10, 1.5e-3).

**Proposed Change:** Either support scientific notation or use Lean's built-in float parsing if available.

**Benefits:** Better compatibility with common CSV float formats.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Extract.lean` (parseFloat? function, lines 34-74)

**Estimated Effort:** Medium

---

### [Priority: Medium] Error Context Enhancement

**Current State:** Some error messages lack context about which row or column caused the error.

**Proposed Change:** Add row number to `ExtractError` variants and include more context in error messages.

**Proposed Enhancement:**
```lean
inductive ExtractError where
  | typeConversion (value : String) (targetType : String) (rowNum : Option Nat := none)
  | columnNotFound (name : String) (availableColumns : Array String := #[])
  ...
```

**Benefits:** Easier debugging when parsing large files.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Core/Error.lean`
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Extract.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Unify Result Types

**Current State:** The library uses both `ParseResult` and `ExtractResult` as separate type aliases for `Except`.

**Proposed Change:** Consider a unified error type or at least ensure clean conversion between them.

**Benefits:** Simpler error handling for users who want to chain parsing and extraction.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Core/Error.lean`
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Add Functor/Monad Instances for Table

**Current State:** Table is a plain structure with no typeclass instances beyond Repr.

**Proposed Change:** Add useful instances for functional operations.

**Proposed Instances:**
```lean
instance : Functor (fun α => Table) where ...  -- Map over rows
instance : ForIn IO Table Row where ...        -- For-in loop support
```

**Benefits:** More idiomatic Lean usage, better integration with standard library patterns.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Core/Table.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Use Subarray for Parsing

**Current State:** The parser tracks position as a `Nat` offset into the string.

**Proposed Change:** Consider using `Substring` or a more efficient byte-level parsing approach.

**Benefits:** Potential performance improvement for large files.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Parser/State.lean`

**Estimated Effort:** Medium

---

## Code Cleanup

### [Priority: High] Add Module Documentation

**Issue:** Most modules have minimal doc comments. The main `Tabular.lean` has good examples but individual modules lack API documentation.

**Location:** All files in `Tabular/Core/` and `Tabular/Parser/`

**Action Required:**
1. Add docstrings to all public functions
2. Add module-level documentation explaining purpose and usage
3. Add examples for key API functions

**Estimated Effort:** Medium

---

### [Priority: Medium] Standardize Error Handling in Tests

**Issue:** Test error handling uses inconsistent patterns - some use `throw (IO.userError ...)`, others use `ensure`.

**Location:**
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tests/ParserTests.lean`
- `/Users/Shared/Projects/lean-workspace/data/tabular/Tests/ExtractTests.lean`

**Action Required:** Standardize on Crucible's `shouldBe`, `shouldSatisfy`, and similar assertion helpers.

**Estimated Effort:** Small

---

### [Priority: Medium] Add Property-Based Tests

**Issue:** Current tests are example-based only. Property-based tests would provide better coverage.

**Location:** `/Users/Shared/Projects/lean-workspace/data/tabular/Tests/`

**Action Required:**
1. Add dependency on plausible (property-based testing library)
2. Add properties like:
   - Round-trip: parse(render(table)) == table
   - Escaped quotes always produce valid output
   - Column count consistency

**Estimated Effort:** Medium

---

### [Priority: Medium] Add Edge Case Tests

**Issue:** Some RFC 4180 edge cases may not be fully tested.

**Location:** `/Users/Shared/Projects/lean-workspace/data/tabular/Tests/ParserTests.lean`

**Action Required:** Add tests for:
- CRLF line endings (currently only LF tested explicitly)
- Trailing commas creating empty last column
- Empty rows in middle of file
- Very long fields (stress test)
- Unicode characters in quoted/unquoted fields
- BOM handling (currently unsupported)
- Fields with only whitespace

**Estimated Effort:** Small

---

### [Priority: Low] Extract Parser Utilities

**Issue:** The `readWhile` and similar utilities in `Primitives.lean` could be useful beyond CSV parsing.

**Location:** `/Users/Shared/Projects/lean-workspace/data/tabular/Tabular/Parser/Primitives.lean`

**Action Required:** Consider extracting to a shared parser combinator library or documenting as internal-only.

**Estimated Effort:** Small

---

### [Priority: Low] Add Benchmarks

**Issue:** No performance benchmarks exist.

**Location:** New directory: `Bench/`

**Action Required:**
1. Create benchmark suite with various CSV sizes
2. Measure parsing speed (rows/second)
3. Measure memory usage
4. Compare different field types (quoted vs unquoted)

**Estimated Effort:** Medium

---

### [Priority: Low] README Documentation

**Issue:** No README.md file exists in the project root.

**Location:** `/Users/Shared/Projects/lean-workspace/data/tabular/README.md`

**Action Required:** Create README with:
- Project description
- Installation instructions
- Quick start examples
- API overview
- Configuration options
- Comparison with alternatives

**Estimated Effort:** Small

---

## Summary

### High Priority Items
1. Fix deprecated `String.get` usage (immediate - causes warnings)
2. Streaming/lazy row iterator (scalability for large files)
3. File I/O integration (common use case)
4. CSV writing/serialization (complete the read/write cycle)
5. Add module documentation (maintainability)
6. Replace string concatenation with StringBuilder (performance)

### Quick Wins (Small Effort, Good Value)
- File I/O integration
- BOM handling
- Comment line support
- Fix deprecation warnings
- Add inline annotations
- Error context enhancement

### Major Features (Larger Effort)
- Typed row deserialization with deriving
- Table transformation operations
- Excel XLSX support
