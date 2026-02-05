/-
  Quarry Test Suite

  This file imports all test modules and runs them.
-/
import Crucible
import QuarryTests.Database
import QuarryTests.Binding
import QuarryTests.Row
import QuarryTests.ErrorHandling
import QuarryTests.Config
import QuarryTests.UserFunctions
import QuarryTests.Backup
import QuarryTests.VirtualTable
import QuarryTests.Extensions
import QuarryTests.Blob
import QuarryTests.Hook
import QuarryTests.Serialize
import QuarryTests.Chisel

open Crucible

def main : IO UInt32 := do
  IO.println "Quarry Library Tests"
  IO.println "===================="
  runAllSuites
