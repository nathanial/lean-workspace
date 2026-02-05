/-
  Tincture - WCAG Contrast and Accessibility
  Calculate contrast ratios and check WCAG compliance.
-/

import Tincture.Color

namespace Tincture

namespace Color

/-- Calculate relative luminance according to WCAG 2.1.
    Returns value in range [0, 1]. -/
def relativeLuminance (c : Color) : Float :=
  let toLinear (v : Float) : Float :=
    if v <= 0.04045 then v / 12.92
    else ((v + 0.055) / 1.055) ^ 2.4
  let r := toLinear c.r
  let g := toLinear c.g
  let b := toLinear c.b
  0.2126 * r + 0.7152 * g + 0.0722 * b

/-- Calculate contrast ratio between two colors (WCAG 2.1).
    Returns value in range [1, 21]. -/
def contrastRatio (c1 c2 : Color) : Float :=
  let l1 := relativeLuminance c1
  let l2 := relativeLuminance c2
  let lighter := Float.max l1 l2
  let darker := Float.min l1 l2
  (lighter + 0.05) / (darker + 0.05)

/-- WCAG 2.1 Level AA requirements for normal text (4.5:1). -/
def meetsWCAG_AA (foreground background : Color) (largeText : Bool := false) : Bool :=
  let ratio := contrastRatio foreground background
  if largeText then ratio >= 3.0 else ratio >= 4.5

/-- WCAG 2.1 Level AAA requirements for normal text (7:1). -/
def meetsWCAG_AAA (foreground background : Color) (largeText : Bool := false) : Bool :=
  let ratio := contrastRatio foreground background
  if largeText then ratio >= 4.5 else ratio >= 7.0

/-- WCAG 2.1 requirements for UI components and graphics (3:1). -/
def meetsWCAG_Graphics (c1 c2 : Color) : Bool :=
  contrastRatio c1 c2 >= 3.0

/-- Get WCAG conformance level as a string. -/
def wcagLevel (foreground background : Color) (largeText : Bool := false) : String :=
  let ratio := contrastRatio foreground background
  if largeText then
    if ratio >= 4.5 then "AAA"
    else if ratio >= 3.0 then "AA"
    else "Fail"
  else
    if ratio >= 7.0 then "AAA"
    else if ratio >= 4.5 then "AA"
    else "Fail"

/-- Check if this color is considered "light" (luminance > 0.5). -/
def isLight (c : Color) : Bool :=
  relativeLuminance c > 0.5

/-- Check if this color is considered "dark". -/
def isDark (c : Color) : Bool :=
  not (isLight c)

/-- Get optimal text color (black or white) for readability on this background. -/
def contrastingTextColor (background : Color) : Color :=
  if isLight background then black else white

/-- Calculate the APCAcontrast (Advanced Perceptual Contrast Algorithm).
    More accurate than WCAG 2.1 for web content.
    Returns value in range roughly [-100, 100]. Positive = light on dark. -/
def apcaContrast (text background : Color) : Float :=
  -- Simplified APCA-W3 algorithm
  let toLinear (v : Float) : Float := v ^ 2.4

  let txtY := 0.2126729 * toLinear text.r + 0.7151522 * toLinear text.g + 0.0721750 * toLinear text.b
  let bgY := 0.2126729 * toLinear background.r + 0.7151522 * toLinear background.g + 0.0721750 * toLinear background.b

  -- APCA contrast calculation
  let normBG := 0.56
  let normTXT := 0.57
  let revBG := 0.62
  let revTXT := 0.65

  if bgY > txtY then
    -- Light background
    let sRGB := bgY ^ normBG - txtY ^ normTXT
    if sRGB < 0.001 then 0.0 else sRGB * 100.0
  else
    -- Dark background
    let sRGB := bgY ^ revBG - txtY ^ revTXT
    if sRGB > -0.001 then 0.0 else sRGB * -100.0

end Color

end Tincture
