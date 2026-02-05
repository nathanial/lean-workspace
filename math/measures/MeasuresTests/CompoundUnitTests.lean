/-
  Tests for compound unit construction.
-/

import Measures
import Crucible
import MeasuresTests.TestUtils

namespace MeasuresTests.CompoundUnitTests

open Crucible
open Measures
open Measures.Units.SI
open MeasuresTests.TestUtils

-- Use Time.hour explicitly to avoid ambiguity with SI units
private def hour := Measures.Units.Time.hour

testSuite "Compound Unit Construction"

test "meter / second creates velocity unit" := do
  let velocity := meter / second
  let speed := 10.0 *: velocity
  -- 10 m/s should equal 10 m/s when expressed in our compound unit
  ensure (approxEq (speed.asUnit velocity) 10.0) "Expected 10.0"

test "velocity unit matches predefined meterPerSecond" := do
  let velocity := meter / second
  let speed1 := 25.0 *: velocity
  let speed2 := 25.0 *: meterPerSecond
  ensure (approxEq speed1.value speed2.value) "Values should match"

test "newton * meter creates energy unit" := do
  let work := newton * meter
  let energy := 100.0 *: work
  -- Should be equivalent to 100 joules
  ensure (approxEq (energy.asUnit joule) 100.0) "Expected 100 J"

test "watt * second creates energy unit" := do
  let energyUnit := watt * second
  let energy := 3600.0 *: energyUnit
  -- 3600 W·s = 3600 J = 1 kWh
  ensure (approxEq (energy.asUnit joule) 3600.0) "Expected 3600 J"

test "kilogram * meter / second² creates force unit" := do
  let forceUnit := kilogram * meter / (second * second)
  let force := 9.8 *: forceUnit
  ensure (approxEq (force.asUnit newton) 9.8 0.001) "Expected 9.8 N"

testSuite "Unit Squaring and Cubing"

test "meter.sq creates area unit" := do
  let area := 25.0 *: meter.sq
  ensure (approxEq (area.asUnit squareMeter) 25.0) "Expected 25 m²"

test "meter.cube creates volume unit" := do
  let volume := 8.0 *: meter.cube
  ensure (approxEq (volume.asUnit cubicMeter) 8.0) "Expected 8 m³"

test "second.recip creates frequency unit" := do
  let freq := 60.0 *: second.recip
  ensure (approxEq (freq.asUnit hertz) 60.0) "Expected 60 Hz"

testSuite "Compound Unit with Prefixes"

test "kilometer / hour creates velocity unit" := do
  let kph := kilometer / hour
  let speed := 100.0 *: kph
  -- 100 km/h ≈ 27.78 m/s
  ensure (approxEq speed.value 27.7778 0.001) "Expected ~27.78 m/s internally"

test "kilogram * kilometer / hour² creates force-like unit" := do
  let unit := kilogram * kilometer / (hour * hour)
  let value := 1.0 *: unit
  -- 1 kg·km/h² = 1 kg · 1000m / (3600s)² ≈ 7.716e-5 kg·m/s²
  ensure (approxEq value.value 7.716049e-5 1e-8) "Expected ~7.716e-5"

testSuite "Compound Unit Display"

test "velocity unit symbol" := do
  let velocity := meter / second
  ensure (velocity.symbol == "m/s") s!"Expected 'm/s', got '{velocity.symbol}'"

test "area unit symbol" := do
  let area := meter.sq
  ensure (area.symbol == "m²") s!"Expected 'm²', got '{area.symbol}'"

test "energy unit symbol (N·m)" := do
  let energy := newton * meter
  ensure (energy.symbol == "N·m") s!"Expected 'N·m', got '{energy.symbol}'"

testSuite "Chained Operations"

test "multiple divisions" := do
  -- kg / m / s² = kg·m⁻¹·s⁻² (pressure-like)
  let unit := kilogram / meter / (second * second)
  let value := 101325.0 *: unit  -- atmospheric pressure
  ensure (approxEq (value.asUnit pascal) 101325.0) "Expected 101325 Pa"

test "mixed multiply and divide" := do
  -- (kg · m) / s² = N (force)
  let unit := (kilogram * meter) / (second * second)
  let force := 10.0 *: unit
  ensure (approxEq (force.asUnit newton) 10.0) "Expected 10 N"



end MeasuresTests.CompoundUnitTests
