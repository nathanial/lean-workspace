# Tincture Color Library Roadmap

This document outlines potential improvements, new features, and cleanup tasks for the Tincture color library.

---

## Feature Proposals

### [Priority: High] CSS Color Level 4 Parsing Support

**Description:** Extend the color parsing to support modern CSS Color Level 4 syntax including `hsl()`, `hwb()`, `lab()`, `lch()`, `oklab()`, `oklch()`, and the `color()` function.

**Rationale:** CSS Color Level 4 is increasingly adopted in browsers. Supporting these formats would make Tincture more useful for web development workflows and CSS tool integration.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Parse.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: High] Named Color Lookup by Closest Match

**Description:** Add a function to find the closest named color to an arbitrary color, using perceptual color distance (deltaE2000).

**Rationale:** Useful for color identification, accessibility tools, and generating human-readable color descriptions.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Named.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Distance.lean`

**Estimated Effort:** Small

**Dependencies:** Color distance functionality already exists

---

### [Priority: Medium] Gamut Mapping for OkLab/OkLCH

**Description:** Implement gamut mapping to clamp out-of-gamut colors back into the sRGB gamut while preserving perceptual appearance as much as possible. Currently, conversions from wide-gamut color spaces can produce RGB values outside [0,1].

**Rationale:** OkLCH in particular can easily produce colors outside the sRGB gamut. Proper gamut mapping (e.g., via chroma reduction) provides better results than simple clamping.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/OkLab.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/OkLCH.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Display-P3 and Adobe RGB Color Spaces

**Description:** Add support for wide-gamut color spaces like Display-P3 (used on modern Apple devices) and Adobe RGB (used in photography).

**Rationale:** Wide-gamut displays are increasingly common. Supporting these spaces would enable accurate color representation for professional graphics workflows.

**Affected Files:**
- New file: `Tincture/Space/DisplayP3.lean`
- New file: `Tincture/Space/AdobeRGB.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Convert.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] ICC Profile Support (Basic)

**Description:** Add basic ICC profile parsing for CMYK conversions. The current CMYK implementation uses a simple formula that does not account for real-world printing profiles.

**Rationale:** Professional print workflows require ICC profile-based color management for accurate results.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/CMYK.lean`
- New file: `Tincture/ICC.lean`

**Estimated Effort:** Large

**Dependencies:** May require FFI for profile parsing or implementing a subset of ICC in pure Lean

---

### [Priority: Medium] Color Quantization / Palette Extraction

**Description:** Implement algorithms to extract dominant colors from a set of colors (e.g., median cut, k-means clustering). This is useful for extracting color palettes from images.

**Rationale:** Common use case for design tools and image processing.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Palette.lean` or new file `Tincture/Quantize.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Color Interpolation Easing Functions

**Description:** Add support for non-linear interpolation in gradients (ease-in, ease-out, ease-in-out, custom bezier curves).

**Rationale:** Non-linear interpolation produces more visually appealing gradients and animations.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Gradient.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Low] Spectral Color Representation

**Description:** Add support for spectral colors (wavelength-based representation) and conversion to/from XYZ/sRGB.

**Rationale:** Useful for scientific applications, accurate color mixing, and educational purposes.

**Affected Files:**
- New file: `Tincture/Space/Spectral.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Low] Temperature to Color (Kelvin)

**Description:** Add function to generate blackbody radiation colors from temperature in Kelvin. Useful for lighting and photography applications.

**Rationale:** Common feature in color libraries for simulating light sources.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Adjust.lean` or new file `Tincture/Temperature.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Low] Compile-Time Color Literals

**Description:** Add a macro or elaborator for compile-time validated color literals (e.g., `color!"#ff0000"` or `color!"rgb(255, 0, 0)"`).

**Rationale:** Catches color parsing errors at compile time rather than runtime, improves developer experience.

**Affected Files:**
- New file: `Tincture/Syntax.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

## Code Improvements

### [Priority: High] Consolidate Gamma Conversion Functions

**Current State:** The gamma conversion functions (`gammaToLinear`, `linearToGamma`) are duplicated across multiple files:
- `Tincture/Space/RGB.lean` (lines 20-31)
- `Tincture/Space/XYZ.lean` (lines 25-37, marked `private`)
- `Tincture/Space/OkLab.lean` (lines 56-68, marked `private`)
- `Tincture/Blindness.lean` (lines 48-55, marked `private`)

**Proposed Change:** Move these functions to a shared utility module (e.g., `Tincture/Util.lean` or export from `Tincture/Space/RGB.lean`) and have all files use the shared implementation.

**Benefits:** DRY principle, easier maintenance, single source of truth for sRGB gamma curve.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/RGB.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/XYZ.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/OkLab.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Blindness.lean`

