# Raster Roadmap

This document tracks potential improvements, new features, and code cleanup opportunities for the Raster library.

---

## Feature Proposals

### [Priority: High] Tincture Color Integration

**Description:** Add optional integration with the Tincture color library to provide high-level color operations and conversions.

**Rationale:** Tincture provides a rich Color type with HSV/HSL conversion, color blending, gradients, and color harmony functions. Integrating with it would significantly enhance color manipulation capabilities without duplicating functionality.

**Proposed API:**
```lean
-- Convert Image to use Tincture.Color for pixel access
def Image.getPixelColor (img : Image) (x y : Nat) : Option Tincture.Color
def Image.setPixelColor (img : Image) (x y : Nat) (c : Tincture.Color) : Image

-- Apply color transformations
def Image.adjustHue (img : Image) (degrees : Float) : Image
def Image.adjustSaturation (img : Image) (factor : Float) : Image
def Image.adjustBrightness (img : Image) (factor : Float) : Image
```

**Affected Files:** `Raster/Color.lean`, `lakefile.lean`, new `Raster/Tincture.lean`

**Estimated Effort:** Medium

**Dependencies:** Tincture library (optional dependency)

---

### [Priority: High] Format Conversion API

**Description:** Add explicit format conversion functions to change between pixel formats (e.g., RGB to RGBA, RGBA to Grayscale).

**Rationale:** The current `toGrayscale` function is the only format conversion available. Users frequently need to add/remove alpha channels or convert between color and grayscale formats.

**Proposed API:**
```lean
def Image.toRgba (img : Image) : Image      -- Add alpha channel
def Image.toRgb (img : Image) : Image       -- Remove alpha channel
def Image.toGrayA (img : Image) : Image     -- Grayscale with alpha
-- toGrayscale already exists
```

**Affected Files:** `Raster/Color.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: High] Drawing Primitives

**Description:** Add basic drawing operations for programmatic image generation.

**Rationale:** Currently users can only load existing images or create solid-color images. Basic drawing primitives would enable procedural image generation, simple graphics, and overlays.

**Proposed API:**
```lean
namespace Raster.Draw

def line (img : Image) (x0 y0 x1 y1 : Nat) (color : List UInt8) : Image
def rect (img : Image) (x y width height : Nat) (color : List UInt8) : Image
def rectFilled (img : Image) (x y width height : Nat) (color : List UInt8) : Image
def circle (img : Image) (cx cy radius : Nat) (color : List UInt8) : Image
def circleFilled (img : Image) (cx cy radius : Nat) (color : List UInt8) : Image

end Raster.Draw
```

**Affected Files:** New `Raster/Draw.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Image Composition/Blending

**Description:** Add support for compositing multiple images together with various blend modes.

**Rationale:** Combining images is a common operation for overlays, watermarks, and layer-based editing.

**Proposed API:**
```lean
inductive BlendMode where
  | normal | multiply | screen | overlay | add | subtract

def Image.composite (base overlay : Image) (x y : Int) (mode : BlendMode := .normal) : Image
def Image.paste (base overlay : Image) (x y : Nat) : Image  -- Simple paste
def Image.blend (img1 img2 : Image) (t : Float) : Image     -- Linear blend
```

**Affected Files:** New `Raster/Composite.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Additional Resize Filters

**Description:** Expose different resize interpolation methods available in stb_image_resize2.

**Rationale:** Different use cases require different resize quality/speed tradeoffs. Nearest-neighbor is better for pixel art, while Catmull-Rom or Mitchell provide sharper results for photos.

**Proposed API:**
```lean
inductive ResizeFilter where
  | box | triangle | cubicBSpline | catmullRom | mitchell | nearestNeighbor

def Transform.resizeWith (img : Image) (w h : Nat) (filter : ResizeFilter) : IO Image
```

**Affected Files:** `Raster/Transform.lean`, `Raster/FFI/Resize.lean`, `native/src/raster_ffi.c`

**Estimated Effort:** Small

**Dependencies:** None (stb_image_resize2 already supports these)

---

### [Priority: Medium] TGA and HDR Format Support

**Description:** Add support for loading and saving TGA and HDR image formats.

**Rationale:** stb_image already supports loading TGA and HDR formats. Exposing these would be straightforward and useful for game development (TGA textures) and photography (HDR images).

**Proposed API:**
```lean
-- Add to OutputFormat
inductive OutputFormat where
  | png | jpeg (quality : UInt8 := 90) | bmp | tga

-- For HDR: new Image type with Float channels
structure ImageHdr where
  width height : Nat
  data : FloatArray  -- RGB float channels
```

**Affected Files:** `Raster/Core/Types.lean`, `Raster/FFI/Write.lean`, `native/src/raster_ffi.c`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Histogram and Statistics

**Description:** Add functions to compute image statistics and histograms.

**Rationale:** Useful for image analysis, auto-exposure, histogram equalization, and understanding image content.

**Proposed API:**
```lean
structure ImageStats where
  minValue maxValue : UInt8
  mean stdDev : Float
  histogram : Array Nat  -- 256 bins per channel

