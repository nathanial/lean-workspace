# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Staple is a Lean 4 utilities library providing commonly-used macros and helpers for other projects in the workspace.

## Build Commands

```bash
lake build    # Build the library
lake test     # Run test suite (51 tests)
```

## Project Structure

```
staple/
├── lakefile.lean         # Lake build configuration
├── lean-toolchain        # Lean version (v4.16.0)
├── Staple.lean           # Root module (imports all submodules)
├── Staple/
│   ├── Ascii.lean        # ASCII character classification
│   ├── Hex.lean          # Hex encoding/decoding
│   ├── IncludeBytes.lean # Compile-time binary file embedding
│   ├── IncludeStr.lean   # Compile-time string file embedding
│   ├── Json.lean         # JSON string generation
│   └── String.lean       # String utilities
├── Tests.lean            # Test entry point
└── Tests/
    ├── Ascii.lean        # ASCII tests
    ├── Hex.lean          # Hex tests
    ├── Include.lean      # include_str%/include_bytes% tests
    ├── Json.lean         # JSON tests
    ├── String.lean       # String tests
    └── fixtures/         # Test fixture files
```

## Key Modules

### Staple.Ascii

ASCII character classification and case conversion:

```lean
import Staple.Ascii
open Staple.Ascii

#eval isWhitespace ' '     -- true
#eval isAlpha 'a'          -- true
#eval isDigit '5'          -- true
#eval toLower 'A'          -- 'a'
#eval "HELLO".toLowerAscii -- "hello"
```

### Staple.Hex

Hex encoding and decoding for bytes and byte arrays:

```lean
import Staple.Hex
open Staple.Hex

#eval uint8ToHex 255                          -- "ff"
#eval (ByteArray.mk #[0, 255, 171]).toHex     -- "00ffab"
#eval ByteArray.fromHex "00ffab"              -- some #[0, 255, 171]
```

### Staple.IncludeStr / Staple.IncludeBytes

Compile-time file embedding:

```lean
import Staple

def template : String := include_str% "path/to/file.html"
def icon : ByteArray := include_bytes% "assets/icon.png"
```

Path is relative to the source file containing the macro call.

### Staple.Json

JSON string generation with `jsonStr!` macro:

```lean
import Staple.Json
open Staple.Json

-- Using jsonStr! macro
let name := "Alice"
let age : Nat := 30
#eval jsonStr! { name, age }  -- {"name": "Alice", "age": 30}

-- ToJsonStr typeclass instances for:
-- String, Nat, Int, Bool, Float, UInt8/16/32/64, Int8/16/32/64
-- Option α, Array α, List α
```

### Staple.String

String utilities:

```lean
import Staple.String

#eval "42".padLeft 5         -- "   42"
#eval "42".padLeft 5 '0'     -- "00042"
#eval "42".padRight 5        -- "42   "
#eval "hello   ".dropRightWhile (· == ' ')  -- "hello"
#eval "hello world".containsSubstr "world"  -- true
```

## Testing

Uses the Crucible test framework:

```bash
lake test  # Runs 47 tests across all modules
```

## Dependencies

- `crucible` - Test framework (test-only dependency)

## Adding New Utilities

When adding new utilities:

1. Create a new file in `Staple/` (e.g., `Staple/NewUtility.lean`)
2. Add `import Staple.NewUtility` to `Staple.lean`
3. Add tests in `Tests/NewUtility.lean`
4. Add `import Tests.NewUtility` to `Tests.lean`
5. Keep utilities focused and minimal - this is a foundational library
