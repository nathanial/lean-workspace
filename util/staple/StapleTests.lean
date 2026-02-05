/-
  Staple Test Suite
-/
import Crucible
import StapleTests.Hex
import StapleTests.Ascii
import StapleTests.String
import StapleTests.Json
import StapleTests.Include

open Crucible

def main : IO UInt32 := runAllSuites
