/-
  Measures Test Suite
  Main entry point for running all tests.
-/

import MeasuresTests.DimensionTests
import MeasuresTests.QuantityTests
import MeasuresTests.ConversionTests
import MeasuresTests.ArithmeticTests
import MeasuresTests.CompoundUnitTests
import MeasuresTests.ConstantsTests
import Crucible

open Crucible

def main : IO UInt32 := do
  IO.println "Measures Library Tests"
  IO.println "======================"
  IO.println ""

  let result ← runAllSuites

  IO.println ""
  IO.println "======================"

  if result != 0 then
    IO.println "Some tests failed!"
    return 1
  else
    IO.println "All tests passed!"
    return 0
