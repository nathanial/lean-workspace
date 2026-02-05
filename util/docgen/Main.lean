/-
  Docgen - Main entry point
-/
import Docgen
import Docgen.CLI

def main (args : List String) : IO UInt32 :=
  Docgen.CLI.run args
