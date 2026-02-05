/-
  Tests for arithmetic operations on quantities.
-/

import Measures
import Crucible
import MeasuresTests.TestUtils

namespace MeasuresTests.ArithmeticTests

open Crucible
open Measures
open Measures.Quantity
open Measures.Units.SI
open MeasuresTests.TestUtils

testSuite "Addition and Subtraction"

test "add same dimension" := do
  let a := 5.0 *: meter
  let b := 3.0 *: meter
  let c := a + b
  c.asUnit meter ≡ 8.0

test "subtract same dimension" := do
  let a := 10.0 *: meter
  let b := 3.0 *: meter
  let c := a - b
  c.asUnit meter ≡ 7.0

test "negation" := do
  let a := 5.0 *: meter
  let b := -a
  b.asUnit meter ≡ (-5.0)

testSuite "Multiplication and Division"

test "multiply produces new dimension" := do
  let d := 100.0 *: meter
  let t := 10.0 *: second
  let v := d /. t
  -- velocity = 10 m/s
  v.value ≡ 10.0

test "force = mass * acceleration" := do
  let m := 10.0 *: kilogram
  let a := 9.8 *: meterPerSecondSquared
  let f := m *. a
  ensure (approxEq (f.asUnit newton) 98.0 0.01) "Expected 98 N"

test "energy = force * distance" := do
  let f := 100.0 *: newton
  let d := 10.0 *: meter
  let e := f *. d
  e.asUnit joule ≡ 1000.0

test "power = energy / time" := do
  let e := 1000.0 *: joule
  let t := 10.0 *: second
  let p := e /. t
  p.asUnit watt ≡ 100.0

testSuite "Scalar Operations"

test "scalar multiplication with smul" := do
  let q := 5.0 *: meter
  let doubled := Quantity.smul 2.0 q
  doubled.asUnit meter ≡ 10.0

test "quantity times scalar" := do
  let q := 5.0 *: meter
  let doubled := q * 2.0
  doubled.asUnit meter ≡ 10.0

test "quantity divided by scalar" := do
  let q := 10.0 *: meter
  let halved := q / 2.0
  halved.asUnit meter ≡ 5.0

test "scalar times quantity" := do
  let q := 5.0 *: meter
  let doubled := 2.0 * q
  doubled.asUnit meter ≡ 10.0

test "scalar times quantity is commutative" := do
  let q := 7.0 *: meter
  let a := 3.0 * q
  let b := q * 3.0
  ensure (TestUtils.approxEq a.value b.value) "3.0 * q should equal q * 3.0"

test "scalar times quantity with velocity" := do
  let v := 10.0 *: meterPerSecond
  let scaled := 0.5 * v
  ensure (approxEq (scaled.asUnit meterPerSecond) 5.0) "Scaling velocity should work"

testSuite "Powers"

test "square" := do
  let side := 5.0 *: meter
  let area := side.sq
  area.asUnit squareMeter ≡ 25.0

test "cube" := do
  let side := 2.0 *: meter
  let volume := side.cube
  volume.asUnit cubicMeter ≡ 8.0

test "reciprocal" := do
  let t := 2.0 *: second
  let freq := t.recip
  freq.asUnit hertz ≡ 0.5

testSuite "Square Root"

test "sqrt of area gives length" := do
  let area := 25.0 *: squareMeter
  let side := area.sqrt
  side.asUnit meter ≡ 5.0

testSuite "Utility Functions"

test "sum of quantities" := do
  let qs := [1.0 *: meter, 2.0 *: meter, 3.0 *: meter]
  let total := Quantity.sum qs
  total.asUnit meter ≡ 6.0

test "average of quantities" := do
  let qs := [2.0 *: meter, 4.0 *: meter, 6.0 *: meter]
  let average := Quantity.avg qs
  average.asUnit meter ≡ 4.0

test "min of two quantities" := do
  let a := 5.0 *: meter
  let b := 3.0 *: meter
  let minimum := Quantity.min a b
  minimum.asUnit meter ≡ 3.0

test "max of two quantities" := do
  let a := 5.0 *: meter
  let b := 3.0 *: meter
  let maximum := Quantity.max a b
  maximum.asUnit meter ≡ 5.0



end MeasuresTests.ArithmeticTests
