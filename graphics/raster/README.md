# Raster

Image loading, saving, and manipulation library for Lean 4.

Supports PNG, JPEG, BMP, and GIF formats via [stb_image](https://github.com/nothings/stb).

## Installation

Add to your `lakefile.lean`:

```lean
require raster from git "https://github.com/nathanial/raster" @ "v0.0.1"
```

## Quick Start

```lean
import Raster

def main : IO Unit := do
  -- Load an image
  let img ← Raster.Image.load "photo.jpg"
  IO.println s!"Loaded {img.width}x{img.height} image"

  -- Resize to thumbnail
  let thumb ← Raster.Transform.resize img 100 100

  -- Flip horizontally
  let mirrored := Raster.Transform.flipHorizontal thumb

  -- Save as PNG
  Raster.Image.save mirrored "thumbnail.png"
```

## Features

### Image Loading

```lean
-- Load from file (auto-detect format)
let img ← Image.load "photo.png"

-- Load with specific pixel format
let rgba ← Image.loadAs "photo.png" .rgba

-- Load from memory buffer
let img ← Image.loadFromMemory bytes

-- Get image info without loading pixels
let (width, height, format) ← Image.info "photo.png"
```

### Image Saving

```lean
-- Save as PNG
Image.save img "output.png"

-- Save as JPEG with quality (1-100)
Image.save img "output.jpg" (.jpeg 85)

-- Save as BMP
Image.save img "output.bmp" .bmp

-- Encode to memory buffer
let pngBytes ← Image.encode img .png
let jpegBytes ← Image.encode img (.jpeg 90)
```

### Transformations

```lean
-- Resize to specific dimensions
let resized ← Transform.resize img 800 600

-- Scale by factor
let half ← Transform.scale img 0.5
let double ← Transform.scale img 2.0

-- Crop region (x, y, width, height)
let cropped := Transform.crop img 10 10 100 100

-- Flip
let hFlipped := Transform.flipHorizontal img
let vFlipped := Transform.flipVertical img

-- Rotate
let r90 := Transform.rotate90 img    -- 90° clockwise
let r180 := Transform.rotate180 img  -- 180°
let r270 := Transform.rotate270 img  -- 270° clockwise
```

### Pixel Access

```lean
-- Get pixel at (x, y) as list of channel values
let pixel := img.getPixel 10 20  -- Option (List UInt8)

-- Set pixel
let modified := img.setPixel 10 20 [255, 0, 0, 255]

-- Get individual channels (for RGB/RGBA images)
let r := img.getRed 10 20    -- Option UInt8
let g := img.getGreen 10 20
let b := img.getBlue 10 20
let a := img.getAlpha 10 20

-- Fill with solid color
let red := img.fill [255, 0, 0, 255]

-- Convert to grayscale
let gray := img.toGrayscale
```

### Creating Images

```lean
-- Create blank image with fill color
let img := Image.create 100 100 .rgba [0, 0, 0, 255]

-- Create empty image (no pixel data)
let empty := Image.empty 100 100 .rgb
```

## Pixel Formats

| Format | Channels | Description |
|--------|----------|-------------|
| `.gray` | 1 | Grayscale |
| `.grayA` | 2 | Grayscale + Alpha |
| `.rgb` | 3 | Red, Green, Blue |
| `.rgba` | 4 | Red, Green, Blue, Alpha |

## Output Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| `.png` | .png | Lossless, supports alpha |
| `.jpeg quality` | .jpg | Lossy, quality 1-100 |
| `.bmp` | .bmp | Uncompressed |

## Building

```bash
./build.sh        # Downloads stb headers and builds
lake build        # Build library
lake test         # Run tests
```

## Architecture

```
Raster/
├── Core/
│   ├── Types.lean      # Image, PixelFormat, OutputFormat
│   └── Error.lean      # RasterError
├── FFI/
│   ├── Load.lean       # stb_image bindings
│   ├── Write.lean      # stb_image_write bindings
│   └── Resize.lean     # stb_image_resize2 bindings
├── Image.lean          # High-level load/save API
├── Transform.lean      # Resize, crop, flip, rotate
└── Color.lean          # Pixel access utilities
```

## Dependencies

- [stb_image](https://github.com/nothings/stb) - Image loading (vendored, downloaded by build.sh)
- [stb_image_write](https://github.com/nothings/stb) - Image saving (vendored)
- [stb_image_resize2](https://github.com/nothings/stb) - Image resizing (vendored)
- [crucible](https://github.com/nathanial/crucible) - Test framework (dev only)

## License

MIT License. See [LICENSE](LICENSE) for details.

Note: stb libraries are public domain / MIT licensed.
