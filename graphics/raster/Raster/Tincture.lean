/-
  Raster.Tincture - Optional Tincture color integration
-/
import Raster.Color
import Tincture.Space.HSV

namespace Raster

private def pixelToColor (format : PixelFormat) (values : List UInt8) : Tincture.Color :=
  match format with
  | .gray =>
    let g := values.getD 0 0
    Tincture.Color.fromRgb8 g g g 255
  | .grayA =>
    let g := values.getD 0 0
    let a := values.getD 1 255
    Tincture.Color.fromRgb8 g g g a
  | .rgb =>
    let r := values.getD 0 0
    let g := values.getD 1 0
    let b := values.getD 2 0
    Tincture.Color.fromRgb8 r g b 255
  | .rgba =>
    let r := values.getD 0 0
    let g := values.getD 1 0
    let b := values.getD 2 0
    let a := values.getD 3 255
    Tincture.Color.fromRgb8 r g b a

private def colorToPixel (format : PixelFormat) (color : Tincture.Color) : List UInt8 :=
  let (r, g, b, a) := Tincture.Color.toRgb8 color
  let gray :=
    ((r.toFloat * 0.299 + g.toFloat * 0.587 + b.toFloat * 0.114).toUInt8)
  match format with
  | .gray => [gray]
  | .grayA => [gray, a]
  | .rgb => [r, g, b]
  | .rgba => [r, g, b, a]

private def mapColors (img : Image) (f : Tincture.Color → Tincture.Color) : Image :=
  img.mapPixels fun px =>
    colorToPixel img.format (f (pixelToColor img.format px))

/-- Get pixel value at (x, y) as a Tincture color. -/
def Image.getPixelColor (img : Image) (x y : Nat) : Option Tincture.Color :=
  (img.getPixel x y).map (pixelToColor img.format)

/-- Set pixel value at (x, y) using a Tincture color. -/
def Image.setPixelColor (img : Image) (x y : Nat) (color : Tincture.Color) : Image :=
  img.setPixel x y (colorToPixel img.format color)

/-- Rotate image hue by degrees (HSV space). -/
def Image.adjustHue (img : Image) (degrees : Float) : Image :=
  let delta := degrees / 360.0
  mapColors img fun c =>
    let hsv := Tincture.Color.toHSV c
    let h' := (hsv.h + delta) - (hsv.h + delta).floor
    Tincture.Color.fromHSV ⟨h', hsv.s, hsv.v⟩ c.a

/-- Scale saturation by a factor (1.0 = no change). -/
def Image.adjustSaturation (img : Image) (factor : Float) : Image :=
  mapColors img fun c =>
    let hsv := Tincture.Color.toHSV c
    let s' := Tincture.Color.clamp01 (hsv.s * factor)
    Tincture.Color.fromHSV ⟨hsv.h, s', hsv.v⟩ c.a

/-- Scale brightness by a factor (1.0 = no change). -/
def Image.adjustBrightness (img : Image) (factor : Float) : Image :=
  mapColors img fun c =>
    let hsv := Tincture.Color.toHSV c
    let v' := Tincture.Color.clamp01 (hsv.v * factor)
    Tincture.Color.fromHSV ⟨hsv.h, hsv.s, v'⟩ c.a

end Raster
