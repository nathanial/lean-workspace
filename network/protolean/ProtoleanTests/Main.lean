/-
  Test runner for Protolean.
-/
import Crucible
import ProtoleanTests.Varint
import ProtoleanTests.Scalar
import ProtoleanTests.Parser
import ProtoleanTests.Import
import ProtoleanTests.Service
import ProtoleanTests.WellKnown

open Crucible

def main : IO Unit := do
  IO.println "╔══════════════════════════════════════════════════════════════╗"
  IO.println "║                    Protolean Test Suite                      ║"
  IO.println "╚══════════════════════════════════════════════════════════════╝"
  IO.println ""

  let exitCode ← runAllSuites

  IO.println ""
  IO.println "══════════════════════════════════════════════════════════════"

  if exitCode == 0 then
    IO.println "All tests passed!"
  else
    IO.println "Some tests failed"
    IO.Process.exit 1
