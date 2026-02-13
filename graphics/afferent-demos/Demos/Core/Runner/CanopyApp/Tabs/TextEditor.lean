/-
  Demo Runner - Canopy app TextEditor tab content.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Trellis

open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

namespace Demos

private def initialDocText : String :=
  "Afferent Text Editor\n\n" ++
  "This is plain text mode today.\n" ++
  "Next steps: rich text blocks, inline styling, and embedded widgets (charts/tables).\n\n" ++
  "Try typing, newlines, arrows, home/end, and delete/backspace."

def textEditorTabContent (env : DemoEnv) : WidgetM Unit := do
  let frameStyle : BoxStyle := {
    width := .percent 1.0
    height := .percent 1.0
    flexItem := some (FlexItem.growing 1)
  }

  let editorConfig : TextEditorConfig := {
    width := max 560 (env.windowWidthF - 120)
    height := max 320 (env.windowHeightF - 260)
    showLineNumbers := true
    showStatusBar := true
    mode := .plain
  }

  column' (gap := 10) (style := frameStyle) do
    caption' "Plain text editor widget (initial foundation for richer document editing)."
    let editor ← textEditor "Start writing..." initialDocText editorConfig
    let details ← Dynamic.zipWith3M (fun c l d => (c, l, d)) editor.cursor editor.lineCount editor.document
    let _ ← dynWidget details fun (cursor, lineCount, doc) => do
      caption' s!"Cursor Ln {cursor.line}, Col {cursor.column} | {lineCount} lines | {doc.blocks.size} blocks"
    pure ()

end Demos
