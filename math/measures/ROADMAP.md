# Roadmap

A prioritized list of potential improvements, new features, code cleanup opportunities, and enhancements for the Measures library.

---

## Feature Proposals

### ~~[Priority: High] Compound Unit Construction~~ ✅ COMPLETED

**Description:** Add support for constructing compound units at runtime.

**Resolution:** Implemented in `Measures/Core/Unit.lean`:
- `Unit.mul` - Multiply two units (e.g., `newton.mul meter`)
- `Unit.div` - Divide two units (e.g., `meter.div second`)
- `Unit.sq` - Square a unit (e.g., `meter.sq`)
- `Unit.cube` - Cube a unit (e.g., `meter.cube`)
- `Unit.recip` - Reciprocal (e.g., `second.recip`)
- `Unit.pow` - Raise to integer power
- `HMul` and `HDiv` instances for operator syntax: `meter / second`, `newton * meter`

Added 15 tests in `MeasuresTests/CompoundUnitTests.lean`.

---

### ~~[Priority: High] Pretty Printing with Unit Symbols~~ ✅ COMPLETED

**Description:** Format quantities with their unit symbols.

**Resolution:** Added to `Measures/Core/Unit.lean`:
- `Quantity.format` - Format with unit symbol: `distance.format meter` → `"100 m"`
- `Quantity.formatLong` - Format with full unit name: `distance.formatLong meter` → `"100 meter"`
- Both accept optional precision parameter (default 2)
- Trailing zeros are trimmed for clean output

Added 8 tests in `MeasuresTests/QuantityTests.lean`.

---

### ~~[Priority: High] Type-Safe Unit Arithmetic~~ ✅ COMPLETED

**Description:** Add operations to multiply and divide `Unit` types to produce new derived units with correct dimensions.

**Resolution:** Completed as part of "Compound Unit Construction" above. Users can now write `let velocity := meter / second` to create a velocity unit.

---

### [Priority: Medium] Dimensioned Numeric Types Beyond Float

**Description:** Support numeric types other than `Float` (e.g., `Nat`, `Int`, `Rat` from mathlib, or arbitrary precision types).

**Rationale:** `Float` has precision limitations. Scientific computing may require exact rational arithmetic or integer quantities (e.g., counting molecules with moles).

**Affected Files:**
- `Measures/Core/Quantity.lean` - Generalize from `Float` to `(n : Type) [Numeric n]`
- All arithmetic operations would need adjustment

**Estimated Effort:** Large

**Dependencies:** May benefit from mathlib's numeric hierarchy

---

### [Priority: Medium] Monad Instance for Dimensionless Quantities

**Description:** Provide `Functor`, `Applicative`, and `Monad` instances for `Quantity Dimension.one`.

**Rationale:** Dimensionless quantities are essentially wrapped numbers. Adding these instances would enable familiar functional programming patterns and composition.

**Affected Files:**
- `Measures/Core/Quantity.lean` - Add typeclass instances

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Medium] Compile-Time Dimension Mismatch Error Messages

**Description:** Improve error messages when dimension mismatches occur to show human-readable dimension names.

**Rationale:** Current type errors show raw `Dimension` structure comparisons. Messages like "Cannot add Length and Time" would be far more helpful than structural mismatches.

**Affected Files:**
- `Measures/Core/Dimension.lean` - Add custom `ToString` or elaborator hints
- Potentially add macro-level diagnostics

**Estimated Effort:** Medium

**Dependencies:** Understanding of Lean 4 elaboration and error reporting

---

### ~~[Priority: Medium] Physical Constants Module~~ ✅ COMPLETED

**Description:** Add a module with commonly used physical constants as typed quantities.

**Resolution:** Expanded `Measures/Constants.lean` with 20+ physical constants including:

**Fundamental:**
- Speed of light (`c`), Planck constant (`h`, `ℏ`), gravitational constant (`G`)

**Electromagnetic:**
- Elementary charge (`e_charge`), vacuum permittivity (`ε₀`), vacuum permeability (`μ₀`)

**Thermodynamic:**
- Boltzmann constant (`k_B`), Stefan-Boltzmann (`σ`), gas constant (`R`)

**Atomic/Nuclear:**
- Avogadro constant (`N_A`), electron/proton/neutron mass (`m_e`, `m_p`, `m_n`), atomic mass unit (`u`)

**Derived:**
- Fine-structure constant (`α`), Rydberg constant, Bohr radius (`a_0`), standard gravity (`g_n`), standard atmosphere (`atm`)

All constants have correct dimensions and short aliases. Added 23 tests including E=mc² calculation.

---

### [Priority: Medium] Currency Units

**Description:** Add support for currency as a dimension with common currency units.