**Estimated Effort:** Small

---

### [Priority: High] Add Alpha Channel Preservation to Color Space Conversions

**Current State:** Alpha channel handling is inconsistent across color space types. For example, `HSL`, `HSV`, `HWB`, `Lab`, `LCH`, `OkLab`, `OkLCH`, `XYZ`, and `CMYK` structures do not store alpha. The alpha is passed separately to `toColor` but lost during `fromColor`.

**Proposed Change:** Either:
1. Add an `alpha` field to each color space structure, or
2. Create wrapper types that consistently carry alpha alongside the color space data, or
3. Document the pattern clearly and ensure all `toColor` methods accept alpha

**Benefits:** Consistent alpha handling, prevents subtle bugs when converting between color spaces.

**Affected Files:**
- All files in `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/`

**Estimated Effort:** Medium

---

### [Priority: Medium] Add Typeclass for Color Space Conversion

**Current State:** Each color space has its own `fromColor` and `toColor` functions, but there is no common interface (typeclass).

**Proposed Change:** Create a `ColorSpace` typeclass with `fromColor` and `toColor` methods. This would enable generic programming over color spaces.

```lean
class ColorSpace (S : Type) where
  fromColor : Color -> S
  toColor : S -> Float -> Color  -- Float is alpha
```

**Benefits:** Enables generic algorithms, cleaner API, better composability.

**Affected Files:**
- All files in `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Convert.lean`

**Estimated Effort:** Medium

---

### [Priority: Medium] Optimize Named Color Lookup

**Current State:** `namedColors` is a `List (String x Color)` and lookup is O(n) via `List.find?`.

**Proposed Change:** Use a `HashMap` or `RBMap` for O(log n) or O(1) lookup. The list has 147+ entries.

**Benefits:** Faster color name lookups.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Named.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Add Infix Operators for Common Operations

**Current State:** Common operations like color mixing and blending use function calls.

**Proposed Change:** Add optional infix operators:
- `c1 +c c2` for additive mixing (linear RGB)
- `c1 *c c2` for multiply blend
- `c1 |> blend` for blending operations

**Benefits:** More ergonomic API for color manipulation DSLs.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Blend.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Adjust.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Improve Float Parsing Robustness

**Current State:** The `parseFloat` function in `Parse.lean` (lines 82-103) is a basic implementation that:
- Does not handle negative numbers
- Does not handle scientific notation
- Does not handle leading zeros well

**Proposed Change:** Improve the parser to handle more edge cases or use Lean's built-in parsing utilities if available.

**Benefits:** More robust color parsing, fewer parsing failures.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Parse.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Add Benchmarking Suite

**Current State:** No performance benchmarks exist.

**Proposed Change:** Add benchmarks for:
- Color space conversions (especially Lab and OkLab which are more compute-intensive)
- Delta E calculations
- Gradient sampling
- Parsing/formatting

**Benefits:** Identify performance regressions, guide optimization efforts.

**Affected Files:**
- New file: `TinctureTests/Benchmarks.lean` or similar

**Estimated Effort:** Medium

---

### [Priority: Low] Lazy Gradient Sampling

**Current State:** `Gradient.sample` eagerly computes all colors into an Array.

**Proposed Change:** Add a lazy/iterator-based API for sampling gradients, useful when only a few samples are needed from a potentially large gradient.

