/-
  Tests for color harmony generation.
-/

import Tincture
import Crucible

namespace TinctureTests.HarmonyTests

open Crucible
open Tincture

testSuite "Hue Rotation"

test "rotating by 0 returns same hue" := do
  let c := Color.red
  let rotated := Color.rotateHue c 0.0
  let origHsl := HSL.fromColor c
  let newHsl := HSL.fromColor rotated
  ensure (floatNear origHsl.h newHsl.h 0.02) "hue should be unchanged"

test "rotating by 0.5 gives complementary" := do
  let c := Color.red
  let rotated := Color.rotateHue c 0.5
  let origHsl := HSL.fromColor c
  let newHsl := HSL.fromColor rotated
  let diff := Float.abs (newHsl.h - origHsl.h)
  ensure (floatNear diff 0.5 0.02) "hue diff should be 0.5"

test "rotating by 1 wraps around" := do
  let c := Color.red
  let rotated := Color.rotateHue c 1.0
  let origHsl := HSL.fromColor c
  let newHsl := HSL.fromColor rotated
  ensure (floatNear origHsl.h newHsl.h 0.02) "hue should wrap around"

testSuite "Complementary Colors"

test "red's complement is cyan-ish" := do
  let comp := Color.complementary Color.red
  let compHsl := HSL.fromColor comp
  ensure (floatNear compHsl.h 0.5 0.02) "complement should be ~0.5"

test "complementary of complementary is original" := do
  let c := Color.rgb 0.5 0.3 0.7
  let double := Color.complementary (Color.complementary c)
  let origHsl := HSL.fromColor c
  let doubleHsl := HSL.fromColor double
  ensure (floatNear origHsl.h doubleHsl.h 0.02) "double complement should match original"

testSuite "Split Complementary"

test "split complementary returns two colors" := do
  let (left, right) := Color.splitComplementary Color.red
  let leftHsl := HSL.fromColor left
  let rightHsl := HSL.fromColor right
  ensure (leftHsl.h > 0.4 && leftHsl.h < 0.6) "left should be near 0.5"
  ensure (rightHsl.h > 0.4 && rightHsl.h < 0.6) "right should be near 0.5"

test "split colors are symmetric around complement" := do
  let (left, right) := Color.splitComplementary Color.red
  let leftHsl := HSL.fromColor left
  let rightHsl := HSL.fromColor right
  let leftDist := Float.abs (leftHsl.h - 0.5)
  let rightDist := Float.abs (rightHsl.h - 0.5)
  ensure (floatNear leftDist rightDist 0.02) "distances should be equal"

testSuite "Triadic Colors"

test "triadic returns two additional colors" := do
  let (c1, c2) := Color.triadic Color.red
  let h1 := (HSL.fromColor c1).h
  let h2 := (HSL.fromColor c2).h
  ensure (h1 > 0.2 && h1 < 0.5) "h1 should be ~1/3"
  ensure (h2 > 0.5 && h2 < 0.8) "h2 should be ~2/3"

test "triadic colors are equally spaced" := do
  let (c1, c2) := Color.triadic Color.red
  let h1 := (HSL.fromColor c1).h
  let h2 := (HSL.fromColor c2).h
  ensure (floatNear h1 (1.0/3.0) 0.02) "h1 should be 1/3"
  ensure (floatNear h2 (2.0/3.0) 0.02) "h2 should be 2/3"

testSuite "Square Colors"

test "square returns three additional colors" := do
  let sq := Color.square Color.red
  sq.size ≡ 3

test "square colors are 90 degrees apart" := do
  let sq := Color.square Color.red
  let h1 := (HSL.fromColor sq[0]!).h
  let h2 := (HSL.fromColor sq[1]!).h
  let h3 := (HSL.fromColor sq[2]!).h
  ensure (floatNear h1 0.25 0.02) "h1 should be 0.25"
  ensure (floatNear h2 0.5 0.02) "h2 should be 0.5"
  ensure (floatNear h3 0.75 0.02) "h3 should be 0.75"

testSuite "Analogous Colors"

test "analogous returns two neighbors" := do
  let (left, right) := Color.analogous Color.red
  let leftHsl := HSL.fromColor left
  let rightHsl := HSL.fromColor right
  ensure (leftHsl.h > 0.9 || leftHsl.h < 0.1) "left should be near 0"
  ensure (rightHsl.h < 0.1) "right should be near 0"

