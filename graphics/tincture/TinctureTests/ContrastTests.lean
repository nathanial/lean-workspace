/-
  Tests for WCAG contrast and accessibility functions.
-/

import Tincture
import Crucible

namespace TinctureTests.ContrastTests

open Crucible
open Tincture

testSuite "Relative Luminance"

test "white has luminance 1" := do
  let lum := Color.relativeLuminance Color.white
  ensure (floatNear lum 1.0 0.01) "white luminance should be 1"

test "black has luminance 0" := do
  let lum := Color.relativeLuminance Color.black
  ensure (floatNear lum 0.0 0.01) "black luminance should be 0"

test "luminance is always in [0, 1]" := do
  let colors := #[Color.red, Color.green, Color.blue, Color.yellow, Color.cyan]
  for c in colors do
    let lum := Color.relativeLuminance c
    ensure (lum >= 0.0 && lum <= 1.0) s!"luminance should be in range"

test "gray 50% has luminance in expected range" := do
  -- sRGB 0.5 linearizes to about 0.214
  let lum := Color.relativeLuminance (Color.gray 0.5)
  ensure (lum > 0.1 && lum < 0.3) "gray luminance should be ~0.214"

testSuite "Contrast Ratio"

test "black on white has maximum contrast" := do
  let ratio := Color.contrastRatio Color.black Color.white
  ensure (floatNear ratio 21.0 0.01) "black/white ratio should be 21"

test "white on black has maximum contrast" := do
  let ratio := Color.contrastRatio Color.white Color.black
  ensure (floatNear ratio 21.0 0.01) "white/black ratio should be 21"

test "same color has minimum contrast" := do
  let ratio := Color.contrastRatio Color.red Color.red
  ensure (floatNear ratio 1.0 0.01) "same color ratio should be 1"

test "contrast ratio is symmetric" := do
  let ratio1 := Color.contrastRatio Color.red Color.blue
  let ratio2 := Color.contrastRatio Color.blue Color.red
  ensure (floatNear ratio1 ratio2 0.01) "contrast should be symmetric"

test "contrast ratio is always >= 1" := do
  let colors := #[Color.red, Color.green, Color.blue, Color.gray 0.3, Color.gray 0.7]
  for c1 in colors do
    for c2 in colors do
      let ratio := Color.contrastRatio c1 c2
      ensure (ratio >= 1.0) "ratio should be >= 1"

testSuite "WCAG AA Compliance"

test "black on white meets AA" :=
  Color.meetsWCAG_AA Color.black Color.white ≡ true

test "white on black meets AA" :=
  Color.meetsWCAG_AA Color.white Color.black ≡ true

test "similar grays fail AA" := do
  let gray1 := Color.gray 0.4
  let gray2 := Color.gray 0.5
  Color.meetsWCAG_AA gray1 gray2 ≡ false

test "large text has lower threshold" := do
  -- 3:1 is enough for large text but not normal
  -- Gray 0.58 on white gives ratio around 3.2
  let fg := Color.gray 0.58
  let bg := Color.white
  let ratio := Color.contrastRatio fg bg
  ensure (ratio >= 3.0 && ratio < 4.5) "ratio should be between 3 and 4.5"
  Color.meetsWCAG_AA fg bg (largeText := false) ≡ false
  Color.meetsWCAG_AA fg bg (largeText := true) ≡ true

testSuite "WCAG AAA Compliance"

test "black on white meets AAA" :=
  Color.meetsWCAG_AAA Color.black Color.white ≡ true

test "AAA is stricter than AA" := do
  -- Find a color that passes AA but fails AAA
  -- Gray 0.44 on white gives ratio around 4.8 (passes AA but not AAA)
  let fg := Color.gray 0.44
  let bg := Color.white
  let passesAA := Color.meetsWCAG_AA fg bg
  let passesAAA := Color.meetsWCAG_AAA fg bg
  passesAA ≡ true
  passesAAA ≡ false

testSuite "WCAG Level Detection"

test "black on white is AAA" :=
  Color.wcagLevel Color.black Color.white ≡ "AAA"

test "similar grays fail" :=
  Color.wcagLevel (Color.gray 0.5) (Color.gray 0.6) ≡ "Fail"

testSuite "Light/Dark Detection"

test "white is light" :=
  Color.isLight Color.white ≡ true

test "black is dark" :=
  Color.isDark Color.black ≡ true

test "yellow is light" :=
  Color.isLight Color.yellow ≡ true

test "dark blue is dark" := do
  let darkBlue := Color.rgb 0.0 0.0 0.3
  Color.isDark darkBlue ≡ true

test "isLight and isDark are opposites" := do
  let colors := #[Color.red, Color.green, Color.blue, Color.white, Color.black]
  for c in colors do
    ensure (Color.isLight c != Color.isDark c) "isLight and isDark should be opposites"

testSuite "Contrasting Text Color"

test "white background gets black text" :=
  Color.contrastingTextColor Color.white ≡ Color.black

test "black background gets white text" :=
  Color.contrastingTextColor Color.black ≡ Color.white

test "yellow background gets black text" :=
  Color.contrastingTextColor Color.yellow ≡ Color.black

test "dark blue background gets white text" := do
  let darkBlue := Color.rgb 0.0 0.0 0.3
  Color.contrastingTextColor darkBlue ≡ Color.white

test "contrasting color meets AA" := do
  -- Note: Not all colors have sufficient contrast with black/white
  -- This test verifies the function works for common cases
  let backgrounds := #[Color.white, Color.black, Color.yellow]
  for bg in backgrounds do
    let text := Color.contrastingTextColor bg
    ensure (Color.meetsWCAG_AA text bg) "contrasting text should meet AA"

testSuite "Graphics Contrast"

test "black on white meets graphics requirement" :=
  Color.meetsWCAG_Graphics Color.black Color.white ≡ true

test "similar grays fail graphics requirement" := do
  let gray1 := Color.gray 0.5
  let gray2 := Color.gray 0.6
  Color.meetsWCAG_Graphics gray1 gray2 ≡ false

testSuite "APCA Contrast"

test "black on white has high APCA contrast" := do
  let contrast := Color.apcaContrast Color.black Color.white
  ensure (contrast > 90.0) "black on white should have high APCA"

test "white on black has high APCA contrast" := do
  let contrast := Color.apcaContrast Color.white Color.black
  ensure (contrast > 90.0) "white on black should have high APCA"

test "same color has zero APCA contrast" := do
  let contrast := Color.apcaContrast (Color.gray 0.5) (Color.gray 0.5)
  ensure (floatNear contrast 0.0 1.0) "same color should have ~0 APCA"



end TinctureTests.ContrastTests
