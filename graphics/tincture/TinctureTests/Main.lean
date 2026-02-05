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
import TinctureTests.PropertyTests  -- Plausible tests run at compile time via #test
import Crucible

open Crucible

def main : IO UInt32 := do
  IO.println "Tincture Color Library Tests"
  IO.println "============================"
  IO.println ""

  let result ← runAllSuites
  -- PropertyTests uses Plausible #test (runs at compile time)

  IO.println ""
  IO.println "============================"
  IO.println "(Property tests with Plausible run during compilation)"

  if result != 0 then
    IO.println "Some tests failed!"
    return 1
  else
    IO.println "All tests passed!"
    return 0
