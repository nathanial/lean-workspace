/-
  Tests for Dimension operations.
-/

import Measures
import Crucible

namespace MeasuresTests.DimensionTests

open Crucible
open Measures
open Dimension

testSuite "Dimension Basics"

test "one is dimensionless" := do
  ensure (Dimension.one.isDimensionless) "one should be dimensionless"

test "base dimensions are not dimensionless" := do
  ensure (!Length.isDimensionless) "Length should not be dimensionless"
  ensure (!Mass.isDimensionless) "Mass should not be dimensionless"
  ensure (!Time.isDimensionless) "Time should not be dimensionless"

testSuite "Dimension Arithmetic"

test "one is identity for multiplication" := do
  let d := Length
  (d.mul Dimension.one) ≡ d
  (Dimension.one.mul d) ≡ d

test "mul adds exponents" := do
  let result := Length.mul Time
  result.length ≡ 1
  result.time ≡ 1

test "div subtracts exponents" := do
  let velocity := Length.div Time
  velocity.length ≡ 1
  velocity.time ≡ (-1)

test "velocity dimension matches Velocity constant" := do
  let computed := Length.div Time
  computed ≡ Velocity

test "force dimension matches Force constant" := do
  -- F = m * a = m * (L / T^2)
  let accel := Length.div (Time.pow 2)
  let force := Mass.mul accel
  force ≡ Force

test "energy dimension matches Energy constant" := do
  -- E = F * d = (M * L / T^2) * L = M * L^2 / T^2
  let energy := Force.mul Length
  energy ≡ Energy

test "power dimension matches Power constant" := do
  -- P = E / T = M * L^2 / T^3
  let power := Energy.div Time
  power ≡ Power

test "inv negates exponents" := do
  let inv := Velocity.inv
  inv.length ≡ (-1)
  inv.time ≡ 1

test "pow multiplies exponents" := do
  let squared := Length.pow 2
  squared.length ≡ 2
  squared ≡ Area

  let cubed := Length.pow 3
  cubed.length ≡ 3
  cubed ≡ Volume

test "mul and div are inverses" := do
  let d := Velocity
  let roundtrip := d.mul Time |>.div Time
  roundtrip ≡ d

testSuite "Dimension Square Root"

test "canSqrt for even exponents" := do
  ensure (Area.canSqrt) "Area should be sqrt-able"
  ensure ((Length.pow 4).canSqrt) "L^4 should be sqrt-able"

test "canSqrt false for odd exponents" := do
  ensure (!Length.canSqrt) "Length should not be sqrt-able"
  ensure (!Velocity.canSqrt) "Velocity should not be sqrt-able"

test "sqrt halves exponents" := do
  let sqrtArea := Area.sqrt
  sqrtArea ≡ Length

  let sqrtL4 := (Length.pow 4).sqrt
  sqrtL4 ≡ Area

testSuite "Dimension Hashable"

test "equal dimensions have equal hashes" := do
  let d1 := Length
  let d2 : Dimension := { length := 1 }
  ensure (hash d1 == hash d2) "Equal dimensions should have equal hashes"

test "different dimensions can have different hashes" := do
  let len := Length
  let mass := Mass
  -- Not guaranteed but highly likely
  ensure (hash len != hash mass) "Different dimensions likely have different hashes"

test "hash is consistent" := do
  let d := Velocity
  -- Calling hash multiple times should give same result
  ensure (hash d == hash d) "Hash should be consistent"



end MeasuresTests.DimensionTests
