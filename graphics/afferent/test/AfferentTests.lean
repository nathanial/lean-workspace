/-
  Afferent Test Runner
  Entry point for running all tests.
-/
import AfferentTests.TessellationTests
import AfferentTests.LayoutTests
import AfferentTests.CanvasStateTests
import AfferentTests.BackendExecuteTests
import AfferentTests.FontTests
import AfferentTests.RenderSmokeTests
import AfferentTests.CSSTests
import AfferentTests.ScrollContainerTests
import AfferentTests.TooltipTests
import AfferentTests.MenuTests
import AfferentTests.MenuBarTests
import AfferentTests.DropdownTests
import AfferentTests.TableTests
import AfferentTests.ListBoxTests
import AfferentTests.TreeViewTests
import AfferentTests.VirtualListTests
import AfferentTests.ColorPickerTests
import AfferentTests.WidgetCoverageTests
import AfferentTests.ReactiveLayoutTests
import AfferentTests.DynWidgetTests
import AfferentTests.ShaderDSLTests
import AfferentTests.TextInputTests
import AfferentTests.MDITests
import AfferentTests.TextAreaTests
import AfferentTests.TextEditorTests
import Crucible

open Crucible
open AfferentTests

def main : IO UInt32 := do
  IO.println "╔════════════════════════════════════════╗"
  IO.println "║       Afferent Test Suite              ║"
  IO.println "╚════════════════════════════════════════╝"

  let exitCode ← runAllSuites

  -- Summary
  IO.println ""
  if exitCode == 0 then
    IO.println "✓ All test suites passed!"
  else
    IO.println "✗ Some tests failed"

  return if exitCode > 0 then 1 else 0