def Image.stats (img : Image) : ImageStats
def Image.histogram (img : Image) : Array (Array Nat)  -- Per-channel histograms
def Image.equalizeHistogram (img : Image) : Image
```

**Affected Files:** New `Raster/Stats.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Low] GIF Animation Support

**Description:** Add support for loading and saving animated GIFs.

**Rationale:** stb_image supports loading GIF frames. Animation support would be valuable for game sprites and simple animations.

**Proposed API:**
```lean
structure AnimatedImage where
  frames : Array Image
  delays : Array Nat  -- Delay in ms for each frame

def AnimatedImage.load (path : String) : IO AnimatedImage
def AnimatedImage.save (anim : AnimatedImage) (path : String) : IO Unit
```

**Affected Files:** New `Raster/Animation.lean`, `Raster/FFI/Load.lean`, `native/src/raster_ffi.c`

**Estimated Effort:** Large

**Dependencies:** May need additional GIF encoding library

---

### [Priority: Low] Convolution and Filters

**Description:** Add convolution-based image filters (blur, sharpen, edge detection).

**Rationale:** Common image processing operations that would make the library more useful for image manipulation tasks.

**Proposed API:**
```lean
namespace Raster.Filter

def boxBlur (img : Image) (radius : Nat) : Image
def gaussianBlur (img : Image) (radius : Nat) (sigma : Float) : Image
def sharpen (img : Image) (amount : Float) : Image
def edgeDetect (img : Image) : Image
def convolve (img : Image) (kernel : Array Float) (size : Nat) : Image

end Raster.Filter
```

**Affected Files:** New `Raster/Filter.lean`

**Estimated Effort:** Large

**Dependencies:** None

---

### [Priority: Low] Streaming/Progressive Loading

**Description:** Add support for loading large images progressively or in tiles.

**Rationale:** For very large images, loading the entire image into memory may not be practical. Streaming support would enable working with large images.

**Proposed API:**
```lean
-- Load a specific region of an image
def Image.loadRegion (path : String) (x y width height : Nat) : IO Image

-- Progressive callback-based loading
def Image.loadProgressive (path : String) (callback : Image -> IO Unit) : IO Unit
```

**Affected Files:** `Raster/Image.lean`, `Raster/FFI/Load.lean`, `native/src/raster_ffi.c`

**Estimated Effort:** Large

**Dependencies:** None (but may require significant FFI changes)

---

## Code Improvements

### [Priority: High] Use ByteArray.mk with Subarray for Performance

**Current State:** Transform operations like `flipHorizontal`, `flipVertical`, and `rotate` build ByteArrays by repeatedly calling `push`, which may cause multiple reallocations.

**Proposed Change:** Pre-allocate ByteArrays with the correct size and use indexed writes, or use `ByteArray.mk` with a computed list/array.

**Benefits:** Significant performance improvement for large images by avoiding repeated memory allocations.

**Affected Files:** `Raster/Transform.lean`, `Raster/Color.lean`

**Estimated Effort:** Small

---

### [Priority: High] Add Bounds Checking Options

**Current State:** Several operations use `get!` and `set!` which panic on out-of-bounds access instead of returning errors.

**Proposed Change:** Add safe alternatives that return `Option` or `RasterResult`, and ensure all internal uses have validated bounds first.

**Benefits:** Better error handling, no panics in production code.

**Affected Files:** `Raster/Transform.lean`, `Raster/Color.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Consistent Error Handling

**Current State:** Some operations return `IO` (which can throw), some return `RasterResult`, and some are pure but silently return unchanged images on invalid input (e.g., `setPixel`).

**Proposed Change:** Establish a consistent pattern:
- Operations that can fail should return `RasterResult` or `IO`
- Document which operations can fail and why
- Consider adding `unsafe` variants for performance-critical code with validated inputs

**Benefits:** Predictable API behavior, easier error handling for users.

**Affected Files:** `Raster/Image.lean`, `Raster/Transform.lean`, `Raster/Color.lean`

**Estimated Effort:** Medium

---

### [Priority: Medium] Add Repr Instance for Image

**Current State:** `Image` has `BEq` but no `Repr` instance, making debugging harder.

**Proposed Change:** Add a `Repr` instance that shows dimensions, format, and perhaps a hash of the data (not all bytes).

**Benefits:** Better debugging experience.

**Affected Files:** `Raster/Core/Types.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Optimize toGrayscale with FFI

**Current State:** `toGrayscale` is implemented in pure Lean with per-pixel iteration.

**Proposed Change:** Implement in C for better performance, or use SIMD-friendly memory access patterns.

**Benefits:** Faster grayscale conversion for large images.

**Affected Files:** `Raster/Color.lean`, potentially new FFI function

**Estimated Effort:** Small

---

### [Priority: Low] Consider FloatArray for Internal Operations

**Current State:** All pixel data is stored as `ByteArray` with UInt8 values, requiring Float conversions for color calculations.

**Proposed Change:** For operations like `toGrayscale` that involve floating-point math, consider intermediate Float representation to reduce precision loss.

**Benefits:** More accurate color calculations.

