/-
  Tests for color blending operations.
-/

import Tincture
import Crucible

namespace TinctureTests.BlendTests

open Crucible
open Tincture

/-- Helper to check if two colors are approximately equal. -/
def colorApproxEq (c1 c2 : Color) (epsilon : Float := 0.01) : Bool :=
  floatNear c1.r c2.r epsilon &&
  floatNear c1.g c2.g epsilon &&
  floatNear c1.b c2.b epsilon

testSuite "Blend Modes"

test "normal blend returns top layer" := do
  let result := Color.blend .normal Color.red Color.blue
  ensure (colorApproxEq result Color.blue) "normal blend should return top"

test "multiply with white is identity" := do
  let c := Color.rgb 0.5 0.3 0.7
  let result := Color.blend .multiply c Color.white
  ensure (colorApproxEq result c) "multiply with white should be identity"

test "multiply with black is black" := do
  let c := Color.rgb 0.5 0.3 0.7
  let result := Color.blend .multiply c Color.black
  ensure (floatNear result.r 0.0 0.01) "r should be 0"
  ensure (floatNear result.g 0.0 0.01) "g should be 0"
  ensure (floatNear result.b 0.0 0.01) "b should be 0"

test "multiply is commutative" := do
  let c1 := Color.rgb 0.5 0.3 0.7
  let c2 := Color.rgb 0.8 0.4 0.2
  let r1 := Color.blend .multiply c1 c2
  let r2 := Color.blend .multiply c2 c1
  ensure (colorApproxEq r1 r2) "multiply should be commutative"

test "screen with black is identity" := do
  let c := Color.rgb 0.5 0.3 0.7
  let result := Color.blend .screen c Color.black
  ensure (colorApproxEq result c) "screen with black should be identity"

test "screen with white is white" := do
  let c := Color.rgb 0.5 0.3 0.7
  let result := Color.blend .screen c Color.white
  ensure (floatNear result.r 1.0 0.01) "r should be 1"
  ensure (floatNear result.g 1.0 0.01) "g should be 1"
  ensure (floatNear result.b 1.0 0.01) "b should be 1"

test "screen is commutative" := do
  let c1 := Color.rgb 0.5 0.3 0.7
  let c2 := Color.rgb 0.8 0.4 0.2
  let r1 := Color.blend .screen c1 c2
  let r2 := Color.blend .screen c2 c1
  ensure (colorApproxEq r1 r2) "screen should be commutative"

test "darken returns minimum per channel" := do
  let c1 := Color.rgb 0.8 0.2 0.5
  let c2 := Color.rgb 0.3 0.9 0.5
  let result := Color.blend .darken c1 c2
  ensure (floatNear result.r 0.3 0.01) "r should be min"
  ensure (floatNear result.g 0.2 0.01) "g should be min"
  ensure (floatNear result.b 0.5 0.01) "b should be min"

test "lighten returns maximum per channel" := do
  let c1 := Color.rgb 0.8 0.2 0.5
  let c2 := Color.rgb 0.3 0.9 0.5
  let result := Color.blend .lighten c1 c2
  ensure (floatNear result.r 0.8 0.01) "r should be max"
  ensure (floatNear result.g 0.9 0.01) "g should be max"
  ensure (floatNear result.b 0.5 0.01) "b should be max"

test "difference of same color is black" := do
  let c := Color.rgb 0.5 0.3 0.7
  let result := Color.blend .difference c c
  ensure (floatNear result.r 0.0 0.01) "r should be 0"
  ensure (floatNear result.g 0.0 0.01) "g should be 0"
  ensure (floatNear result.b 0.0 0.01) "b should be 0"

test "exclusion of gray 0.5 with itself" := do
  let c := Color.rgb 0.5 0.5 0.5
  let result := Color.blend .exclusion c c
  -- exclusion(0.5, 0.5) = 0.5 + 0.5 - 2*0.5*0.5 = 0.5
  ensure (floatNear result.r 0.5 0.01) "exclusion of 0.5 with itself should be 0.5"

testSuite "Blend Shorthand Functions"

