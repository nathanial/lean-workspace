/-
  Tincture - Color Distance Metrics
  Delta E and other perceptual color difference calculations.
-/

import Tincture.Space.Lab
import Tincture.Space.LCH

namespace Tincture

namespace Color

/-- Simple Euclidean distance in RGB space. -/
def euclideanDistance (c1 c2 : Color) : Float :=
  let dr := c1.r - c2.r
  let dg := c1.g - c2.g
  let db := c1.b - c2.b
  Float.sqrt (dr * dr + dg * dg + db * db)

/-- CIE76 Delta E (Euclidean distance in Lab space).
    Simple but less accurate than newer formulas.
    Values: <1 not perceptible, 1-2 close look, 2-10 noticeable, >10 different -/
def deltaE76 (c1 c2 : Color) : Float :=
  let lab1 := Lab.fromColor c1
  let lab2 := Lab.fromColor c2
  let dL := lab1.l - lab2.l
  let da := lab1.a - lab2.a
  let db := lab1.b - lab2.b
  Float.sqrt (dL * dL + da * da + db * db)

/-- CIE94 Delta E. Accounts for perceptual non-uniformity.
    Better than CIE76 for industrial applications. -/
def deltaE94 (c1 c2 : Color) (textiles : Bool := false) : Float :=
  let lab1 := Lab.fromColor c1
  let lab2 := Lab.fromColor c2

  let dL := lab1.l - lab2.l
  let c1' := Float.sqrt (lab1.a * lab1.a + lab1.b * lab1.b)
  let c2' := Float.sqrt (lab2.a * lab2.a + lab2.b * lab2.b)
  let dC := c1' - c2'

  let da := lab1.a - lab2.a
  let db := lab1.b - lab2.b
  let dH2 := da * da + db * db - dC * dC
  let dH := if dH2 > 0.0 then Float.sqrt dH2 else 0.0

  -- Weighting factors (different for textiles)
  let kL := if textiles then 2.0 else 1.0
  let k1 := if textiles then 0.048 else 0.045
  let k2 := if textiles then 0.014 else 0.015

  let sL := 1.0
  let sC := 1.0 + k1 * c1'
  let sH := 1.0 + k2 * c1'

  let termL := dL / (kL * sL)
  let termC := dC / sC
  let termH := dH / sH

  Float.sqrt (termL * termL + termC * termC + termH * termH)

/-- CIEDE2000 Delta E. The most accurate color difference formula.
    Accounts for perceptual non-uniformity and hue-dependent effects. -/
def deltaE2000 (c1 c2 : Color) : Float :=
  let lab1 := Lab.fromColor c1
  let lab2 := Lab.fromColor c2

  let π := Float.pi
  let rad := π / 180.0

  -- Step 1: Calculate C'_i and h'_i
  let c1Star := Float.sqrt (lab1.a * lab1.a + lab1.b * lab1.b)
  let c2Star := Float.sqrt (lab2.a * lab2.a + lab2.b * lab2.b)
  let cBarStar := (c1Star + c2Star) / 2.0

  let cBar7 := cBarStar ^ 7.0
  let g := 0.5 * (1.0 - Float.sqrt (cBar7 / (cBar7 + 6103515625.0)))  -- 25^7

  let a1Prime := lab1.a * (1.0 + g)
  let a2Prime := lab2.a * (1.0 + g)

  let c1Prime := Float.sqrt (a1Prime * a1Prime + lab1.b * lab1.b)
  let c2Prime := Float.sqrt (a2Prime * a2Prime + lab2.b * lab2.b)

  let h1Prime :=
    if lab1.b == 0.0 && a1Prime == 0.0 then 0.0
    else
      let h := Float.atan2 lab1.b a1Prime * 180.0 / π
      if h < 0.0 then h + 360.0 else h

  let h2Prime :=
    if lab2.b == 0.0 && a2Prime == 0.0 then 0.0
    else
      let h := Float.atan2 lab2.b a2Prime * 180.0 / π
      if h < 0.0 then h + 360.0 else h

  -- Step 2: Calculate dL', dC', dH'
  let dLPrime := lab2.l - lab1.l
  let dCPrime := c2Prime - c1Prime

  let dhPrime :=
    if c1Prime * c2Prime == 0.0 then 0.0
    else
      let dh := h2Prime - h1Prime
      if dh > 180.0 then dh - 360.0
      else if dh < -180.0 then dh + 360.0
      else dh

  let dHPrime := 2.0 * Float.sqrt (c1Prime * c2Prime) * Float.sin (dhPrime * rad / 2.0)

  -- Step 3: Calculate CIEDE2000
  let lBarPrime := (lab1.l + lab2.l) / 2.0
  let cBarPrime := (c1Prime + c2Prime) / 2.0

  let hBarPrime :=
    if c1Prime * c2Prime == 0.0 then h1Prime + h2Prime
    else
      let hSum := h1Prime + h2Prime
      let hDiff := Float.abs (h1Prime - h2Prime)
      if hDiff <= 180.0 then hSum / 2.0
      else if hSum < 360.0 then (hSum + 360.0) / 2.0
      else (hSum - 360.0) / 2.0

  let t := 1.0
       - 0.17 * Float.cos ((hBarPrime - 30.0) * rad)
       + 0.24 * Float.cos (2.0 * hBarPrime * rad)
       + 0.32 * Float.cos ((3.0 * hBarPrime + 6.0) * rad)
       - 0.20 * Float.cos ((4.0 * hBarPrime - 63.0) * rad)

  let dTheta := 30.0 * Float.exp (-(((hBarPrime - 275.0) / 25.0) ^ 2.0))

  let cBar7' := cBarPrime ^ 7.0
  let rC := 2.0 * Float.sqrt (cBar7' / (cBar7' + 6103515625.0))

  let lBar50 := (lBarPrime - 50.0) ^ 2.0
  let sL := 1.0 + (0.015 * lBar50) / Float.sqrt (20.0 + lBar50)
  let sC := 1.0 + 0.045 * cBarPrime
  let sH := 1.0 + 0.015 * cBarPrime * t

  let rT := -Float.sin (2.0 * dTheta * rad) * rC

  let termL := dLPrime / sL
  let termC := dCPrime / sC
  let termH := dHPrime / sH

  Float.sqrt (termL * termL + termC * termC + termH * termH + rT * termC * termH)

/-- Check if two colors are perceptually similar.
    Default threshold of 2.3 is "just noticeable difference" (JND). -/
def isPerceptuallySimilar (c1 c2 : Color) (threshold : Float := 2.3) : Bool :=
  deltaE2000 c1 c2 <= threshold

/-- Get the closest color from a list to the target color. -/
def closest (target : Color) (colors : Array Color) : Option Color :=
  if colors.isEmpty then none
  else
    let rec go (i : Nat) (best : Color) (bestDist : Float) : Color :=
      if i >= colors.size then best
      else
        let c := colors[i]!
        let dist := deltaE2000 target c
        if dist < bestDist then
          go (i + 1) c dist
        else
          go (i + 1) best bestDist
    some (go 1 colors[0]! (deltaE2000 target colors[0]!))

end Color

end Tincture