**Rationale:** Financial calculations benefit from dimensional analysis (e.g., price per unit, cost per kilowatt-hour). Currency is not an SI dimension but is a common use case.

**Affected Files:**
- `Measures/Core/Dimension.lean` - May need to add a `currency` field or use a separate dimension system
- New file: `Measures/Units/Currency.lean`

**Estimated Effort:** Medium

**Dependencies:** Design decision on whether to extend SI dimensions or create parallel system

---

### [Priority: Low] Data/Information Units

**Description:** Add units for digital information (bits, bytes, kilobytes, etc.).

**Rationale:** Information is technically dimensionless but has its own unit system. This is useful for computing applications.

**Affected Files:**
- New file: `Measures/Units/Data.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Low] Custom Dimension System

**Description:** Allow users to define custom dimensions beyond the 7 SI base dimensions.

**Rationale:** Some domains have additional base quantities (e.g., currency, information, count). A mechanism for user-defined dimensions would increase flexibility.

**Affected Files:**
- `Measures/Core/Dimension.lean` - Major redesign to support extensibility

**Estimated Effort:** Large

**Dependencies:** Significant design work needed

---

### [Priority: Low] Uncertainty/Error Propagation

**Description:** Track measurement uncertainty alongside values and propagate errors through arithmetic operations.

**Rationale:** Real-world measurements have uncertainties. Automatic error propagation would be valuable for scientific applications.

**Affected Files:**
- New file: `Measures/Uncertainty.lean`
- May need parallel `QuantityWithError` type

**Estimated Effort:** Large

**Dependencies:** None

---

## Code Improvements

### ~~[Priority: High] DecidableEq Instance for Quantity~~ ✅ COMPLETED

**Issue:** `Quantity` only had `BEq` but lacked `DecidableEq`.

**Resolution:** Added `DecidableEq` instance using IEEE 754 bit-level equality via `Float.toUInt64`. Enables propositional equality proofs and use in `if` expressions without `decide`.

Added 3 tests in `MeasuresTests/QuantityTests.lean`.

---

### ~~[Priority: High] Hashable Instance for Quantity and Dimension~~ ✅ COMPLETED

**Issue:** `Dimension` and `Quantity` lacked `Hashable` instances.

**Resolution:**
- Added `Hashable` to `Dimension` deriving clause
- Added manual `Hashable` instance for `Quantity` using `Float.toUInt64`

Enables use in `HashMap` and `HashSet`. Added 3 tests each for Dimension and Quantity.

---

### [Priority: Medium] Use Simp Lemmas for Dimension Arithmetic

**Current State:** Dimension arithmetic is defined but lacks simp lemmas for compile-time normalization.

**Proposed Change:** Add `@[simp]` lemmas proving properties like `d.mul Dimension.one = d`, `d.mul d.inv = Dimension.one`, etc.

**Benefits:** Enables Lean's simplifier to automatically prove dimension equalities, reducing need for explicit casts.

**Affected Files:**
- `Measures/Core/Dimension.lean`

**Estimated Effort:** Medium

**Dependencies:** May require decidable equality proofs

---

### [Priority: Medium] Lawful Typeclass Instances

**Current State:** `Add`, `Mul`, etc. instances are provided but without proof of associativity, commutativity, etc.

**Proposed Change:** Add `LawfulAdd`, `LawfulMul` style instances with proofs.

**Benefits:** Enables use with generic algorithms that require lawful typeclasses, better integration with mathlib.

**Affected Files:**
- `Measures/Ops/Arithmetic.lean`
- `Measures/Core/Dimension.lean`

**Estimated Effort:** Medium

---

### [Priority: Medium] Float Wrapper for Numeric Safety

**Current State:** Quantities directly use `Float` which allows NaN and Infinity without explicit handling.

**Proposed Change:** Consider adding predicates or a wrapper type that validates values, or at least document behavior for edge cases.

**Benefits:** Clearer semantics for invalid values, potential for safer numeric operations.

**Affected Files:**
- `Measures/Core/Quantity.lean`

**Estimated Effort:** Medium

---

### [Priority: Low] Inline Annotations for Performance

**Current State:** Core operations lack `@[inline]` annotations.

**Proposed Change:** Add `@[inline]` or `@[always_inline]` to hot-path functions like `Unit.quantity`, `Unit.fromQuantity`, arithmetic operations.

**Benefits:** Better runtime performance by avoiding function call overhead.

**Affected Files:**
- `Measures/Core/Quantity.lean`
- `Measures/Core/Unit.lean`
- `Measures/Ops/Arithmetic.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Specialize via Typeclass for Float Operations

**Current State:** All operations use `Float` directly.

