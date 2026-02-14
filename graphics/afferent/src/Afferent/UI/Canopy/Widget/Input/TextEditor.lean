/-
  Canopy TextEditor Widget
  Plain-text editor with line numbers and status metadata, designed to grow into rich content.
-/
import Reactive
import Afferent.UI.Canopy.Core
import Afferent.UI.Canopy.Theme
import Afferent.UI.Canopy.Widget.Input.TextArea
import Afferent.UI.Canopy.Reactive.Component

namespace Afferent.Canopy

open Afferent.Arbor hiding Event
open Reactive Reactive.Host
open Afferent.Canopy.Reactive
open Trellis

/-! ## Document Model

This model intentionally supports non-text segments so future rich/embedded rendering can
reuse the same editor API. The current implementation uses plain text editing only.
-/

/-- Inline segment in an editor document. -/
inductive TextEditorSegment where
  | text (content : String)
  | embed (kind : String) (payload : String := "")
deriving Repr, BEq, Inhabited

/-- Block in an editor document. -/
structure TextEditorBlock where
  segments : Array TextEditorSegment := #[.text ""]
deriving Repr, BEq, Inhabited

/-- Editor document composed of blocks. -/
structure TextEditorDocument where
  blocks : Array TextEditorBlock := #[{}]
deriving Repr, BEq, Inhabited

namespace TextEditorDocument

private def splitLines (text : String) : List String :=
  let rec loop (chars : List Char) (lineRev : List Char) (accRev : List String) : List String :=
    match chars with
    | [] =>
        let line := String.ofList lineRev.reverse
        (line :: accRev).reverse
    | ch :: rest =>
        if ch == '\n' then
          let line := String.ofList lineRev.reverse
          loop rest [] (line :: accRev)
        else
          loop rest (ch :: lineRev) accRev
  loop text.toList [] []

private def segmentToPlain (segment : TextEditorSegment) : String :=
  match segment with
  | .text content => content
  | .embed kind payload =>
      if payload.isEmpty then
        s!"[[embed:{kind}]]"
      else
        s!"[[embed:{kind}:{payload}]]"

private def blockToPlain (block : TextEditorBlock) : String :=
  block.segments.foldl (fun acc segment => acc ++ segmentToPlain segment) ""

private def joinLines (lines : List String) : String :=
  match lines with
  | [] => ""
  | line :: rest => rest.foldl (fun acc next => acc ++ "\n" ++ next) line

