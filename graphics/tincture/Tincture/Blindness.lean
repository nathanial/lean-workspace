/-
  Tincture - Color Blindness Simulation
  Simulate how colors appear to people with color vision deficiencies.
-/

import Tincture.Color

namespace Tincture

/-- Types of color vision deficiency (CVD). -/
inductive ColorBlindness where
  | protanopia    -- Red-blind (no L cones)
  | deuteranopia  -- Green-blind (no M cones)
  | tritanopia    -- Blue-blind (no S cones)
  | protanomaly   -- Red-weak (anomalous L cones)
  | deuteranomaly -- Green-weak (anomalous M cones)
  | tritanomaly   -- Blue-weak (anomalous S cones)
  | achromatopsia -- Complete color blindness (monochromacy)
deriving Repr, BEq, Inhabited

namespace ColorBlindness

/-- Get description of the color blindness type. -/
def description : ColorBlindness → String
  | .protanopia => "Red-blind (protanopia) - Cannot perceive red light"
  | .deuteranopia => "Green-blind (deuteranopia) - Cannot perceive green light"
  | .tritanopia => "Blue-blind (tritanopia) - Cannot perceive blue light"
  | .protanomaly => "Red-weak (protanomaly) - Reduced sensitivity to red"
  | .deuteranomaly => "Green-weak (deuteranomaly) - Reduced sensitivity to green"
  | .tritanomaly => "Blue-weak (tritanomaly) - Reduced sensitivity to blue"
  | .achromatopsia => "Complete color blindness - Sees only grayscale"

/-- Get prevalence in the general population (approximate). -/
def prevalence : ColorBlindness → String
  | .protanopia => "~1% of males"
  | .deuteranopia => "~1% of males"
  | .tritanopia => "~0.01% of population"
  | .protanomaly => "~1% of males"
  | .deuteranomaly => "~5% of males"
  | .tritanomaly => "~0.01% of population"
  | .achromatopsia => "~0.003% of population"

end ColorBlindness

namespace Color

/-- Apply gamma correction sRGB -> linear. -/
private def toLinear (v : Float) : Float :=
  if v <= 0.04045 then v / 12.92
  else ((v + 0.055) / 1.055) ^ 2.4

/-- Apply gamma correction linear -> sRGB. -/
private def fromLinear (v : Float) : Float :=
  if v <= 0.0031308 then v * 12.92
  else 1.055 * (v ^ (1.0 / 2.4)) - 0.055

/-- Simulate protanopia (red-blind). -/
private def simulateProtanopia (c : Color) : Color :=
  let r := toLinear c.r
  let g := toLinear c.g
  let b := toLinear c.b
  let r' := 0.567 * r + 0.433 * g + 0.0 * b
  let g' := 0.558 * r + 0.442 * g + 0.0 * b
  let b' := 0.0 * r + 0.242 * g + 0.758 * b
  ⟨clamp01 (fromLinear r'), clamp01 (fromLinear g'), clamp01 (fromLinear b'), c.a⟩

/-- Simulate deuteranopia (green-blind). -/
private def simulateDeuteranopia (c : Color) : Color :=
  let r := toLinear c.r
  let g := toLinear c.g
  let b := toLinear c.b
  let r' := 0.625 * r + 0.375 * g + 0.0 * b
  let g' := 0.700 * r + 0.300 * g + 0.0 * b
  let b' := 0.0 * r + 0.300 * g + 0.700 * b
  ⟨clamp01 (fromLinear r'), clamp01 (fromLinear g'), clamp01 (fromLinear b'), c.a⟩

/-- Simulate tritanopia (blue-blind). -/
private def simulateTritanopia (c : Color) : Color :=
  let r := toLinear c.r
  let g := toLinear c.g
  let b := toLinear c.b
  let r' := 0.950 * r + 0.050 * g + 0.0 * b
  let g' := 0.0 * r + 0.433 * g + 0.567 * b
  let b' := 0.0 * r + 0.475 * g + 0.525 * b
  ⟨clamp01 (fromLinear r'), clamp01 (fromLinear g'), clamp01 (fromLinear b'), c.a⟩

/-- Simulate color blindness using Brettel's method.
    This provides accurate simulation for dichromacy (complete color blindness). -/
def simulateColorBlindness (c : Color) (cvd : ColorBlindness) : Color :=
  match cvd with
  | .achromatopsia =>
    -- Complete color blindness - convert to grayscale
    let lum := 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
    ⟨lum, lum, lum, c.a⟩
  | .protanopia => simulateProtanopia c
  | .deuteranopia => simulateDeuteranopia c
  | .tritanopia => simulateTritanopia c
  | .protanomaly =>
    -- Anomalous trichromacy: blend between normal and protanopia
    let simulated := simulateProtanopia c
    lerp c simulated 0.6  -- 60% severity
  | .deuteranomaly =>
    -- Anomalous trichromacy: blend between normal and deuteranopia
    let simulated := simulateDeuteranopia c
    lerp c simulated 0.6
  | .tritanomaly =>
    -- Anomalous trichromacy: blend between normal and tritanopia
    let simulated := simulateTritanopia c
    lerp c simulated 0.6

/-- Simulate color blindness with adjustable severity.
    severity: 0.0 = normal vision, 1.0 = full dichromacy -/
def simulateColorBlindnessSeverity (c : Color) (cvd : ColorBlindness) (severity : Float) : Color :=
  match cvd with
  | .achromatopsia =>
    let lum := 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
    let gray : Color := ⟨lum, lum, lum, c.a⟩
    lerp c gray (clamp01 severity)
  | .protanomaly | .deuteranomaly | .tritanomaly =>
    -- Get the "full" version
    let fullCvd := match cvd with
      | .protanomaly => ColorBlindness.protanopia
      | .deuteranomaly => ColorBlindness.deuteranopia
      | _ => ColorBlindness.tritanopia
    let simulated := simulateColorBlindness c fullCvd
    lerp c simulated (clamp01 severity)
  | _ =>
    -- Already full dichromacy, just apply severity
    let simulated := simulateColorBlindness c cvd
    lerp c simulated (clamp01 severity)

/-- Check if two colors are distinguishable for a person with color blindness. -/
def isDistinguishableFor (c1 c2 : Color) (cvd : ColorBlindness) (threshold : Float := 0.1) : Bool :=
  let s1 := simulateColorBlindness c1 cvd
  let s2 := simulateColorBlindness c2 cvd
  let dr := s1.r - s2.r
  let dg := s1.g - s2.g
  let db := s1.b - s2.b
  Float.sqrt (dr * dr + dg * dg + db * db) > threshold

end Color

end Tincture
