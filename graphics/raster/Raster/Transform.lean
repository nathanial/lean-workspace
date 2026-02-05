/-
  Raster.Transform - Image transformation operations
-/
import Raster.Core.Types
import Raster.Core.Error
import Raster.FFI.Resize

namespace Raster

namespace Transform

/-- Resize image to new dimensions using high-quality linear interpolation -/
def resize (img : Image) (newWidth newHeight : Nat) : IO Image := do
  let newData ← FFI.resize img.data
      img.width.toUInt32 img.height.toUInt32
      newWidth.toUInt32 newHeight.toUInt32
      img.format.channels.toUInt8
  return { img with width := newWidth, height := newHeight, data := newData }

/-- Scale image by a factor (e.g., 0.5 for half size, 2.0 for double) -/
def scale (img : Image) (factor : Float) : IO Image := do
  let newWidth := max 1 (img.width.toFloat * factor).toUInt32.toNat
  let newHeight := max 1 (img.height.toFloat * factor).toUInt32.toNat
  resize img newWidth newHeight

/-- Crop a rectangular region from the image -/
def crop (img : Image) (x y cropWidth cropHeight : Nat) : RasterResult Image := do
  if x + cropWidth > img.width || y + cropHeight > img.height then
    throw (.outOfBounds x y img.width img.height)
  if cropWidth == 0 || cropHeight == 0 then
    throw (.invalidDimensions cropWidth cropHeight)

  let channels := img.format.channels
  let newData := Id.run do
    let mut data : ByteArray := .empty
    for row in [:cropHeight] do
      let srcStart := ((y + row) * img.width + x) * channels
      for col in [:cropWidth] do
        for c in [:channels] do
          let idx := srcStart + col * channels + c
          data := data.push (img.data.get! idx)
    return data

  return { width := cropWidth, height := cropHeight, format := img.format, data := newData }

/-- Flip image horizontally (mirror) -/
def flipHorizontal (img : Image) : Image :=
  let channels := img.format.channels
  let newData := Id.run do
    let mut data : ByteArray := .empty
    for y in [:img.height] do
      for x in [:img.width] do
        let srcX := img.width - 1 - x
        let srcIdx := (y * img.width + srcX) * channels
        for c in [:channels] do
          data := data.push (img.data.get! (srcIdx + c))
    return data
  { img with data := newData }

/-- Flip image vertically -/
def flipVertical (img : Image) : Image :=
  let channels := img.format.channels
  let rowSize := img.width * channels
  let newData := Id.run do
    let mut data : ByteArray := .empty
    for y in [:img.height] do
      let srcY := img.height - 1 - y
      let srcStart := srcY * rowSize
      for i in [:rowSize] do
        data := data.push (img.data.get! (srcStart + i))
    return data
  { img with data := newData }

/-- Rotate image 90 degrees clockwise -/
def rotate90 (img : Image) : Image :=
  let channels := img.format.channels
  let newWidth := img.height
  let newHeight := img.width
  let newData := Id.run do
    let mut data : ByteArray := .empty
    for y in [:newHeight] do
      for x in [:newWidth] do
        -- New (x, y) comes from old (y, height - 1 - x)
        let srcX := y
        let srcY := img.height - 1 - x
        let srcIdx := (srcY * img.width + srcX) * channels
        for c in [:channels] do
          data := data.push (img.data.get! (srcIdx + c))
    return data
  { width := newWidth, height := newHeight, format := img.format, data := newData }

/-- Rotate image 180 degrees -/
def rotate180 (img : Image) : Image :=
  flipHorizontal (flipVertical img)

/-- Rotate image 270 degrees clockwise (90 counter-clockwise) -/
def rotate270 (img : Image) : Image :=
  let channels := img.format.channels
  let newWidth := img.height
  let newHeight := img.width
  let newData := Id.run do
    let mut data : ByteArray := .empty
    for y in [:newHeight] do
      for x in [:newWidth] do
        -- New (x, y) comes from old (width - 1 - y, x)
        let srcX := newHeight - 1 - y
        let srcY := x
        let srcIdx := (srcY * img.width + srcX) * channels
        for c in [:channels] do
          data := data.push (img.data.get! (srcIdx + c))
    return data
  { width := newWidth, height := newHeight, format := img.format, data := newData }

end Transform

end Raster