**Affected Files:** `Raster/Color.lean`, `Raster/Transform.lean`

**Estimated Effort:** Medium

---

### [Priority: Low] Add Image Validation on Load

**Current State:** `Image.load` creates an image from FFI-returned data without validating that the data size matches expected dimensions.

**Proposed Change:** Add validation that `data.size == width * height * channels` after loading, with meaningful error on mismatch.

**Benefits:** Catch FFI bugs or corrupted data early.

**Affected Files:** `Raster/Image.lean`

**Estimated Effort:** Small

---

## Code Cleanup

### [Priority: Medium] Add Type Alias for Pixel Data

**Issue:** Pixel colors are represented as `List UInt8` throughout the API, which is not type-safe and unclear.

**Location:** `Raster/Color.lean`, `Raster/Image.lean`

**Action Required:**
1. Add `abbrev Pixel := List UInt8` or a proper structure
2. Consider channel-specific types like `RgbaPixel`, `RgbPixel`, `GrayPixel`

**Estimated Effort:** Medium

---

### [Priority: Medium] Consolidate FFI Modules

**Issue:** The three FFI modules (`Load.lean`, `Write.lean`, `Resize.lean`) are very small and could be consolidated.

**Location:** `Raster/FFI/*.lean`

**Action Required:**
1. Consider merging into a single `Raster/FFI.lean` file
2. Or keep separate but add a barrel export

**Estimated Effort:** Small

---

### [Priority: Low] Add Module Documentation

**Issue:** While individual functions have docstrings, there are no module-level documentation comments explaining the overall architecture.

**Location:** All `.lean` files

**Action Required:**
1. Add module docstrings at the top of each file
2. Document the relationship between modules
3. Add usage examples in module docs

**Estimated Effort:** Small

---

### [Priority: Low] Expand Test Coverage

**Issue:** Tests cover basic functionality but lack:
- Tests for actual image loading/saving (require test fixtures)
- Edge cases (1x1 images, very large images)
- Error path testing
- Grayscale format tests

**Location:** `Tests/*.lean`

**Action Required:**
1. Add test image fixtures
2. Add integration tests for load/save roundtrips
3. Add edge case tests
4. Add error handling tests

**Estimated Effort:** Medium

---

### [Priority: Low] Add LICENSE File

**Issue:** The README mentions MIT License but there is no LICENSE file in the repository.

**Location:** Project root

**Action Required:** Add a LICENSE file with the MIT license text.

**Estimated Effort:** Small

---

### [Priority: Low] Build Script Improvements

**Issue:** `build.sh` could be more robust with error handling and caching.

**Location:** `build.sh`

**Action Required:**
1. Add checksum verification for downloaded stb headers
2. Add version pinning for stb (use specific commit hash)
3. Add `clean` option to remove downloaded headers

**Estimated Effort:** Small

---

## API Enhancements

### [Priority: High] Add Iterator/Fold for Pixels

**Description:** Add functional iteration patterns for processing pixels.

**Proposed API:**
```lean
def Image.forEachPixel (img : Image) (f : Nat -> Nat -> List UInt8 -> IO Unit) : IO Unit
def Image.mapPixels (img : Image) (f : List UInt8 -> List UInt8) : Image
def Image.foldPixels (img : Image) (init : A) (f : A -> Nat -> Nat -> List UInt8 -> A) : A
```

**Rationale:** Enables functional programming patterns for image processing.

**Affected Files:** `Raster/Color.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Add Subimage/View Type

**Description:** Add a view type that references a region of an image without copying data.

**Proposed API:**
```lean
structure ImageView where
  source : Image
  x y width height : Nat

def Image.view (img : Image) (x y w h : Nat) : RasterResult ImageView
def ImageView.toImage (view : ImageView) : Image  -- Copy to new image
def ImageView.getPixel (view : ImageView) (x y : Nat) : Option (List UInt8)
```

**Rationale:** Avoids unnecessary copies when working with image regions.

**Affected Files:** New `Raster/View.lean`

**Estimated Effort:** Medium

---

### [Priority: Medium] BMP Encoding to Memory

**Description:** Add in-memory BMP encoding (currently only file output is supported).

**Current State:** `Image.encode` throws an error for BMP format with message "BMP encoding to memory not supported".

**Proposed Change:** Implement `raster_encode_bmp` using `stbi_write_bmp_to_func`.

**Affected Files:** `Raster/Image.lean`, `Raster/FFI/Write.lean`, `native/src/raster_ffi.c`

**Estimated Effort:** Small

---

### [Priority: Low] Add WebP Support

**Description:** Add WebP format support for loading and saving.

**Rationale:** WebP is increasingly common on the web and offers good compression.

**Affected Files:** `native/src/raster_ffi.c`, lakefile.lean, FFI modules

**Estimated Effort:** Large (requires additional native library)

**Dependencies:** libwebp

---

## Notes

- All effort estimates assume familiarity with the codebase
- "Small" = a few hours, "Medium" = 1-2 days, "Large" = several days to a week
- Priority reflects both value and feasibility
- Some features may require coordination with dependent projects (e.g., afferent, worldmap)
