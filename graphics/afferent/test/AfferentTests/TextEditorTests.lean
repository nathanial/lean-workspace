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

end AfferentTests.TextEditorTests