**Proposed Change:** Define a typeclass for numeric operations and provide a `Float` instance, allowing future extension to other numeric types.

**Benefits:** Prepares codebase for supporting multiple numeric types without breaking changes.

**Affected Files:**
- New file: `Measures/Core/Numeric.lean`
- `Measures/Core/Quantity.lean`

**Estimated Effort:** Medium

---

## Code Cleanup

### ~~[Priority: High] Unused Precision Parameter in toString~~ ✅ COMPLETED

**Issue:** `Quantity.toString` accepts a `precision` parameter but ignores it.

**Resolution:** Implemented `roundToPrecision` helper and updated `toString` to use it.

---

### ~~[Priority: Medium] Duplicated approxEq Helper in Tests~~ ✅ COMPLETED

**Issue:** The `approxEq` function was defined identically in both test files.

**Resolution:** Created `MeasuresTests/TestUtils.lean` with shared `approxEq` function. Both test files now import this module.

---

### ~~[Priority: Medium] Duplicated Pi Constant~~ ✅ COMPLETED

**Issue:** Pi was defined in multiple places.

**Resolution:** Created `Measures/Constants.lean` with `π` and `τ` constants. Updated `Angle.lean` and `TestUtils.lean` to use this module.

---

### ~~[Priority: Medium] Inconsistent Unit Definition Patterns~~ ✅ COMPLETED

**Issue:** Temperature.lean and Time.lean duplicated units from SI.lean.

**Resolution:** Updated both files to import SI.lean and use `abbrev` to re-export units (`kelvin`, `second`, `millisecond`, `microsecond`, `nanosecond`, `hertz`).

---

### [Priority: Low] Missing Module Documentation

**Issue:** Some files lack top-level module documentation explaining their purpose and usage.

**Location:** Several unit test files have minimal documentation.

**Action Required:** Add consistent module-level docstrings following the pattern in core files.

**Estimated Effort:** Small

---

### [Priority: Low] Inconsistent Comment Style

**Issue:** Mix of `/-! ... -/` section comments and `/-- ... -/` doc comments without clear pattern.

**Location:** Throughout codebase

**Action Required:** Establish and apply consistent documentation style guidelines.

**Estimated Effort:** Small

---

## Missing Unit Coverage

### [Priority: High] Molar Units and Chemistry

**Issue:** Despite having `Amount` dimension (mole), there are no units for:
- Molar mass (g/mol)
- Molarity (mol/L)
- Avogadro's number

**Affected Files:**
- New file: `Measures/Units/Chemistry.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Electrical Units Beyond Basics

**Issue:** Missing common electrical units:
- Siemens (conductance, 1/Ohm)
- Millihenry, microhenry
- Millifarad, microfarad, nanofarad, picofarad
- Electron volt (energy)

**Affected Files:**
- `Measures/Units/SI.lean` - Add to existing electrical section

**Estimated Effort:** Small

---

### [Priority: Medium] Radiation and Nuclear Units

**Issue:** No units for:
- Becquerel (radioactivity)
- Gray (absorbed dose)
- Sievert (equivalent dose)

**Affected Files:**
- `Measures/Units/SI.lean` or new file

**Estimated Effort:** Small

---

### [Priority: Medium] Photometric Units

**Issue:** Despite having `Luminosity` dimension, missing:
- Lumen (luminous flux)
- Lux (illuminance)

**Affected Files:**
- `Measures/Units/SI.lean`
- `Measures/Dimensions.lean` - Add `LuminousFlux` and `Illuminance` dimensions

**Estimated Effort:** Small

---

### [Priority: Low] Astronomical Units

**Issue:** Missing common astronomical units:
- Astronomical unit (AU)
- Light-year
- Parsec
- Solar mass

**Affected Files:**
- New file: `Measures/Units/Astronomical.lean`

**Estimated Effort:** Small

---

### [Priority: Low] CGS Units

**Issue:** Some scientific fields still use CGS units:
- Dyne (force)
- Erg (energy)
- Gauss (magnetic field)
- Poise (viscosity)

**Affected Files:**
- New file: `Measures/Units/CGS.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Cooking/Recipe Units

**Issue:** Beyond basic volume units, missing:
- Pinch, dash (informal but used)
- Metric cup (250 mL)
- Imperial cooking measurements

**Affected Files:**
- `Measures/Units/Imperial.lean` or new file

**Estimated Effort:** Small

---

## API Improvements

### ~~[Priority: High] Operator Overloading for Float * Quantity~~ ✅ COMPLETED

**Issue:** `Float * Quantity` was not supported, only `Quantity * Float`.

**Resolution:** Added `HMul Float (Quantity d) (Quantity d)` instance in `Measures/Ops/Arithmetic.lean`.

