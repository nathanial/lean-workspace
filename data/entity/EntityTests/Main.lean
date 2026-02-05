/-
  Entity Test Runner
-/
import EntityTests.CoreTests
import EntityTests.WorldTests
import EntityTests.QueryTests
import EntityTests.SystemTests
import Crucible

open Crucible

def main : IO UInt32 := runAllSuites
