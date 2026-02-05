/-
  Tests for unit conversions.
-/

import Measures
import Crucible
import MeasuresTests.TestUtils

namespace MeasuresTests.ConversionTests

open Crucible
open Measures
open Measures.Units.SI
open Measures.Units.Imperial
open Measures.Units.Temperature
open Measures.Units.Angle
open MeasuresTests.TestUtils

testSuite "SI Prefix Conversions"

test "kilometer to meter" := do
  let km := 1.0 *: kilometer
  let m := km.asUnit meter
  ensure (approxEq m 1000.0) s!"Expected 1000, got {m}"

test "millimeter to meter" := do
  let mm := 1000.0 *: millimeter
  let m := mm.asUnit meter
  ensure (approxEq m 1.0) s!"Expected 1, got {m}"

test "kilogram to gram" := do
  let kg := 1.0 *: kilogram
  let g := kg.asUnit gram
  ensure (approxEq g 1000.0) s!"Expected 1000, got {g}"

test "millisecond to second" := do
  let ms := 1000.0 *: millisecond
  let s := ms.asUnit second
  ensure (approxEq s 1.0) s!"Expected 1, got {s}"

testSuite "Imperial Length Conversions"

test "foot to meter" := do
  let ft := 1.0 *: foot
  let m := ft.asUnit meter
  ensure (approxEq m 0.3048) s!"Expected 0.3048, got {m}"

test "meter to foot" := do
  let m := 1.0 *: meter
  let ft := m.asUnit foot
  ensure (approxEq ft 3.28084 0.0001) s!"Expected ~3.28084, got {ft}"

test "inch to centimeter" := do
  let in_ := 1.0 *: inch
  let cm := in_.asUnit centimeter
  ensure (approxEq cm 2.54) s!"Expected 2.54, got {cm}"

test "mile to kilometer" := do
  let mi := 1.0 *: mile
  let km := mi.asUnit kilometer
  ensure (approxEq km 1.609344 0.0001) s!"Expected ~1.609, got {km}"

testSuite "Imperial Mass Conversions"

test "pound to kilogram" := do
  let lb := 1.0 *: pound
  let kg := lb.asUnit kilogram
  ensure (approxEq kg 0.45359237 0.0001) s!"Expected ~0.454, got {kg}"

test "ounce to gram" := do
  let oz := 1.0 *: ounce
  let g := oz.asUnit gram
  ensure (approxEq g 28.349523 0.001) s!"Expected ~28.35, got {g}"

testSuite "Temperature Conversions"

test "celsius to kelvin - freezing point" := do
  let c := 0.0 *: celsius
  let k := c.asUnit Units.Temperature.kelvin
  ensure (approxEq k 273.15 0.01) s!"Expected 273.15, got {k}"

test "celsius to kelvin - boiling point" := do
  let c := 100.0 *: celsius
  let k := c.asUnit Units.Temperature.kelvin
  ensure (approxEq k 373.15 0.01) s!"Expected 373.15, got {k}"

test "fahrenheit to celsius - freezing point" := do
  let f := 32.0 *: fahrenheit
  let c := f.asUnit celsius
  ensure (approxEq c 0.0 0.1) s!"Expected 0, got {c}"

test "fahrenheit to celsius - boiling point" := do
  let f := 212.0 *: fahrenheit
  let c := f.asUnit celsius
  ensure (approxEq c 100.0 0.1) s!"Expected 100, got {c}"

test "celsius to fahrenheit - room temperature" := do
  let c := 20.0 *: celsius
  let f := c.asUnit fahrenheit
  ensure (approxEq f 68.0 0.1) s!"Expected 68, got {f}"

testSuite "Angle Conversions"

test "degree to radian" := do
  let deg := 180.0 *: degree
  let rad := deg.asUnit radian
  ensure (approxEq rad π 0.0001) s!"Expected π, got {rad}"

test "radian to degree" := do
  let rad := π *: radian
  let deg := rad.asUnit degree
  ensure (approxEq deg 180.0 0.0001) s!"Expected 180, got {deg}"

test "full turn" := do
  let t := 1.0 *: turn
  let deg := t.asUnit degree
  ensure (approxEq deg 360.0 0.0001) s!"Expected 360, got {deg}"

testSuite "Round-trip Conversions"

test "meter -> foot -> meter" := do
  let original := 42.0
  let m1 := original *: meter
  let ft := m1.asUnit foot
  let m2 := (ft *: foot).asUnit meter
  ensure (approxEq m2 original 0.0001) s!"Expected {original}, got {m2}"

test "kilogram -> pound -> kilogram" := do
  let original := 100.0
  let kg1 := original *: kilogram
  let lb := kg1.asUnit pound
  let kg2 := (lb *: pound).asUnit kilogram
  ensure (approxEq kg2 original 0.0001) s!"Expected {original}, got {kg2}"

testSuite "Direct Unit Conversion"

test "convert meter to foot" := do
  let result := Unit.convert 1.0 meter foot
  ensure (approxEq result 3.28084 0.0001) s!"Expected ~3.28084, got {result}"

test "convert kilometer to mile" := do
  let result := Unit.convert 1.609344 kilometer mile
  ensure (approxEq result 1.0 0.0001) s!"Expected 1.0, got {result}"

test "convert celsius to fahrenheit - freezing" := do
  let result := Unit.convert 0.0 celsius fahrenheit
  ensure (approxEq result 32.0 0.1) s!"Expected 32.0, got {result}"

test "convert celsius to fahrenheit - boiling" := do
  let result := Unit.convert 100.0 celsius fahrenheit
  ensure (approxEq result 212.0 0.1) s!"Expected 212.0, got {result}"

test "convert fahrenheit to celsius" := do
  let result := Unit.convert 68.0 fahrenheit celsius
  ensure (approxEq result 20.0 0.1) s!"Expected 20.0, got {result}"

test "convert degree to radian" := do
  let result := Unit.convert 180.0 degree radian
  ensure (approxEq result π 0.0001) s!"Expected π, got {result}"

test "convert is equivalent to quantity conversion" := do
  let direct := Unit.convert 42.0 meter foot
  let via_quantity := (42.0 *: meter).asUnit foot
  ensure (approxEq direct via_quantity) "Direct and quantity conversion should match"



end MeasuresTests.ConversionTests
