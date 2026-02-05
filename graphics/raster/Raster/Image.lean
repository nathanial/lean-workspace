/-
  Raster.Image - High-level image loading and saving API
-/
import Raster.Core.Types
import Raster.Core.Error
import Raster.FFI.Load
import Raster.FFI.Write

namespace Raster

namespace Image

/-- Load an image from file path, auto-detecting format -/
def load (path : String) : IO Image := do
  let (data, width, height, channels) ← FFI.loadFromFile path 0
  let format := PixelFormat.fromChannels channels.toNat
  return { width := width.toNat, height := height.toNat, format, data }

/-- Load image forcing specific pixel format -/
def loadAs (path : String) (format : PixelFormat) : IO Image := do
  let channels := format.channels.toUInt8
  let (data, width, height, _) ← FFI.loadFromFile path channels
  return { width := width.toNat, height := height.toNat, format, data }

/-- Load image from memory buffer (auto-detect format) -/
def loadFromMemory (buffer : ByteArray) : IO Image := do
  let (data, width, height, channels) ← FFI.loadFromMemory buffer 0
  let format := PixelFormat.fromChannels channels.toNat
  return { width := width.toNat, height := height.toNat, format, data }

/-- Load image from memory with specific pixel format -/
def loadFromMemoryAs (buffer : ByteArray) (format : PixelFormat) : IO Image := do
  let channels := format.channels.toUInt8
  let (data, width, height, _) ← FFI.loadFromMemory buffer channels
  return { width := width.toNat, height := height.toNat, format, data }

/-- Get image dimensions without loading full data -/
def info (path : String) : IO (Nat × Nat × PixelFormat) := do
  let (width, height, channels) ← FFI.infoFromFile path
  let format := PixelFormat.fromChannels channels.toNat
  return (width.toNat, height.toNat, format)

/-- Save image to file -/
def save (img : Image) (path : String) (format : OutputFormat := .png) : IO Unit := do
  let w := img.width.toUInt32
  let h := img.height.toUInt32
  let c := img.format.channels.toUInt32
  match format with
  | .png => FFI.writePng path w h c img.data
  | .jpeg quality => FFI.writeJpeg path w h c img.data quality
  | .bmp => FFI.writeBmp path w h c img.data

/-- Encode image to memory buffer -/
def encode (img : Image) (format : OutputFormat := .png) : IO ByteArray := do
  let w := img.width.toUInt32
  let h := img.height.toUInt32
  let c := img.format.channels.toUInt32
  match format with
  | .png => FFI.encodePng w h c img.data
  | .jpeg quality => FFI.encodeJpeg w h c img.data quality
  | .bmp => throw (IO.userError "BMP encoding to memory not supported")

/-- Create a new image filled with a solid color -/
def create (width height : Nat) (format : PixelFormat := .rgba)
    (fill : List UInt8 := [0, 0, 0, 255]) : Image :=
  let channels := format.channels
  let data := Id.run do
    let mut arr : ByteArray := .empty
    for _ in [:width * height] do
      for i in [:channels] do
        arr := arr.push (fill.getD i 0)
    return arr
  { width, height, format, data }

/-- Create a copy of the image -/
def clone (img : Image) : Image :=
  { img with data := img.data }

end Image

end Raster
