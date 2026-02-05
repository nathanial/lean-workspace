/-
  Raster.Core.Types - Core type definitions for image handling
-/

namespace Raster

/-- Pixel format for image data -/
inductive PixelFormat where
  | gray   : PixelFormat  -- 1 channel (grayscale)
  | grayA  : PixelFormat  -- 2 channels (grayscale + alpha)
  | rgb    : PixelFormat  -- 3 channels (RGB)
  | rgba   : PixelFormat  -- 4 channels (RGBA)
  deriving Repr, BEq, Inhabited

namespace PixelFormat

/-- Get the number of channels for this pixel format -/
def channels : PixelFormat → Nat
  | .gray  => 1
  | .grayA => 2
  | .rgb   => 3
  | .rgba  => 4

/-- Create a PixelFormat from channel count -/
def fromChannels : Nat → PixelFormat
  | 1 => .gray
  | 2 => .grayA
  | 3 => .rgb
  | _ => .rgba

end PixelFormat

/-- Image output format for encoding -/
inductive OutputFormat where
  | png                          -- PNG format (lossless, supports alpha)
  | jpeg (quality : UInt8 := 90) -- JPEG format (lossy, quality 1-100)
  | bmp                          -- BMP format (uncompressed)
  deriving Repr, BEq

/-- Core image structure with pixel data -/
structure Image where
  width  : Nat
  height : Nat
  format : PixelFormat
  data   : ByteArray
  deriving BEq

namespace Image

/-- Get the number of pixels in the image -/
def pixelCount (img : Image) : Nat := img.width * img.height

/-- Get the expected data size based on dimensions and format -/
def expectedDataSize (img : Image) : Nat :=
  img.width * img.height * img.format.channels

/-- Check if the image data is valid (correct size) -/
def isValid (img : Image) : Bool :=
  img.width > 0 && img.height > 0 && img.data.size == img.expectedDataSize

/-- Get the number of channels -/
def channels (img : Image) : Nat := img.format.channels

/-- Create an empty image with given dimensions -/
def empty (width height : Nat) (format : PixelFormat := .rgba) : Image :=
  { width, height, format, data := .empty }

end Image

end Raster
