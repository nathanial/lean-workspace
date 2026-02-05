/-
  Cellar Test Suite Entry Point
-/
import Crucible
import CellarTests.Config
import CellarTests.LRU
import CellarTests.IO

open Crucible

def main : IO UInt32 := do
  IO.println "Cellar Library Tests"
  IO.println "===================="
  runAllSuites
