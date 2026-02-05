/-
  Tabular Test Suite
-/
import Crucible
import Tests.ParserTests
import Tests.ExtractTests

open Crucible

def main : IO UInt32 := do
  IO.println "Tabular Library Tests"
  IO.println "====================="
  runAllSuites
