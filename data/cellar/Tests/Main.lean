/-
  Cellar Test Suite Entry Point
-/
import Crucible
import Tests.Config
import Tests.LRU
import Tests.IO

open Crucible

def main : IO UInt32 := do
  IO.println "Cellar Library Tests"
  IO.println "===================="
  runAllSuites
