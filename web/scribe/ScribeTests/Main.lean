/-
  Scribe Test Suite
-/
import Crucible
import ScribeTests.Builder
import ScribeTests.Components

open Crucible

def main : IO UInt32 := do
  IO.println "Scribe HTML Builder Tests"
  IO.println "========================="
  IO.println ""

  let result ← runAllSuites

  IO.println ""
  if result != 0 then
    IO.println "Some tests failed!"
    return 1
  else
    IO.println "All tests passed!"
    return 0
