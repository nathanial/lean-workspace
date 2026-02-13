/-
  TextEditor Widget Tests
  Unit tests for document conversion and cursor/line helpers.
-/
import AfferentTests.Framework
import Afferent.UI.Canopy.Widget.Input.TextEditor

namespace AfferentTests.TextEditorTests

open Crucible
open AfferentTests
open Afferent.Canopy

testSuite "TextEditor Tests"

test "TextEditorDocument round-trips plain text with multiple lines" := do
  let src := "hello\nworld\n"
  let doc := TextEditorDocument.fromPlainText src
  let out := TextEditorDocument.toPlainText doc
  ensure (out == src) s!"Expected round-trip to preserve text; got '{out}'"

test "TextEditorDocument serializes embed segments as placeholders" := do
  let doc : TextEditorDocument := {
    blocks := #[
      { segments := #[.text "Chart: ", .embed "chart" "sales"] },
      { segments := #[.text "Done"] }
    ]
  }
  let out := TextEditorDocument.toPlainText doc
  ensure (out == "Chart: [[embed:chart:sales]]\nDone")
    s!"Expected embed placeholder output; got '{out}'"

test "TextEditor.cursorLocation tracks line and column from cursor index" := do
  let state : TextAreaState := { value := "ab\ncde\nf", cursor := 5 }
  let pos := TextEditor.cursorLocation state
  ensure (pos.line == 2) s!"Expected line 2, got {pos.line}"
  ensure (pos.column == 3) s!"Expected column 3, got {pos.column}"

test "TextEditor.logicalLineCount counts logical newline-delimited lines" := do
  ensure (TextEditor.logicalLineCount "" == 1) "Empty text should count as one line"
  ensure (TextEditor.logicalLineCount "one" == 1) "Single line text should count as one line"
  ensure (TextEditor.logicalLineCount "one\ntwo\nthree" == 3) "Expected three logical lines"
  ensure (TextEditor.logicalLineCount "one\n" == 2) "Trailing newline should create an empty line"

test "TextEditorDocument.fromPlainText keeps an empty trailing line for trailing newline" := do
  let doc := TextEditorDocument.fromPlainText "alpha\nbeta\n"
  ensure (doc.blocks.size == 3) s!"Expected 3 blocks, got {doc.blocks.size}"
  let out := TextEditorDocument.toPlainText doc
  ensure (out == "alpha\nbeta\n") s!"Expected trailing newline to round-trip, got '{out}'"

test "TextEditor.cursorLocation reports first line/column for cursor 0" := do
  let state : TextAreaState := { value := "hello\nworld", cursor := 0 }
  let pos := TextEditor.cursorLocation state
  ensure (pos.line == 1) s!"Expected line 1, got {pos.line}"
  ensure (pos.column == 1) s!"Expected column 1, got {pos.column}"

test "TextEditor.cursorLocation reports end position at text length" := do
  let text := "ab\ncd"
  let state : TextAreaState := { value := text, cursor := text.length }
  let pos := TextEditor.cursorLocation state
  ensure (pos.line == 2) s!"Expected line 2, got {pos.line}"
  ensure (pos.column == 3) s!"Expected column 3, got {pos.column}"

test "TextEditor viewport helpers account for gutter and status bar" := do
  let cfg : TextEditorConfig := {
    width := 800
    height := 500
    padding := 10
    gutterWidth := 60
    showLineNumbers := true
    showStatusBar := true
  }
  ensure (TextEditor.statusBarHeight cfg == 28) "Expected status bar height 28"
  ensure (TextEditor.viewportWidth cfg == 720)
    s!"Expected viewport width 720, got {TextEditor.viewportWidth cfg}"
  ensure (TextEditor.viewportHeight cfg == 452)
    s!"Expected viewport height 452, got {TextEditor.viewportHeight cfg}"

test "TextEditor viewport width ignores gutter when line numbers are disabled" := do
  let cfg : TextEditorConfig := {
    width := 420
    height := 260
    padding := 8
    gutterWidth := 80
    showLineNumbers := false
    showStatusBar := false
  }
  ensure (TextEditor.viewportWidth cfg == 404)
    s!"Expected viewport width 404, got {TextEditor.viewportWidth cfg}"
  ensure (TextEditor.viewportHeight cfg == 244)
    s!"Expected viewport height 244, got {TextEditor.viewportHeight cfg}"

end AfferentTests.TextEditorTests
