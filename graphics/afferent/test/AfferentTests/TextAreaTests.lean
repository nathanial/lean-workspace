/-
  TextArea Widget Tests
  Unit tests for multiline cursor navigation behavior.
-/
import AfferentTests.Framework
import Afferent.UI.Canopy.Widget.Input.TextArea
import Afferent.UI.Arbor.Event.Types

namespace AfferentTests.TextAreaTests

open Crucible
open AfferentTests
open Afferent.Canopy
open Afferent.Arbor

testSuite "TextArea Tests"

private def wrappedLine (text : String) (startIdx endIdx : Nat) : WrappedLine :=
  { text := text, startIdx := startIdx, endIdx := endIdx, width := 0 }

private def stateWithLines (value : String) (cursor : Nat) (lines : Array WrappedLine) : TextAreaState :=
  {
    value := value
    cursor := cursor
    renderState := { wrappedLines := lines }
  }

test "lineColToCursor clamps to visible text and excludes trailing newline span" := do
  let lines : Array WrappedLine := #[
    wrappedLine "short" 0 6, -- includes newline at index 5 (endIdx = 6)
    wrappedLine "longline" 6 14
  ]
  let cursor := TextArea.lineColToCursor 0 999 lines
  ensure (cursor == 5)
    s!"Expected clamp to end of visible first line (5), got {cursor}"

test "moveCursorUp from long line to shorter previous line lands at previous line end" := do
  let value := "short\nveryverylong"
  let lines : Array WrappedLine := #[
    wrappedLine "short" 0 6,
    wrappedLine "veryverylong" 6 18
  ]
  let state := stateWithLines value 14 lines -- line 2, column 8
  let moved := TextArea.moveCursorUp state lines
  ensure (moved.cursor == 5)
    s!"Expected cursor at end of first line (5), got {moved.cursor}"

test "moveCursorDown from long line to shorter next line lands at next line end" := do
  let value := "veryverylong\nshort"
  let lines : Array WrappedLine := #[
    wrappedLine "veryverylong" 0 13,
    wrappedLine "short" 13 18
  ]
  let state := stateWithLines value 10 lines -- line 1, column 10
  let moved := TextArea.moveCursorDown state lines
  ensure (moved.cursor == 18)
    s!"Expected cursor at end of second line (18), got {moved.cursor}"

test "moveCursorUp from line start moves to previous line start" := do
  let value := "abc\ndef"
  let lines : Array WrappedLine := #[
    wrappedLine "abc" 0 4,
    wrappedLine "def" 4 7
  ]
  let state := stateWithLines value 4 lines -- start of second line
  let moved := TextArea.moveCursorUp state lines
  ensure (moved.cursor == 0) s!"Expected cursor 0, got {moved.cursor}"

test "moveCursorUp preserves target column through shorter intermediate line" := do
  let value := "abcdefghij\nabc\nabcdefghij"
  let lines : Array WrappedLine := #[
    wrappedLine "abcdefghij" 0 11,
    wrappedLine "abc" 11 15,
    wrappedLine "abcdefghij" 15 25
  ]
  let start := stateWithLines value 23 lines -- line 3, column 8
  let up1 := TextArea.moveCursorUp start lines
  ensure (up1.cursor == 14) s!"Expected clamped cursor 14 on short middle line, got {up1.cursor}"
  let up2 := TextArea.moveCursorUp up1 lines
  ensure (up2.cursor == 8)
    s!"Expected restored target column on top line at cursor 8, got {up2.cursor}"

test "handleKeyPress up arrow moves to previous line (regression)" := do
  let value := "short\nveryverylong"
  let lines : Array WrappedLine := #[
    wrappedLine "short" 0 6,
    wrappedLine "veryverylong" 6 18
  ]
  let state := stateWithLines value 14 lines
  let keyEvent : KeyEvent := { key := .up, modifiers := {} }
  let moved := TextArea.handleKeyPress keyEvent state none
  ensure (moved.cursor == 5)
    s!"Expected up-arrow to move to previous line end (5), got {moved.cursor}"

test "handleKeyPress cmd+up moves cursor to start of document" := do
  let value := "line1\nline2"
  let lines : Array WrappedLine := #[
    wrappedLine "line1" 0 6,
    wrappedLine "line2" 6 11
  ]
  let state := stateWithLines value 8 lines
  let keyEvent : KeyEvent := { key := .up, modifiers := { cmd := true } }
  let moved := TextArea.handleKeyPress keyEvent state none
  ensure (moved.cursor == 0) s!"Expected cmd+up to move to 0, got {moved.cursor}"

test "handleKeyPress down arrow advances to next line" := do
  let value := "abc\ndef\nghi"
  let lines : Array WrappedLine := #[
    wrappedLine "abc" 0 4,
    wrappedLine "def" 4 8,
    wrappedLine "ghi" 8 11
  ]
  let state := stateWithLines value 1 lines -- line 1, column 1
  let keyEvent : KeyEvent := { key := .down, modifiers := {} }
  let moved := TextArea.handleKeyPress keyEvent state none
  ensure (moved.cursor == 5) s!"Expected cursor 5 (line 2, column 1), got {moved.cursor}"

end AfferentTests.TextAreaTests
