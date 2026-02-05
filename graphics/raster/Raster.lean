/-
  Raster - Image loading, saving, and manipulation library for Lean 4

  This library provides functionality for reading and writing images in
  various formats (PNG, JPEG, BMP, GIF) using stb_image, along with
  common image transformations.

  ## Quick Start

  ```lean
  import Raster

  def main : IO Unit := do
    -- Load an image
    let img ← Raster.Image.load "photo.jpg"
    IO.println s!"Loaded {img.width}x{img.height} image"

    -- Resize to thumbnail
    let thumb ← Raster.Transform.resize img 100 100

    -- Save as PNG
    Raster.Image.save thumb "thumbnail.png"
  ```
-/

-- Core types and errors
import Raster.Core.Types
import Raster.Core.Error

-- FFI bindings (low-level)
import Raster.FFI.Load
import Raster.FFI.Write
import Raster.FFI.Resize

-- High-level API
import Raster.Image
import Raster.Transform
import Raster.Color

namespace Raster
end Raster