**Benefits:** Better memory efficiency for large sample counts.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Gradient.lean`

**Estimated Effort:** Small

---

## Code Cleanup

### [Priority: High] Remove Duplicate Helper Functions in Tests

**Issue:** The test files each define their own `approxEq` and `colorApproxEq` helper functions:
- `TinctureTests/ColorTests.lean` (lines 14-22)
- `TinctureTests/SpaceTests.lean` (lines 14-21)
- `TinctureTests/BlendTests.lean` (lines 14-21)
- `TinctureTests/ContrastTests.lean` (lines 14-15)
- `TinctureTests/HarmonyTests.lean` (lines 14-15)
- `TinctureTests/ParseFormatTests.lean` (lines 14-21)
- `TinctureTests/PropertyTests.lean` (lines 63-69)

**Location:** All test files in `/Users/Shared/Projects/lean-workspace/tincture/TinctureTests/`

**Action Required:** Extract shared test utilities into a common file (e.g., `TinctureTests/TestUtils.lean`) and import from all test files.

**Estimated Effort:** Small

---

### [Priority: Medium] Add Missing `Float.abs` Definition Location Documentation

**Issue:** `Float.abs` is defined in `Tincture/Color.lean` (line 18), but it may shadow or conflict with any future standard library definition. Additionally, `Float.pi`, `Float.max`, `Float.min` are defined here too.

**Location:** `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Color.lean` (lines 8-18)

**Action Required:** Check if these are available in Lean's standard library now (Lean 4.26+) and remove duplicates if so. If not, document why they are needed.

**Estimated Effort:** Small

---

### [Priority: Medium] Consistent Error Handling in Parsing

**Issue:** Parsing functions return `Option Color` but do not provide error messages. Users cannot distinguish between different types of parse failures.

**Location:** `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Parse.lean`

**Action Required:** Consider adding an `Except String Color` variant that provides error messages, or at minimum document what types of inputs are rejected.

**Estimated Effort:** Small

---

### [Priority: Medium] Update README to Match Current Features

**Issue:** The README.md is minimal and does not reflect the full feature set of the library. It mentions only RGBA and HSV but the library supports 10+ color spaces, color blindness simulation, WCAG contrast, gradients, palettes, etc.

**Location:** `/Users/Shared/Projects/lean-workspace/tincture/README.md`

**Action Required:** Update README with:
- Complete feature list
- Examples for each major feature area
- API documentation or links to generated docs

**Estimated Effort:** Medium

---

### [Priority: Low] Add Module-Level Documentation Comments

**Issue:** While individual functions have doc comments, module-level documentation explaining the purpose and usage of each file is minimal.

**Location:** All source files

**Action Required:** Add comprehensive doc comments at the top of each file explaining:
- Purpose of the module
- Key types and functions
- Usage examples
- Any important caveats

**Estimated Effort:** Medium

---

### [Priority: Low] Inconsistent Hue Representation

**Issue:** Hue is represented as `0.0 to 1.0` (normalized) in all color spaces, but some helper functions like `rotateHueDeg` accept degrees. The documentation could be clearer about this.

**Location:**
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/HSL.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/HSV.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Adjust.lean` (line 41)

**Action Required:** Add clear documentation about the hue convention. Consider adding more degree-based convenience functions if commonly needed.

**Estimated Effort:** Small

---

### [Priority: Low] Add Test Coverage for Color Blindness Simulation

**Issue:** No unit tests exist for the color blindness simulation module.

**Location:** No `BlindnessTests.lean` file exists

**Action Required:** Create `TinctureTests/BlindnessTests.lean` with tests for:
- Each type of color blindness simulation
- Severity adjustment
- `isDistinguishableFor` function

**Estimated Effort:** Small

---

### [Priority: Low] Add Test Coverage for Distance Module

**Issue:** No dedicated unit tests exist for the color distance module (deltaE76, deltaE94, deltaE2000). Only property tests in `PropertyTests.lean` cover some aspects.

**Location:** No `DistanceTests.lean` file exists

**Action Required:** Create `TinctureTests/DistanceTests.lean` with tests for:
- Known deltaE values from the CIE publications
- Edge cases (same color, black/white, complementary colors)
- Symmetry and non-negativity

**Estimated Effort:** Small

---

### [Priority: Low] Add Test Coverage for Gradient Module

**Issue:** No dedicated unit tests exist for gradient functionality. Only property tests cover basic gradient behavior.

**Location:** No `GradientTests.lean` file exists

**Action Required:** Create `TinctureTests/GradientTests.lean` with tests for:
- Different gradient spaces (sRGB, OkLab, etc.)
- Hue interpolation methods
- Multi-stop gradients
- Reverse functionality
- Sample function

**Estimated Effort:** Small

---

### [Priority: Low] Add Test Coverage for Palette Module

**Issue:** No dedicated unit tests exist for palette generation.

**Location:** No `PaletteTests.lean` file exists

**Action Required:** Create `TinctureTests/PaletteTests.lean` with tests for:
- Sequential, diverging, and qualitative palettes
- Warm, cool, earth, pastel, neon palettes
- Accessible palette generation
- Random palette with seed reproducibility

**Estimated Effort:** Small

---

### [Priority: Low] Add Test Coverage for Adjust Module

**Issue:** No dedicated unit tests exist for color adjustment operations (lighten, darken, saturate, etc.).

**Location:** No `AdjustTests.lean` file exists

**Action Required:** Create `TinctureTests/AdjustTests.lean` with tests for:
- Lighten/darken
- Saturate/desaturate
- Hue rotation
- Invert, grayscale, sepia
- Brightness/contrast adjustments
- OkLCH-based adjustments

**Estimated Effort:** Small
