/-
  Tincture Test Suite
  Main entry point for running all tests.
-/

import TinctureTests.ColorTests
import TinctureTests.SpaceTests
import TinctureTests.BlendTests
import TinctureTests.ContrastTests
import TinctureTests.HarmonyTests
import TinctureTests.ParseFormatTests
-- import TinctureTests.PropertyTests  -- Disabled: requires Plausible
import Crucible

open Crucible

def main : IO UInt32 := do
  IO.println "Tincture Color Library Tests"
  IO.println "============================"
  IO.println ""

  let result ← runAllSuites

  IO.println ""
  IO.println "============================"

  if result != 0 then
    IO.println "Some tests failed!"
    return 1
  else
    IO.println "All tests passed!"
    return 0
