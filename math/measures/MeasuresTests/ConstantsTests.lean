/-
  Tests for physical constants.
-/

import Measures
import Crucible
import MeasuresTests.TestUtils

namespace MeasuresTests.ConstantsTests

open Crucible
open Measures
open Measures.Constants
open Measures.Units.SI
open MeasuresTests.TestUtils
open scoped Measures.Quantity  -- For *. and /. operators

testSuite "Physical Constants Values"

test "speed of light value" := do
  let cValue := c.asUnit meterPerSecond
  ensure (approxEq cValue 299792458.0 1.0) s!"Expected 299792458, got {cValue}"

test "Planck constant value" := do
  -- h ≈ 6.626e-34 J·s
  ensure (approxEq h.value 6.62607015e-34 1e-42) "Planck constant value incorrect"

test "reduced Planck constant is h/2π" := do
  let expected := h.value / (2.0 * Constants.π)
  ensure (approxEq hbar.value expected 1e-42) "ℏ should equal h/2π"

test "gravitational constant value" := do
  ensure (approxEq G.value 6.67430e-11 1e-15) "G value incorrect"

test "elementary charge value" := do
  ensure (approxEq e_charge.value 1.602176634e-19 1e-28) "e value incorrect"

test "Boltzmann constant value" := do
  ensure (approxEq k_B.value 1.380649e-23 1e-30) "k_B value incorrect"

test "Avogadro constant value" := do
  ensure (approxEq N_A.value 6.02214076e23 1e16) "N_A value incorrect"

test "electron mass value" := do
  ensure (approxEq m_e.value 9.1093837015e-31 1e-40) "m_e value incorrect"

test "proton mass value" := do
  ensure (approxEq m_p.value 1.67262192369e-27 1e-37) "m_p value incorrect"

test "standard gravity value" := do
  let gValue := g_n.asUnit meterPerSecondSquared
  ensure (approxEq gValue 9.80665 0.00001) s!"Expected 9.80665, got {gValue}"

test "standard atmosphere value" := do
  let atmValue := atm.asUnit pascal
  ensure (approxEq atmValue 101325.0 0.1) s!"Expected 101325, got {atmValue}"

testSuite "Physical Constants Dimensions"

test "speed of light has velocity dimension" := do
  -- If it compiles with this type, dimension is correct
  let _ : Quantity Dimension.Velocity := c
  pure ()

test "Planck constant has action dimension" := do
  let _ : Quantity Dimension.Action := h
  pure ()

test "gravitational constant has correct dimension" := do
  let _ : Quantity Dimension.GravitationalConstant := G
  pure ()

test "Boltzmann constant has entropy dimension" := do
  let _ : Quantity Dimension.Entropy := k_B
  pure ()

test "Avogadro constant has inverse amount dimension" := do
  let _ : Quantity Dimension.InverseAmount := N_A
  pure ()

test "electron mass has mass dimension" := do
  let _ : Quantity Dimension.Mass := m_e
  pure ()

test "standard gravity has acceleration dimension" := do
  let _ : Quantity Dimension.Acceleration := g_n
  pure ()

test "standard atmosphere has pressure dimension" := do
  let _ : Quantity Dimension.Pressure := atm
  pure ()

testSuite "Physical Constants Usage"

test "E = mc²" := do
  -- Energy of 1 kg at rest
  let mass := 1.0 *: kilogram
  let cSquared := c *. c
  let energy := mass *. cSquared
  -- Should be about 8.99e16 J
  ensure (approxEq (energy.asUnit joule) 8.987551787e16 1e10) "E=mc² calculation"

test "proton to electron mass ratio" := do
  let ratio := m_p.value / m_e.value
  -- Should be about 1836.15
  ensure (approxEq ratio 1836.15 0.01) s!"Expected ~1836.15, got {ratio}"

test "fine structure constant is dimensionless" := do
  let _ : Quantity Dimension.one := α
  -- α ≈ 1/137
  ensure (approxEq α.value 7.2973525693e-3 1e-12) "α value incorrect"
  ensure (approxEq (1.0 / α.value) 137.036 0.001) "1/α should be ~137"

test "Boltzmann and gas constant relation" := do
  -- R = N_A * k_B
  let computed := N_A.value * k_B.value
  ensure (approxEq computed R.value 1e-6) "R should equal N_A * k_B"



end MeasuresTests.ConstantsTests
