/-
  Tincture - Color library for Lean 4
  Core RGBA color type.
-/

namespace Tincture

/-- Pi constant. -/
def Float.pi : Float := 3.14159265358979323846

/-- Maximum of two floats. -/
def Float.max (a b : Float) : Float := if a >= b then a else b

/-- Minimum of two floats. -/
def Float.min (a b : Float) : Float := if a <= b then a else b

/-- Absolute value of a float. -/
def Float.abs (x : Float) : Float := if x >= 0.0 then x else -x

/-- RGBA color with components in range 0.0 to 1.0. -/
structure Color where
  r : Float
  g : Float
  b : Float
  a : Float
deriving Repr, BEq, Inhabited

namespace Color

/-- Clamp a float to [0.0, 1.0] range. -/
@[inline]
def clamp01 (x : Float) : Float :=
  if x < 0.0 then 0.0 else if x > 1.0 then 1.0 else x

/-- Clamp all components to valid range. -/
def clamp (c : Color) : Color :=
  ⟨clamp01 c.r, clamp01 c.g, clamp01 c.b, clamp01 c.a⟩

/-- Create RGBA color with clamping. -/
def rgba (r g b a : Float) : Color :=
  ⟨clamp01 r, clamp01 g, clamp01 b, clamp01 a⟩

/-- Create RGB color with alpha = 1.0, with clamping. -/
def rgb (r g b : Float) : Color :=
  ⟨clamp01 r, clamp01 g, clamp01 b, 1.0⟩

/-- Create color from UInt8 components (0-255). -/
def fromRgb8 (r g b : UInt8) (a : UInt8 := 255) : Color :=
  ⟨r.toFloat / 255.0, g.toFloat / 255.0, b.toFloat / 255.0, a.toFloat / 255.0⟩

/-- Convert to UInt8 components (0-255). -/
def toRgb8 (c : Color) : UInt8 × UInt8 × UInt8 × UInt8 :=
  let r := (c.r * 255.0 + 0.5).toUInt8
  let g := (c.g * 255.0 + 0.5).toUInt8
  let b := (c.b * 255.0 + 0.5).toUInt8
  let a := (c.a * 255.0 + 0.5).toUInt8
  (r, g, b, a)

-- Standard colors
def black : Color := ⟨0.0, 0.0, 0.0, 1.0⟩
def white : Color := ⟨1.0, 1.0, 1.0, 1.0⟩
def red : Color := ⟨1.0, 0.0, 0.0, 1.0⟩
def green : Color := ⟨0.0, 1.0, 0.0, 1.0⟩
def blue : Color := ⟨0.0, 0.0, 1.0, 1.0⟩
def yellow : Color := ⟨1.0, 1.0, 0.0, 1.0⟩
def cyan : Color := ⟨0.0, 1.0, 1.0, 1.0⟩
def magenta : Color := ⟨1.0, 0.0, 1.0, 1.0⟩
def orange : Color := ⟨1.0, 0.65, 0.0, 1.0⟩
def purple : Color := ⟨0.5, 0.0, 0.5, 1.0⟩
def transparent : Color := ⟨0.0, 0.0, 0.0, 0.0⟩

-- Grays
def gray (value : Float) : Color := ⟨clamp01 value, clamp01 value, clamp01 value, 1.0⟩
def darkGray : Color := gray 0.25
def lightGray : Color := gray 0.75

/-- Set alpha channel. -/
def withAlpha (c : Color) (a : Float) : Color :=
  ⟨c.r, c.g, c.b, clamp01 a⟩

/-- Linear interpolation between two colors. -/
def lerp (c1 c2 : Color) (t : Float) : Color :=
  let t' := clamp01 t
  ⟨c1.r + (c2.r - c1.r) * t',
   c1.g + (c2.g - c1.g) * t',
   c1.b + (c2.b - c1.b) * t',
   c1.a + (c2.a - c1.a) * t'⟩

/-- Convert to premultiplied alpha (for compositing). -/
def premultiply (c : Color) : Color :=
  ⟨c.r * c.a, c.g * c.a, c.b * c.a, c.a⟩

/-- Convert from premultiplied alpha back to straight alpha. -/
def unpremultiply (c : Color) : Color :=
  if c.a == 0.0 then transparent
  else ⟨c.r / c.a, c.g / c.a, c.b / c.a, c.a⟩

/-- Check if color is opaque (alpha = 1.0). -/
def isOpaque (c : Color) : Bool := c.a >= 1.0

/-- Check if color is fully transparent. -/
def isTransparent (c : Color) : Bool := c.a <= 0.0

end Color

end Tincture
