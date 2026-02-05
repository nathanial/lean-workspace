/-
  Tests for Quantity operations.
-/

import Measures
import Crucible

namespace MeasuresTests.QuantityTests

open Crucible
open Measures
open Measures.Units.SI
open Measures.Units.Imperial

testSuite "Quantity Construction"

test "create quantity with unit" := do
  let q := 5.0 *: meter
  q.value ≡ 5.0

test "zero quantity" := do
  let z : Quantity Dimension.Length := Quantity.zero
  z.value ≡ 0.0

test "pure creates dimensionless" := do
  let q := Quantity.pure 3.14
  q.value ≡ 3.14

testSuite "Quantity Predicates"

test "isZero" := do
  let z : Quantity Dimension.Length := Quantity.zero
  ensure (z.isZero) "zero should be zero"
  let nonzero := 1.0 *: meter
  ensure (!nonzero.isZero) "1m should not be zero"

test "isPositive and isNegative" := do
  let pos := 5.0 *: meter
  let neg := (-5.0) *: meter
  let zero : Quantity Dimension.Length := Quantity.zero
  ensure (pos.isPositive) "positive should be positive"
  ensure (!pos.isNegative) "positive should not be negative"
  ensure (neg.isNegative) "negative should be negative"
  ensure (!neg.isPositive) "negative should not be positive"
  ensure (!zero.isPositive) "zero should not be positive"
  ensure (!zero.isNegative) "zero should not be negative"

testSuite "Quantity Basic Operations"

test "negation" := do
  let q := 5.0 *: meter
  let neg := q.neg
  neg.value ≡ (-5.0)

test "absolute value" := do
  let neg := (-5.0) *: meter
  let absVal := neg.abs
  absVal.value ≡ 5.0

test "scalar multiplication" := do
  let q := 5.0 *: meter
  let doubled := q.smul 2.0
  doubled.value ≡ 10.0

test "scalar division" := do
  let q := 10.0 *: meter
  let halved := q.sdiv 2.0
  halved.value ≡ 5.0

testSuite "Quantity Display"

test "toString" := do
  let q := 42.0 *: meter
  ensure (q.toString.length > 0) "toString should produce output"

testSuite "Pretty Printing"

test "format with symbol" := do
  let distance := 100.0 *: meter
  let formatted := distance.format meter
  -- Trailing zeros are trimmed: "100.0" -> "100"
  ensure (formatted == "100 m") s!"Expected '100 m', got '{formatted}'"

test "format with precision" := do
  let distance := 123.456789 *: meter
  let formatted := distance.format meter 2
  ensure (formatted == "123.46 m") s!"Expected '123.46 m', got '{formatted}'"

test "format velocity" := do
  let speed := 25.0 *: meterPerSecond
  let formatted := speed.format meterPerSecond
  ensure (formatted == "25 m/s") s!"Expected '25 m/s', got '{formatted}'"

test "format with unit conversion" := do
  let distance := 1000.0 *: meter
  let formatted := distance.format kilometer
  ensure (formatted == "1 km") s!"Expected '1 km', got '{formatted}'"

test "formatLong shows full name" := do
  let distance := 5.0 *: meter
  let formatted := distance.formatLong meter
  ensure (formatted == "5 meter") s!"Expected '5 meter', got '{formatted}'"

test "format compound unit" := do
  let velocity := meter / second
  let speed := 10.0 *: velocity
  let formatted := speed.format velocity
  ensure (formatted == "10 m/s") s!"Expected '10 m/s', got '{formatted}'"

test "format with different unit" := do
  let distance := 1.0 *: mile
  let formatted := distance.format kilometer 2
  -- 1 mile ≈ 1.609 km
  ensure (formatted == "1.61 km") s!"Expected '1.61 km', got '{formatted}'"

test "format preserves non-zero decimals" := do
  let distance := 3.5 *: meter
  let formatted := distance.format meter
  ensure (formatted == "3.5 m") s!"Expected '3.5 m', got '{formatted}'"

testSuite "Quantity DecidableEq"

test "equal quantities are decidably equal" := do
  let q1 := 5.0 *: meter
  let q2 := 5.0 *: meter
  ensure (q1 = q2) "Equal quantities should be propositionally equal"

test "different quantities are decidably not equal" := do
  let q1 := 5.0 *: meter
  let q2 := 10.0 *: meter
  ensure (q1 ≠ q2) "Different quantities should not be equal"

test "can use in if expression with propositional equality" := do
  let q1 := 100.0 *: meter
  let q2 := 100.0 *: meter
  let result := if q1 = q2 then "same" else "different"
  ensure (result == "same") "Should be able to use = in if"

testSuite "Quantity Hashable"

test "equal quantities have equal hashes" := do
  let q1 := 5.0 *: meter
  let q2 := 5.0 *: meter
  ensure (hash q1 == hash q2) "Equal quantities should have equal hashes"

test "hash is consistent" := do
  let q := 42.0 *: meter
  -- Calling hash multiple times should give same result
  ensure (hash q == hash q) "Hash should be consistent"



end MeasuresTests.QuantityTests
