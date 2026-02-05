/-
  Tabular Test Suite
-/
import Crucible
import TabularTests.ParserTests
import TabularTests.ExtractTests

open Crucible

def main : IO UInt32 := do
  IO.println "Tabular Library Tests"
  IO.println "====================="
  runAllSuites
