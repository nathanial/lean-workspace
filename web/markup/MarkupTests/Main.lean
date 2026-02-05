/-
  Tests/Main.lean - Test entry point for Markup HTML parser
-/

import Crucible
import MarkupTests.Parser.Elements
import MarkupTests.Parser.Attributes
import MarkupTests.Parser.Entities
import MarkupTests.Parser.Documents
import MarkupTests.Parser.Errors

open Crucible

def main : IO UInt32 := runAllSuites