Now both forms work: `2.0 * distance` and `distance * 2.0`. Added 3 tests.

---

### ~~[Priority: High] Direct Unit Conversion Function~~ ✅ COMPLETED

**Issue:** Converting between units required: `(value *: unit1).asUnit unit2`

**Resolution:** Added `Unit.convert` function in `Measures/Core/Unit.lean`:
```lean
def convert (value : Float) (fromUnit toUnit : Unit d) : Float
```

Example: `Unit.convert 100.0 celsius fahrenheit` returns `212.0`. Added 7 tests.

---

### [Priority: Medium] Quantity Formatting with Specified Unit

**Current State:** No way to format a quantity with a specific unit and symbol.

**Proposed Change:** Add `format : Quantity d -> Unit d -> String` that returns e.g., "100.5 km".

**Benefits:** Clean output for user interfaces and logging.

**Affected Files:**
- `Measures/Core/Quantity.lean` or `Measures/Core/Unit.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Quantity Rounding Functions

**Current State:** No built-in rounding support.

**Proposed Change:** Add `round`, `floor`, `ceiling`, `truncate` functions that preserve dimensions.

**Benefits:** Common operations for display and calculations.

**Affected Files:**
- `Measures/Core/Quantity.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] List/Array Operations

**Current State:** Only `sum` and `avg` for lists.

**Proposed Change:** Add `minList`, `maxList`, `median`, `variance`, `stdDev` for statistical operations on quantity lists.

**Benefits:** Common operations for data analysis with dimensional safety.

**Affected Files:**
- `Measures/Ops/Arithmetic.lean`

**Estimated Effort:** Medium

---

### [Priority: Medium] Linear Interpolation

**Current State:** No interpolation support.

**Proposed Change:** Add `lerp : Quantity d -> Quantity d -> Float -> Quantity d` for linear interpolation between two quantities.

**Benefits:** Common operation in physics simulations and graphics.

**Affected Files:**
- `Measures/Ops/Arithmetic.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Alternative Infix Operators

**Current State:** Uses `*.` and `/.` which may conflict with some notations.

**Proposed Change:** Consider alternative operators or make current ones configurable via scoped notations.

**Benefits:** Better compatibility with other libraries.

**Affected Files:**
- `Measures/Ops/Arithmetic.lean`

**Estimated Effort:** Small

---

## Documentation Improvements

### [Priority: High] README with Examples

**Issue:** No README.md file with comprehensive examples and getting-started guide.

**Action Required:** Create README.md with:
- Installation instructions
- Quick start examples
- Common use cases
- API overview

**Estimated Effort:** Medium

---

### [Priority: Medium] API Reference Documentation

**Issue:** While individual functions have doc comments, there is no centralized API reference.

**Action Required:** Either generate documentation using doc-gen4 or create a manual API reference.

**Estimated Effort:** Medium

---

### [Priority: Medium] Tutorial: Building Custom Units

**Issue:** No documentation on how users should define their own units.

**Action Required:** Add a tutorial or example file showing custom unit definition patterns.

**Estimated Effort:** Small

---

### [Priority: Low] Temperature Handling Guide

**Issue:** Temperature offset handling is subtle and can be confusing (absolute vs. difference).

**Action Required:** Add detailed documentation explaining the temperature model and common pitfalls.

**Estimated Effort:** Small

---

## Test Coverage Gaps

### [Priority: High] Temperature Delta Units

**Issue:** `kelvinDelta`, `celsiusDelta`, `fahrenheitDelta` units in Temperature.lean have no tests.

**Action Required:** Add tests verifying temperature difference calculations work correctly.

**Estimated Effort:** Small

---

### [Priority: Medium] Angle Utility Functions

**Issue:** `normalizePositive` and `normalizeSigned` in Angle.lean have no tests.

**Action Required:** Add tests for angle normalization edge cases.

**Estimated Effort:** Small

---

### [Priority: Medium] Edge Cases

**Issue:** No tests for edge cases like:
- Division by zero quantities
- NaN/Infinity handling
- Very large/small values (overflow)
- Empty list operations (sum, avg)

**Action Required:** Add comprehensive edge case tests.

**Estimated Effort:** Medium

---

### [Priority: Medium] Comparison Operations

**Issue:** `Comparison.lean` operations (`lt`, `le`, `gt`, `ge`, `inRange`, `clamp`) have minimal or no dedicated tests.

**Action Required:** Add tests for comparison operations.

**Estimated Effort:** Small

---

### [Priority: Low] All Units Roundtrip Tests

**Issue:** Only meter-foot and kilogram-pound roundtrips are tested.

**Action Required:** Add roundtrip conversion tests for all unit pairs to catch conversion factor errors.

**Estimated Effort:** Medium

---
