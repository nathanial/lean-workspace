/-
  TextEditor Widget Tests
  Unit tests for document conversion and cursor/line helpers.
-/
import AfferentTests.Framework
import Afferent.UI.Arbor
import Afferent.UI.Arbor.Widget.DSL
import Afferent.UI.Canopy.Reactive.Component
import Afferent.UI.Canopy.Widget.Input.TextEditor
import Trellis

namespace AfferentTests.TextEditorTests

open Crucible
open AfferentTests
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

testSuite "TextEditor Tests"

private def wrappedLine (text : String) : WrappedLine :=
  { text := text, startIdx := 0, endIdx := text.length, width := 0 }

private def testFont : FontId := { id := 0, name := "test", size := 14.0 }

private def testTheme : Theme := { Theme.dark with font := testFont, smallFont := testFont }

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

test "TextEditor.clampScrollOffset clamps inside content bounds" := do
  let state : TextAreaState := {
    scrollOffsetY := 999
    renderState := {
      wrappedLines := #[
        wrappedLine "a",
        wrappedLine "b",
        wrappedLine "c",
        wrappedLine "d",
        wrappedLine "e"
      ]
      lineHeight := 20
    }
  }
  let clamped := TextEditor.clampScrollOffset state 60
  ensure (clamped.scrollOffsetY == 40)
    s!"Expected max scroll 40, got {clamped.scrollOffsetY}"

test "TextEditor.scrollBy supports both forward and backward wheel movement" := do
  let state : TextAreaState := {
    scrollOffsetY := 20
    renderState := {
      wrappedLines := #[
        wrappedLine "a",
        wrappedLine "b",
        wrappedLine "c",
        wrappedLine "d",
        wrappedLine "e"
      ]
      lineHeight := 20
    }
  }
  let movedDown := TextEditor.scrollBy state 60 25
  ensure (movedDown.scrollOffsetY == 40)
    s!"Expected downward scroll clamp at 40, got {movedDown.scrollOffsetY}"
  let movedUp := TextEditor.scrollBy state 60 (-50)
  ensure (movedUp.scrollOffsetY == 0)
    s!"Expected upward scroll clamp at 0, got {movedUp.scrollOffsetY}"

test "TextEditor.editorVisual does not force fixed min/max bounds" := do
  let cfg : TextEditorConfig := { width := 640, height := 420 }
  let state : TextAreaState := {}
  let cursor : TextEditorCursor := {}
  let (widget, _) ← (TextEditor.editorVisual 9001 testTheme state cursor "" cfg).run {}
  match widget with
  | .flex _ _ _ style _ _ =>
      ensure (style.width == .length 640) s!"Expected explicit width 640, got {repr style.width}"
      ensure (style.height == .length 420) s!"Expected explicit height 420, got {repr style.height}"
      ensure style.minHeight.isNone "Expected no forced minHeight on editor frame"
      ensure style.maxHeight.isNone "Expected no forced maxHeight on editor frame"
      ensure style.minWidth.isNone "Expected no forced minWidth on editor frame"
      ensure style.maxWidth.isNone "Expected no forced maxWidth on editor frame"
  | _ =>
      ensure false "Expected editorVisual root to be a flex widget"

test "TextEditor.editorVisual uses fill sizing when enabled" := do
  let cfg : TextEditorConfig := { width := 640, height := 420, fillWidth := true, fillHeight := true }
  let state : TextAreaState := {}
  let cursor : TextEditorCursor := {}
  let (widget, _) ← (TextEditor.editorVisual 9003 testTheme state cursor "" cfg).run {}
  match widget with
  | .flex _ _ _ style _ _ =>
      ensure (style.width == .percent 1.0) s!"Expected percent width fill, got {repr style.width}"
      ensure (style.height == .percent 1.0) s!"Expected percent height fill, got {repr style.height}"
      match style.flexItem with
      | some fi =>
          ensure (fi.grow == 1) s!"Expected grow=1 for fillHeight, got {fi.grow}"
      | none =>
          ensure false "Expected flexItem.growing for fillHeight"
  | _ =>
      ensure false "Expected editorVisual root to be a flex widget"

test "TextEditor.editorVisual can shrink within a constrained column" := do
  let cfg : TextEditorConfig := {
    width := 640
    height := 420
    showLineNumbers := true
    showStatusBar := true
  }
  let state : TextAreaState := {
    value := "line 1\nline 2\nline 3"
    renderState := {
      wrappedLines := #[wrappedLine "line 1", wrappedLine "line 2", wrappedLine "line 3"]
      lineHeight := 20
      padding := 10
    }
  }
  let cursor : TextEditorCursor := { line := 1, column := 1 }
  let editor := TextEditor.editorVisual 9002 testTheme state cursor "" cfg
  let parent := column (gap := 0) (style := {
    width := .length 500
    height := .length 260
    minWidth := some 500
    maxWidth := some 500
    minHeight := some 260
    maxHeight := some 260
  }) #[editor]
  let (widget, _) ← parent.run {}
  let measureResult : MeasureResult := measureWidget (M := Id) widget 500 260
  let layouts := Trellis.layout measureResult.node 500 260
  let editorWid ← match findWidgetIdByName measureResult.widget 9002 with
    | some wid => pure wid
    | none =>
        ensure false "Expected to find text editor by component id"
        pure 0
  let editorLayout := layouts.get! editorWid
  ensure (editorLayout.borderRect.height <= 260.0)
    s!"Expected editor to shrink to parent height, got {editorLayout.borderRect.height}"

end AfferentTests.TextEditorTests
