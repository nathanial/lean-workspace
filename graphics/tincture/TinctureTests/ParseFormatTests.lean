/-
  Tests for color parsing and formatting.
-/

import Tincture
import Crucible
import Staple

namespace TinctureTests.ParseFormatTests

open Crucible
open Tincture
open Staple (String.containsSubstr)

/-- Helper to check if two colors are approximately equal. -/
def colorApproxEq (c1 c2 : Color) (epsilon : Float := 0.01) : Bool :=
  floatNear c1.r c2.r epsilon &&
  floatNear c1.g c2.g epsilon &&
  floatNear c1.b c2.b epsilon

testSuite "Hex Parsing"

test "parse #RRGGBB format" := do
  match Color.fromHex "#ff8000" with
  | some c =>
    ensure (floatNear c.r 1.0 0.01) "r should be 1.0"
    ensure (floatNear c.g 0.502 0.01) "g should be ~0.502"
    ensure (floatNear c.b 0.0 0.01) "b should be 0.0"
  | none => ensure false "parsing failed"

test "parse RRGGBB without #" := do
  match Color.fromHex "ff8000" with
  | some c => ensure (floatNear c.r 1.0 0.01) "r should be 1.0"
  | none => ensure false "parsing failed"

test "parse #RGB short format" := do
  match Color.fromHex "#f80" with
  | some c =>
    ensure (floatNear c.r 1.0 0.01) "r should be 1.0"
    ensure (floatNear c.g 0.533 0.01) "g should be ~0.533"
    ensure (floatNear c.b 0.0 0.01) "b should be 0.0"
  | none => ensure false "parsing failed"

test "parse #RRGGBBAA format" := do
  match Color.fromHex "#ff800080" with
  | some c =>
    ensure (floatNear c.r 1.0 0.01) "r should be 1.0"
    ensure (floatNear c.a 0.502 0.01) "a should be ~0.502"
  | none => ensure false "parsing failed"

test "parse uppercase hex" := do
  match Color.fromHex "#FF8000" with
  | some c => ensure (floatNear c.r 1.0 0.01) "r should be 1.0"
  | none => ensure false "parsing failed"

test "parse black" := do
  match Color.fromHex "#000000" with
  | some c => ensure (colorApproxEq c Color.black) "should be black"
  | none => ensure false "parsing failed"

test "parse white" := do
  match Color.fromHex "#ffffff" with
  | some c => ensure (colorApproxEq c Color.white) "should be white"
  | none => ensure false "parsing failed"

test "invalid hex returns none" :=
  Color.fromHex "#xyz" ≡ none

test "wrong length returns none" :=
  Color.fromHex "#12345" ≡ none

testSuite "RGB String Parsing"

test "parse rgb(255, 128, 0)" := do
  match Color.fromRgbString "rgb(255, 128, 0)" with
  | some c =>
    ensure (floatNear c.r 1.0 0.01) "r should be 1.0"
    ensure (floatNear c.g 0.502 0.01) "g should be ~0.502"
    ensure (floatNear c.b 0.0 0.01) "b should be 0.0"
  | none => ensure false "parsing failed"

test "parse rgb with spaces" := do
  match Color.fromRgbString "rgb( 255 , 128 , 0 )" with
  | some c => ensure (floatNear c.r 1.0 0.01) "r should be 1.0"
  | none => ensure false "parsing failed"

test "parse rgb with percentages" := do
  match Color.fromRgbString "rgb(100%, 50%, 0%)" with
  | some c =>
    ensure (floatNear c.r 1.0 0.01) "r should be 1.0"
    ensure (floatNear c.g 0.5 0.01) "g should be 0.5"
    ensure (floatNear c.b 0.0 0.01) "b should be 0.0"
  | none => ensure false "parsing failed"

test "parse rgba format" := do
  match Color.fromRgbaString "rgba(255, 128, 0, 0.5)" with
  | some c =>
    ensure (floatNear c.r 1.0 0.01) "r should be 1.0"
    ensure (floatNear c.a 0.5 0.01) "a should be 0.5"
  | none => ensure false "parsing failed"

test "invalid rgb returns none" :=
  Color.fromRgbString "notacolor" ≡ none

testSuite "Universal Parse"

test "parse auto-detects hex" := do
  match Color.parse "#ff0000" with
  | some c => ensure (colorApproxEq c Color.red) "should be red"
  | none => ensure false "parsing failed"