test "multiply shorthand works" := do
  let c1 := Color.rgb 0.5 0.5 0.5
  let c2 := Color.rgb 0.5 0.5 0.5
  let result := Color.multiply c1 c2
  ensure (floatNear result.r 0.25 0.01) "multiply 0.5 * 0.5 = 0.25"

test "screen shorthand works" := do
  let c1 := Color.rgb 0.5 0.5 0.5
  let c2 := Color.rgb 0.5 0.5 0.5
  let result := Color.screen c1 c2
  -- screen(0.5, 0.5) = 1 - (1-0.5)(1-0.5) = 0.75
  ensure (floatNear result.r 0.75 0.01) "screen(0.5, 0.5) = 0.75"

test "overlay shorthand works" := do
  let c1 := Color.rgb 0.3 0.7 0.5
  let c2 := Color.rgb 0.6 0.4 0.5
  let r1 := Color.overlay c1 c2
  let r2 := Color.blend .overlay c1 c2
  ensure (colorApproxEq r1 r2) "overlay shorthand should equal blend"

testSuite "Alpha Blending"

test "fully transparent top preserves base" := do
  let base := Color.red
  let top := Color.blue.withAlpha 0.0
  let result := Color.blendAlpha .normal base top
  ensure (colorApproxEq result Color.red) "transparent top should preserve base"

test "fully opaque top replaces base" := do
  let base := Color.red
  let top := Color.blue.withAlpha 1.0
  let result := Color.blendAlpha .normal base top
  ensure (colorApproxEq result Color.blue) "opaque top should replace base"

test "50% alpha gives blend of colors" := do
  let base := Color.red
  let top := Color.blue.withAlpha 0.5
  let result := Color.blendAlpha .normal base top
  ensure (result.r > 0.0 && result.r < 1.0) "r should be blended"
  ensure (result.b > 0.0 && result.b < 1.0) "b should be blended"

test "over compositing works" := do
  let base := Color.white
  let top := Color.red.withAlpha 0.5
  let result := Color.over base top
  result.a ≡ 1.0
  ensure (result.r > 0.9) "r should be high"

testSuite "Color Mixing"

test "mix at 0 returns first color" := do
  let result := Color.mix Color.red Color.blue 0.0
  ensure (colorApproxEq result Color.red) "mix at 0 should return first"

test "mix at 1 returns second color" := do
  let result := Color.mix Color.red Color.blue 1.0
  ensure (colorApproxEq result Color.blue) "mix at 1 should return second"

test "mix at 0.5 returns midpoint" := do
  let result := Color.mix Color.black Color.white 0.5
  ensure (floatNear result.r 0.5 0.01) "r should be 0.5"
  ensure (floatNear result.g 0.5 0.01) "g should be 0.5"
  ensure (floatNear result.b 0.5 0.01) "b should be 0.5"

test "mixOkLab produces valid colors" := do
  let result := Color.mixOkLab Color.red Color.blue 0.5
  ensure (result.r >= 0.0 && result.r <= 1.0) "r should be in range"
  ensure (result.g >= 0.0 && result.g <= 1.0) "g should be in range"
  ensure (result.b >= 0.0 && result.b <= 1.0) "b should be in range"

testSuite "HSL Blend Modes"

test "hue blend transfers hue only" := do
  let base := Color.red
  let top := Color.blue
  let result := Color.blend .hue base top
  let resultHsl := HSL.fromColor result
  let blueHsl := HSL.fromColor Color.blue
  ensure (floatNear resultHsl.h blueHsl.h 0.01) "result should have blue's hue"

test "saturation blend transfers saturation only" := do
  let base := Color.red
  let desaturated := Color.gray 0.5
  let result := Color.blend .saturation base desaturated
  let resultHsl := HSL.fromColor result
  ensure (floatNear resultHsl.s 0.0 0.01) "result should have zero saturation"

test "luminosity blend transfers lightness only" := do
  let base := Color.red
  let dark := Color.rgb 0.1 0.1 0.1
  let result := Color.blend .luminosity base dark
  let resultHsl := HSL.fromColor result
  ensure (resultHsl.l < 0.3) "result should be dark"



end TinctureTests.BlendTests
