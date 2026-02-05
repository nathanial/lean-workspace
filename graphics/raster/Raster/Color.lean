/-
  Raster.Color - Pixel access and color utilities
-/
import Raster.Core.Types

namespace Raster

/-- Get pixel value at (x, y) as a list of channel values -/
def Image.getPixel (img : Image) (x y : Nat) : Option (List UInt8) :=
  if x >= img.width || y >= img.height then none
  else
    let channels := img.format.channels
    let idx := (y * img.width + x) * channels
    some (List.range channels |>.map fun c => img.data.get! (idx + c))

/-- Get pixel value at (x, y), returning default if out of bounds -/
def Image.getPixelD (img : Image) (x y : Nat) (default : List UInt8 := [0, 0, 0, 255]) : List UInt8 :=
  img.getPixel x y |>.getD default

/-- Set pixel value at (x, y) -/
def Image.setPixel (img : Image) (x y : Nat) (values : List UInt8) : Image :=
  if x >= img.width || y >= img.height then img
  else
    let channels := img.format.channels
    let idx := (y * img.width + x) * channels
    let newData := Id.run do
      let mut data := img.data
      for c in [:min channels values.length] do
        data := data.set! (idx + c) (values.getD c 0)
      return data
    { img with data := newData }

/-- Map over pixels, preserving image dimensions and format. -/
def Image.mapPixels (img : Image) (f : List UInt8 → List UInt8) : Image :=
  let channels := img.format.channels
  let newData := Id.run do
    let mut data : ByteArray := .empty
    for i in [:img.width * img.height] do
      let idx := i * channels
      let pixel := List.range channels |>.map fun c => img.data.get! (idx + c)
      let newPixel := f pixel
      for c in [:channels] do
        data := data.push (newPixel.getD c 0)
    return data
  { img with data := newData }

/-- Get red channel (for RGB/RGBA images) -/
def Image.getRed (img : Image) (x y : Nat) : Option UInt8 :=
  if img.format == .rgb || img.format == .rgba then
    (img.getPixel x y).bind fun px => px[0]?
  else none

/-- Get green channel (for RGB/RGBA images) -/
def Image.getGreen (img : Image) (x y : Nat) : Option UInt8 :=
  if img.format == .rgb || img.format == .rgba then
    (img.getPixel x y).bind fun px => px[1]?
  else none

/-- Get blue channel (for RGB/RGBA images) -/
def Image.getBlue (img : Image) (x y : Nat) : Option UInt8 :=
  if img.format == .rgb || img.format == .rgba then
    (img.getPixel x y).bind fun px => px[2]?
  else none

/-- Get alpha channel (for RGBA/GrayA images) -/
def Image.getAlpha (img : Image) (x y : Nat) : Option UInt8 :=
  match img.format with
  | .rgba => (img.getPixel x y).bind fun px => px[3]?
  | .grayA => (img.getPixel x y).bind fun px => px[1]?
  | _ => none

/-- Get grayscale value (for gray/grayA images) -/
def Image.getGray (img : Image) (x y : Nat) : Option UInt8 :=
  match img.format with
  | .gray | .grayA => (img.getPixel x y).bind fun px => px[0]?
  | _ => none

/-- Fill entire image with a solid color -/
def Image.fill (img : Image) (color : List UInt8) : Image :=
  let channels := img.format.channels
  let newData := Id.run do
    let mut data : ByteArray := .empty
    for _ in [:img.width * img.height] do
      for c in [:channels] do
        data := data.push (color.getD c 0)
    return data
  { img with data := newData }

/-- Convert image to grayscale using luminance formula -/
def Image.toGrayscale (img : Image) : Image :=
  match img.format with
  | .gray | .grayA => img  -- Already grayscale
  | .rgb | .rgba =>
    let hasAlpha := img.format == .rgba
    let newFormat := if hasAlpha then PixelFormat.grayA else PixelFormat.gray
    let newData := Id.run do
      let mut data : ByteArray := .empty
      for y in [:img.height] do
        for x in [:img.width] do
          let idx := (y * img.width + x) * img.format.channels
          let r := img.data.get! idx
          let g := img.data.get! (idx + 1)
          let b := img.data.get! (idx + 2)
          -- Standard luminance formula: 0.299*R + 0.587*G + 0.114*B
          let gray := ((r.toFloat * 0.299 + g.toFloat * 0.587 + b.toFloat * 0.114).toUInt8)
          data := data.push gray
          if hasAlpha then
            let a := img.data.get! (idx + 3)
            data := data.push a
      return data
    { width := img.width, height := img.height, format := newFormat, data := newData }

end Raster
