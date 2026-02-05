/-
  Chisel Test Suite
-/
import Crucible
import ChiselTests.Literal
import ChiselTests.Expr
import ChiselTests.Select
import ChiselTests.DML
import ChiselTests.DDL
import ChiselTests.Parser

open Crucible

def main : IO UInt32 := do
  IO.println "Chisel SQL DSL Tests"
  IO.println "===================="
  runAllSuites