testSuite "Monochromatic Palette"

test "monochromatic returns requested count" := do
  let palette := Color.monochromatic Color.red 5
  palette.size ≡ 5

test "monochromatic with 0 returns empty" := do
  let palette := Color.monochromatic Color.red 0
  palette.size ≡ 0

test "monochromatic with 1 returns original" := do
  let palette := Color.monochromatic Color.red 1
  palette.size ≡ 1

test "monochromatic preserves hue" := do
  let palette := Color.monochromatic Color.red 5
  let redHue := (HSL.fromColor Color.red).h
  for c in palette do
    ensure (floatNear (HSL.fromColor c).h redHue 0.02) "hue should be preserved"

test "monochromatic varies lightness" := do
  let palette := Color.monochromatic Color.red 5
  let firstL := (HSL.fromColor palette[0]!).l
  let lastL := (HSL.fromColor palette[4]!).l
  ensure (firstL < lastL) "lightness should increase"

testSuite "Shades, Tints, and Tones"

test "shades returns requested count" := do
  let shades := Color.shades Color.red 5
  shades.size ≡ 5

test "shades get progressively darker" := do
  let shades := Color.shades Color.red 3
  let l0 := Color.relativeLuminance shades[0]!
  let l1 := Color.relativeLuminance shades[1]!
  let l2 := Color.relativeLuminance shades[2]!
  ensure (l0 >= l1) "l0 >= l1"
  ensure (l1 >= l2) "l1 >= l2"

test "tints returns requested count" := do
  let tints := Color.tints Color.red 5
  tints.size ≡ 5

test "tints get progressively lighter" := do
  let tints := Color.tints Color.red 3
  let l0 := Color.relativeLuminance tints[0]!
  let l1 := Color.relativeLuminance tints[1]!
  let l2 := Color.relativeLuminance tints[2]!
  ensure (l0 <= l1) "l0 <= l1"
  ensure (l1 <= l2) "l1 <= l2"

test "tones returns requested count" := do
  let tones := Color.tones Color.red 5
  tones.size ≡ 5

test "tones get progressively less saturated" := do
  let tones := Color.tones Color.red 3
  let s0 := (HSL.fromColor tones[0]!).s
  let s1 := (HSL.fromColor tones[1]!).s
  let s2 := (HSL.fromColor tones[2]!).s
  ensure (s0 >= s1) "s0 >= s1"
  ensure (s1 >= s2) "s1 >= s2"

testSuite "Harmony Function"

test "harmony complementary returns 2 colors" := do
  let colors := Color.harmony Color.red .complementary
  colors.size ≡ 2

test "harmony splitComplementary returns 3 colors" := do
  let colors := Color.harmony Color.red .splitComplementary
  colors.size ≡ 3

test "harmony triadic returns 3 colors" := do
  let colors := Color.harmony Color.red .triadic
  colors.size ≡ 3

test "harmony tetradic returns 4 colors" := do
  let colors := Color.harmony Color.red .tetradic
  colors.size ≡ 4

test "harmony square returns 4 colors" := do
  let colors := Color.harmony Color.red .square
  colors.size ≡ 4

test "harmony analogous returns 3 colors" := do
  let colors := Color.harmony Color.red .analogous
  colors.size ≡ 3

test "harmony monochromatic returns 5 colors" := do
  let colors := Color.harmony Color.red .monochromatic
  colors.size ≡ 5

testSuite "OkLCH Harmony"

test "harmonyOk produces valid colors" := do
  let colors := Color.harmonyOk Color.red .triadic
  for c in colors do
    ensure (c.r >= 0.0 && c.r <= 1.0) "r should be valid"
    ensure (c.g >= 0.0 && c.g <= 1.0) "g should be valid"
    ensure (c.b >= 0.0 && c.b <= 1.0) "b should be valid"

test "harmonyOk returns same count as harmony" := do
  let types := #[HarmonyType.complementary, .splitComplementary, .triadic, .tetradic, .square, .analogous, .monochromatic]
  for t in types do
    let h1 := Color.harmony Color.red t
    let h2 := Color.harmonyOk Color.red t
    h1.size ≡ h2.size



end TinctureTests.HarmonyTests
