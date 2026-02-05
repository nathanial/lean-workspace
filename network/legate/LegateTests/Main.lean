/-
  Legate Test Runner

  Run all tests with: lake test
-/

import Crucible
import LegateTests.ErrorTests
import LegateTests.MetadataTests
import LegateTests.StatusTests

open Crucible

def main : IO UInt32 := do
  IO.println "╔══════════════════════════════════════════════════════════════╗"
  IO.println "║                     Legate Test Suite                        ║"
  IO.println "╚══════════════════════════════════════════════════════════════╝"
  IO.println ""

  let exitCode ← runAllSuites

  IO.println ""
  IO.println "══════════════════════════════════════════════════════════════"

  if exitCode == 0 then
    IO.println "All tests passed!"
    return 0
  else
    IO.println "Some tests failed"
    return 1