test "parse auto-detects rgb" := do
  match Color.parse "rgb(0, 255, 0)" with
  | some c => ensure (colorApproxEq c Color.green) "should be green"
  | none => ensure false "parsing failed"

test "parse auto-detects rgba" := do
  match Color.parse "rgba(0, 0, 255, 0.5)" with
  | some c =>
    ensure (floatNear c.b 1.0 0.01) "b should be 1.0"
    ensure (floatNear c.a 0.5 0.01) "a should be 0.5"
  | none => ensure false "parsing failed"

testSuite "Hex Formatting"

test "toHex formats correctly" := do
  let hex := Color.toHex Color.red
  hex ≡ "#ff0000"

test "toHex with white" := do
  let hex := Color.toHex Color.white
  hex ≡ "#ffffff"

test "toHex with black" := do
  let hex := Color.toHex Color.black
  hex ≡ "#000000"

test "toHex with includeAlpha" := do
  let c := Color.red.withAlpha 0.5
  let hex := Color.toHex c true
  ensure (hex.length == 9) "hex with alpha should be 9 chars"

test "toHexShort shortens #ff0000" := do
  let short := Color.toHexShort Color.red
  short ≡ "#f00"

test "toHexShort shortens #ffffff" := do
  let short := Color.toHexShort Color.white
  short ≡ "#fff"

testSuite "RGB/HSL String Formatting"

test "toRgbString formats correctly" := do
  let s := Color.toRgbString Color.red
  s ≡ "rgb(255, 0, 0)"

test "toRgbaString formats correctly" := do
  let c := Color.red.withAlpha 0.5
  let s := Color.toRgbaString c
  ensure (s.startsWith "rgba(255, 0, 0") "should start with rgba(255, 0, 0"

test "toHslString formats correctly" := do
  let s := Color.toHslString Color.red
  ensure (s.startsWith "hsl(") "should start with hsl("
  ensure (String.containsSubstr s "100%") "should contain 100%"

test "toHslaString includes alpha" := do
  let c := Color.red.withAlpha 0.5
  let s := Color.toHslaString c
  ensure (s.startsWith "hsla(") "should start with hsla("

testSuite "CSS Formatting"

test "toCssString uses rgb for opaque" := do
  let s := Color.toCssString Color.red
  ensure (s.startsWith "rgb(") "should start with rgb("

test "toCssString uses rgba for transparent" := do
  let c := Color.red.withAlpha 0.5
  let s := Color.toCssString c
  ensure (s.startsWith "rgba(") "should start with rgba("

test "toCssModern uses space-separated" := do
  let s := Color.toCssModern Color.red
  s ≡ "rgb(255 0 0)"

test "toCssModern with alpha uses /" := do
  let c := Color.red.withAlpha 0.5
  let s := Color.toCssModern c
  ensure (String.containsSubstr s "/") "should contain /"

testSuite "Debug String"

test "toDebugString includes Color prefix" := do
  let s := Color.toDebugString Color.red
  ensure (s.startsWith "Color(") "should start with Color("

test "toDebugString includes all components" := do
  let s := Color.toDebugString (Color.rgba 0.1 0.2 0.3 0.4)
  ensure (String.containsSubstr s "r=") "should contain r="
  ensure (String.containsSubstr s "g=") "should contain g="
  ensure (String.containsSubstr s "b=") "should contain b="
  ensure (String.containsSubstr s "a=") "should contain a="

testSuite "ToString Instance"

test "toString returns hex" := do
  let s := toString Color.red
  s ≡ "#ff0000"

testSuite "Roundtrip"

test "hex roundtrip preserves color" := do
  let original := Color.rgb 0.8 0.4 0.2
  let hex := Color.toHex original
  match Color.fromHex hex with
  | some parsed => ensure (colorApproxEq parsed original 0.01) "roundtrip should preserve"
  | none => ensure false "parsing failed"

test "multiple format roundtrips" := do
  let colors := #[Color.red, Color.green, Color.blue, Color.white, Color.black]
  for c in colors do
    match Color.fromHex (Color.toHex c) with
    | some parsed => ensure (colorApproxEq parsed c 0.01) "roundtrip should preserve"
    | none => ensure false "parsing failed"



end TinctureTests.ParseFormatTests
