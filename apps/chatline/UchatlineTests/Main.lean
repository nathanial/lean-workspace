import Crucible

open Crucible

testSuite "chatline"

test "placeholder" := do
  (1 + 1) ≡ (2 : Nat)

def main : IO UInt32 := runAllSuites
