/-
  Tests for core Color operations.
-/

import Tincture
import Crucible

namespace TinctureTests.ColorTests

open Crucible
open Tincture

/-- Helper to check if two colors are approximately equal. -/
def colorApproxEq (c1 c2 : Color) (epsilon : Float := 0.001) : Bool :=
  floatNear c1.r c2.r epsilon &&
  floatNear c1.g c2.g epsilon &&
  floatNear c1.b c2.b epsilon &&
  floatNear c1.a c2.a epsilon

testSuite "Color Core"

test "clamp01 clamps values below 0" :=
  Color.clamp01 (-0.5) ≡ 0.0

test "clamp01 clamps values above 1" :=
  Color.clamp01 1.5 ≡ 1.0

test "clamp01 preserves values in range" :=
  Color.clamp01 0.5 ≡ 0.5

test "rgba constructor preserves values" := do
  let c := Color.rgba 0.2 0.4 0.6 0.8
  c.r ≡ 0.2
  c.g ≡ 0.4
  c.b ≡ 0.6
  c.a ≡ 0.8

test "rgb constructor sets alpha to 1" := do
  let c := Color.rgb 0.5 0.5 0.5
  c.a ≡ 1.0

test "fromRgb8 converts correctly" := do
  let c := Color.fromRgb8 255 128 0
  ensure (floatNear c.r 1.0 0.001) "r should be 1.0"
  ensure (floatNear c.g 0.502 0.001) "g should be ~0.502"
  ensure (floatNear c.b 0.0 0.001) "b should be 0.0"

test "toRgb8 converts correctly" := do
  let c := Color.rgb 1.0 0.5 0.0
  let (r, g, b, a) := c.toRgb8
  r ≡ 255
  ensure (g >= 127 && g <= 128) "g should be ~128"
  b ≡ 0
  a ≡ 255

test "fromRgb8 and toRgb8 roundtrip" := do
  let c := Color.fromRgb8 100 150 200
  let (r, g, b, _) := c.toRgb8
  r ≡ 100
  g ≡ 150
  b ≡ 200

test "white is (1, 1, 1, 1)" := do
  Color.white.r ≡ 1.0
  Color.white.g ≡ 1.0
  Color.white.b ≡ 1.0
  Color.white.a ≡ 1.0

test "black is (0, 0, 0, 1)" := do
  Color.black.r ≡ 0.0
  Color.black.g ≡ 0.0
  Color.black.b ≡ 0.0
  Color.black.a ≡ 1.0

test "red is (1, 0, 0, 1)" := do
  Color.red.r ≡ 1.0
  Color.red.g ≡ 0.0
  Color.red.b ≡ 0.0

test "green is (0, 1, 0, 1)" := do
  Color.green.r ≡ 0.0
  Color.green.g ≡ 1.0
  Color.green.b ≡ 0.0

test "blue is (0, 0, 1, 1)" := do
  Color.blue.r ≡ 0.0
  Color.blue.g ≡ 0.0
  Color.blue.b ≡ 1.0

test "transparent has alpha 0" :=
  Color.transparent.a ≡ 0.0

test "withAlpha changes only alpha" := do
  let c := Color.red.withAlpha 0.5
  c.r ≡ 1.0
  c.g ≡ 0.0
  c.b ≡ 0.0
  c.a ≡ 0.5

test "lerp at t=0 returns first color" := do
  let c := Color.lerp Color.red Color.blue 0.0
  ensure (colorApproxEq c Color.red) "should equal red"

test "lerp at t=1 returns second color" := do
  let c := Color.lerp Color.red Color.blue 1.0
  ensure (colorApproxEq c Color.blue) "should equal blue"

test "lerp at t=0.5 returns midpoint" := do
  let c := Color.lerp Color.black Color.white 0.5
  ensure (floatNear c.r 0.5 0.001) "r should be 0.5"
  ensure (floatNear c.g 0.5 0.001) "g should be 0.5"
  ensure (floatNear c.b 0.5 0.001) "b should be 0.5"

test "premultiply multiplies RGB by alpha" := do
  let c := (Color.rgb 1.0 0.5 0.25).withAlpha 0.5
  let pm := c.premultiply
  ensure (floatNear pm.r 0.5 0.001) "r should be 0.5"
  ensure (floatNear pm.g 0.25 0.001) "g should be 0.25"
  ensure (floatNear pm.b 0.125 0.001) "b should be 0.125"

test "unpremultiply reverses premultiply" := do
  let c := (Color.rgb 0.8 0.4 0.2).withAlpha 0.5
  let roundtrip := c.premultiply.unpremultiply
  ensure (colorApproxEq roundtrip c) "roundtrip should preserve color"

test "gray creates correct gray" := do
  let g := Color.gray 0.5
  g.r ≡ 0.5
  g.g ≡ 0.5
  g.b ≡ 0.5
  g.a ≡ 1.0



end TinctureTests.ColorTests
