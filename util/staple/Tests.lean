/-
  Staple Test Suite
-/
import Crucible
import Tests.Hex
import Tests.Ascii
import Tests.String
import Tests.Json
import Tests.Include

open Crucible

def main : IO UInt32 := runAllSuites