/-- Build a document from plain text (current editor mode). -/
def fromPlainText (text : String) : TextEditorDocument :=
  let blocks := (splitLines text).map (fun line => ({ segments := #[.text line] } : TextEditorBlock))
  match blocks with
  | [] => { blocks := #[{}] }
  | _ => { blocks := blocks.toArray }

/-- Convert document back to plain text.
    Embed segments serialize as placeholder tokens for now. -/
def toPlainText (doc : TextEditorDocument) : String :=
  let lines := doc.blocks.toList.map blockToPlain
  joinLines lines

end TextEditorDocument

/-- Cursor location in line/column space (1-based). -/
structure TextEditorCursor where
  line : Nat := 1
  column : Nat := 1
deriving Repr, BEq, Inhabited

/-- Editor mode for forward compatibility. -/
inductive TextEditorMode where
  | plain
  | rich
deriving Repr, BEq, Inhabited

/-- Config for text editor rendering/behavior. -/
structure TextEditorConfig where
  width : Float := 720
  height : Float := 420
  fillWidth : Bool := false
  fillHeight : Bool := false
  padding : Float := 10
  scrollSpeed : Float := 20
  gutterWidth : Float := 52
  showLineNumbers : Bool := true
  showStatusBar : Bool := true
  mode : TextEditorMode := .plain
  maxLen : Option Nat := none
deriving Repr, Inhabited

namespace TextEditor

def statusBarHeight (config : TextEditorConfig) : Float :=
  if config.showStatusBar then 28 else 0

def viewportWidth (config : TextEditorConfig) : Float :=
  let gutter := if config.showLineNumbers then config.gutterWidth else 0
  max 64 (config.width - config.padding * 2 - gutter)

def viewportHeight (config : TextEditorConfig) : Float :=
  max 48 (config.height - config.padding * 2 - statusBarHeight config)

private def lineColFromTextPrefix (textPrefix : String) : TextEditorCursor :=
  let (line, col) := textPrefix.toList.foldl
    (fun (pos : Nat × Nat) ch =>
      if ch == '\n' then
        (pos.1 + 1, 1)
      else
        (pos.1, pos.2 + 1))
    (1, 1)
  { line, column := col }

/-- Cursor location from flat cursor index in text. -/
def cursorLocation (state : TextAreaState) : TextEditorCursor :=
  lineColFromTextPrefix (state.value.take state.cursor)

/-- Count logical lines in editor text (newline-delimited). -/
def logicalLineCount (text : String) : Nat :=
  let lineCount := text.toList.foldl
    (fun acc ch => if ch == '\n' then acc + 1 else acc)
    1
  max 1 lineCount

/-- Total rendered content height in pixels. -/
def contentHeight (state : TextAreaState) : Float :=
  state.renderState.wrappedLines.size.toFloat * state.renderState.lineHeight

/-- Clamp scroll offset into valid content range for current viewport height. -/
def clampScrollOffset (state : TextAreaState) (viewportH : Float) : TextAreaState :=
  let maxScroll := max 0 (contentHeight state - viewportH)
  let clamped := min maxScroll (max 0 state.scrollOffsetY)
  { state with scrollOffsetY := clamped }

/-- Scroll vertically by a pixel delta while respecting content bounds. -/
def scrollBy (state : TextAreaState) (viewportH : Float) (dy : Float) : TextAreaState :=
  clampScrollOffset { state with scrollOffsetY := state.scrollOffsetY + dy } viewportH

private def logicalLineNumberAt (text : String) (idx : Nat) : Nat :=
  (lineColFromTextPrefix (text.take idx)).line

private def lineNumberSpec (state : TextAreaState) (theme : Theme)
    (config : TextEditorConfig) : CustomSpec := {
  measure := fun _ _ => (config.gutterWidth, viewportHeight config)
  collect := fun layout reg =>
    let rect := layout.contentRect
    let clipRect := Arbor.Rect.mk' rect.x rect.y rect.width rect.height
    let lines := state.renderState.wrappedLines
    let lineHeight := state.renderState.lineHeight
    let ascender := theme.font.ascender
    let cursorLine := (cursorLocation state).line
    let bgColor := theme.panel.backgroundHover.withAlpha 0.35
    do
      CanvasM.fillRectColor clipRect bgColor 0
      CanvasM.pushClip clipRect
      for i in [:lines.size] do
        match lines[i]? with
        | some line =>
            let logicalLine := logicalLineNumberAt state.value line.startIdx
            let lineY := rect.y + i.toFloat * lineHeight - state.scrollOffsetY
            if lineY + lineHeight >= rect.y && lineY < rect.y + rect.height then
              let isActive := logicalLine == cursorLine
              let color := if isActive then theme.text else theme.textMuted
              let textY := lineY + ascender
              CanvasM.fillTextId reg (toString logicalLine) (rect.x + 8) textY theme.smallFont color
        | none => pure ()
      CanvasM.popClip
}

private def modeLabel (mode : TextEditorMode) : String :=
  match mode with
  | .plain => "plain"
  | .rich => "rich"

/-- Text editor visual with optional line numbers and status bar. -/
def editorVisual (name : ComponentId) (theme : Theme) (state : TextAreaState)
    (cursor : TextEditorCursor) (placeholder : String) (config : TextEditorConfig) : WidgetBuilder := do
  let focusedBorder := if state.focused then theme.input.borderFocused else theme.panel.border
  let frameWidth : Trellis.Dimension := if config.fillWidth then .percent 1.0 else .length config.width
  let frameHeight : Trellis.Dimension := if config.fillHeight then .percent 1.0 else .length config.height
  let frameFlexItem :=
    if config.fillHeight then
      some (FlexItem.growing 1)
    else
      none
  let frameStyle : BoxStyle := {
    backgroundColor := some theme.panel.background
    borderColor := some focusedBorder
    borderWidth := if state.focused then 2 else 1
    cornerRadius := theme.cornerRadius
    width := frameWidth
    height := frameHeight
    flexItem := frameFlexItem
  }

  let contentStyle : BoxStyle := {
    flexItem := some (FlexItem.growing 1)
    padding := EdgeInsets.uniform config.padding
  }

  let viewportW := viewportWidth config
  let viewportH := viewportHeight config

  let showPlaceholder := state.value.isEmpty && !state.focused

  let textContent ← custom
    (TextArea.areaSpec state.renderState placeholder showPlaceholder
      state.scrollOffsetY state.focused theme viewportW viewportH)
    {
      width := .length viewportW
      flexItem := some (FlexItem.growing 1)
    }

  let lineNumberWidgets ←
    if config.showLineNumbers then do
      let gutter ← custom (lineNumberSpec state theme config) {
        width := .length config.gutterWidth
        minWidth := some config.gutterWidth
        maxWidth := some config.gutterWidth
      }
      pure #[gutter]
    else
      pure #[]

  let rowWid ← freshId
  let rowProps : FlexContainer := {
    direction := .row
    alignItems := .stretch
    justifyContent := .flexStart
  }
  let contentRow : Widget := Widget.flex rowWid none rowProps contentStyle (lineNumberWidgets.push textContent)

  let children ←
    if config.showStatusBar then do
      let statusStyle : BoxStyle := {
        padding := EdgeInsets.symmetric (config.padding * 0.75) 6
        backgroundColor := some (theme.panel.backgroundHover.withAlpha 0.25)
      }
      let statusText :=
        s!"Ln {cursor.line}, Col {cursor.column} | {logicalLineCount state.value} lines | {state.value.length} chars | {modeLabel config.mode}"
      let statusLabel ← text' statusText theme.smallFont theme.textMuted .left
      let statusWid ← freshId
      let statusProps : FlexContainer := {
        direction := .row
        alignItems := .center
      }
      let statusWidget : Widget := Widget.flex statusWid none statusProps statusStyle #[statusLabel]
      pure #[contentRow, statusWidget]
    else
      pure #[contentRow]

  let containerWid ← freshId
  let containerProps : FlexContainer := {
    direction := .column
    alignItems := .stretch
    justifyContent := .flexStart
  }
  pure (Widget.flexC containerWid name containerProps frameStyle children)

end TextEditor

/-- Result payload for TextEditor reactive component. -/
structure TextEditorResult where
  onChange : Reactive.Event Spider String
  onFocus : Reactive.Event Spider Unit
  onBlur : Reactive.Event Spider Unit
  text : Reactive.Dynamic Spider String
  document : Reactive.Dynamic Spider TextEditorDocument
  cursor : Reactive.Dynamic Spider TextEditorCursor
  lineCount : Reactive.Dynamic Spider Nat
  isFocused : Reactive.Dynamic Spider Bool

private inductive TextEditorInputEvent where
  | key (data : KeyData)
  | wheel (data : ScrollData)

/-- Reactive text editor component (plain text mode currently). -/
def textEditor (placeholder : String := "Start typing...")
    (initialText : String := "") (config : TextEditorConfig := {}) : WidgetM TextEditorResult := do
  let theme ← getThemeW
  let font ← getFontW
  let name ← registerComponentW (isInput := true)
  let events ← getEventsW
  let focusedInput := events.registry.focusedInput
  let fireFocusedInput := events.registry.fireFocus

  let clicks ← useClick name
  let keyEvents ← useKeyboard
  let scrollEvents ← useScroll name

  let isFocused ← Dynamic.mapM (· == some name) focusedInput

  let focusChanges ← Dynamic.changesM focusedInput
  let focusEvents ← Event.filterM
    (fun (old, new) => old != some name && new == some name) focusChanges
  let onFocus ← Event.voidM focusEvents
  let blurEvents ← Event.filterM
    (fun (old, new) => old == some name && new != some name) focusChanges
  let onBlur ← Event.voidM blurEvents

  let notFocused ← Dynamic.mapM (· != some name) focusedInput
  let focusClicks ← Event.gateM notFocused.current clicks
  let focusAction ← Event.mapM (fun _ => fireFocusedInput (some name)) focusClicks
  performEvent_ focusAction

  let viewportW := TextEditor.viewportWidth config
  let viewportH := TextEditor.viewportHeight config

  let rawInitialState : TextAreaState := {
    value := initialText
    cursor := initialText.length
    scrollOffsetY := 0
    targetColumn := none
  }
  let initialState ← SpiderM.liftIO do
    let rendered ← TextArea.computeRenderState font rawInitialState viewportW config.padding
    pure (TextEditor.clampScrollOffset (TextArea.scrollToCursor rendered viewportH) viewportH)

  let gatedKeys ← Event.gateM isFocused.current keyEvents
  let keyInputEvents ← Event.mapM TextEditorInputEvent.key gatedKeys
  let wheelInputEvents ← Event.mapM TextEditorInputEvent.wheel scrollEvents
  let allInputEvents ← Event.leftmostM [keyInputEvents, wheelInputEvents]
  let textState ← Reactive.foldDynM
    (fun input state => do
      match input with
      | .key keyData =>
          let updated := TextArea.handleKeyPress keyData.event state config.maxLen
          let rendered ← SpiderM.liftIO (TextArea.computeRenderState font updated viewportW config.padding)
          pure (TextEditor.clampScrollOffset (TextArea.scrollToCursor rendered viewportH) viewportH)
      | .wheel scrollData =>
          let dy := -scrollData.scroll.deltaY * config.scrollSpeed
          pure (TextEditor.scrollBy state viewportH dy))
    initialState allInputEvents

  let textChanges ← Dynamic.changesM textState
  let valueChanges ← Event.mapMaybeM
    (fun (old, new) => if old.value != new.value then some new.value else none)
    textChanges
  let onChange := valueChanges

  let text ← Dynamic.mapM (·.value) textState
  let document ← Dynamic.mapM (fun s => TextEditorDocument.fromPlainText s.value) textState
  let cursor ← Dynamic.mapM TextEditor.cursorLocation textState
  let lineCount ← Dynamic.mapM (fun s => TextEditor.logicalLineCount s.value) textState

  let renderState ← Dynamic.zipWithM (fun s f => (s, f)) textState focusedInput
  let _ ← dynWidget renderState fun (state, focused) => do
    let isFoc := focused == some name
    let focusedState := { state with focused := isFoc }
    let cursorLoc := TextEditor.cursorLocation focusedState
    emitM do pure (TextEditor.editorVisual name theme focusedState cursorLoc placeholder config)

  pure { onChange, onFocus, onBlur, text, document, cursor, lineCount, isFocused }

end Afferent.Canopy
