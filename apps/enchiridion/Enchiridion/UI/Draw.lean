/-
  Enchiridion UI Draw
  Main rendering functions
-/

import Terminus
import Enchiridion.State.AppState
import Enchiridion.UI.Layout

namespace Enchiridion.UI

open Terminus

private structure BorderChars where
  topLeft : Char
  topRight : Char
  bottomLeft : Char
  bottomRight : Char
  horizontal : Char
  vertical : Char

private def roundedBorderChars : BorderChars := {
  topLeft := '╭'
  topRight := '╮'
  bottomLeft := '╰'
  bottomRight := '╯'
  horizontal := '─'
  vertical := '│'
}

private def singleBorderChars : BorderChars := {
  topLeft := '┌'
  topRight := '┐'
  bottomLeft := '└'
  bottomRight := '┘'
  horizontal := '─'
  vertical := '│'
}

private def spaces (n : Nat) : String :=
  String.ofList (List.replicate n ' ')

private def fitToWidth (s : String) (width : Nat) : String :=
  if width == 0 then ""
  else if s.length >= width then s.take width
  else s ++ spaces (width - s.length)

private def renderBox (frame : Frame) (area : Rect) (title : Option String)
    (borderStyle : Style) (chars : BorderChars) : Frame × Rect := Id.run do
  if area.width < 2 || area.height < 2 then
    return (frame, area)

  let mut result := frame
  let x0 := area.x
  let y0 := area.y
  let x1 := area.x + area.width - 1
  let y1 := area.y + area.height - 1

  result := result.writeString x0 y0 (String.singleton chars.topLeft) borderStyle
  result := result.writeString x1 y0 (String.singleton chars.topRight) borderStyle
  result := result.writeString x0 y1 (String.singleton chars.bottomLeft) borderStyle
  result := result.writeString x1 y1 (String.singleton chars.bottomRight) borderStyle

  for x in [x0 + 1:x1] do
    result := result.writeString x y0 (String.singleton chars.horizontal) borderStyle
    result := result.writeString x y1 (String.singleton chars.horizontal) borderStyle

  for y in [y0 + 1:y1] do
    result := result.writeString x0 y (String.singleton chars.vertical) borderStyle
    result := result.writeString x1 y (String.singleton chars.vertical) borderStyle

  match title with
  | some t =>
    if area.width > 2 then
      let label := s!" {t} "
      result := result.writeString (x0 + 1) y0 (label.take (area.width - 2)) borderStyle
  | none => pure ()

  return (result, area.inner 1)

private def writeSegments (frame : Frame) (x y width : Nat) (segments : List (String × Style)) : Frame := Id.run do
  let mut result := frame
  let mut col := x
  let maxCol := x + width
  for seg in segments do
    if col < maxCol then
      let text := seg.fst
      let style := seg.snd
      let chunk := text.take (maxCol - col)
      result := result.writeString col y chunk style
      col := col + chunk.length
  result

/-- Get border style based on focus -/
def borderStyle (focused : Bool) : Style :=
  if focused then
    Style.fgColor Color.yellow
  else
    Style.default

private def drawTextInput (frame : Frame) (area : Rect) (input : TextInputState)
    (focused : Bool) (placeholder : String := "") : Frame :=
  if area.width == 0 || area.height == 0 then
    frame
  else
    let text := input.text
    let displayText :=
      if focused then
        let col := min input.cursor text.length
        text.take col ++ "|" ++ text.drop col
      else if text.isEmpty then
        placeholder
      else
        text
    let style := if focused then Style.fgColor Color.cyan else Style.default
    let style := if !focused && text.isEmpty then Style.dim else style
    frame.writeString area.x area.y (fitToWidth displayText area.width) style

private def drawTextArea (frame : Frame) (area : Rect) (input : TextAreaState)
    (focused : Bool) (showLineNumbers : Bool := false) : Frame := Id.run do
  if area.width == 0 || area.height == 0 then
    return frame

  let mut result := frame
  let lines := if input.lines.isEmpty then #[""] else input.lines
  let numberWidth := if showLineNumbers then s!"{lines.size}".length + 1 else 0
  let textWidth := area.width - min area.width numberWidth

  let visibleLines := area.height
  let startLine :=
    if visibleLines == 0 then
      0
    else if input.line < input.scrollOffset then
      input.line
    else if input.line >= input.scrollOffset + visibleLines then
      input.line - visibleLines + 1
    else
      input.scrollOffset

  for row in [:area.height] do
    let y := area.y + row
    let lineIdx := startLine + row

    if numberWidth > 0 then
      let lineNo := if lineIdx < lines.size then s!"{lineIdx + 1}" else ""
      result := result.writeString area.x y (fitToWidth lineNo numberWidth) (Style.fgColor Color.gray)

    if textWidth > 0 then
      let x := area.x + numberWidth
      let sourceLine := lines.getD lineIdx ""
      let renderedLine :=
        if focused && lineIdx == input.line then
          let col := min input.column sourceLine.length
          sourceLine.take col ++ "|" ++ sourceLine.drop col
        else
          sourceLine
      result := result.writeString x y (fitToWidth renderedLine textWidth) Style.default

  return result

/-- Draw the navigation panel (chapter/scene tree) -/
def drawNavigation (frame : Frame) (state : AppState) (area : Rect) (focused : Bool) : Frame := Id.run do
  let (result, inner) := renderBox frame area (some "Chapters") (borderStyle focused) roundedBorderChars
  if inner.width == 0 || inner.height == 0 then
    return result

  let novel := state.project.novel
  let lines := Id.run do
    let mut items : Array (String × Style) := #[]
    let mut chapterIdx := 0
    for chapter in novel.chapters do
      let isSelectedChapter := chapterIdx == state.selectedChapterIdx
      let chapterStyle := if isSelectedChapter && focused then
        Style.default.withBg Color.blue |>.withFg Color.white
      else
        Style.default
      let pfx := if state.navCollapsed.getD chapterIdx false then "▸ " else "▾ "
      items := items.push (s!"{pfx}{chapter.title}", chapterStyle)

      if !(state.navCollapsed.getD chapterIdx false) then
        let mut sceneIdx := 0
        for scene in chapter.scenes do
          let isSelectedScene := isSelectedChapter && sceneIdx == state.selectedSceneIdx
          let sceneStyle := if isSelectedScene && focused then
            Style.default.withBg Color.blue |>.withFg Color.white
          else
            Style.fgColor Color.gray
          items := items.push (s!"  └ {scene.title}", sceneStyle)
          sceneIdx := sceneIdx + 1
      chapterIdx := chapterIdx + 1
    items

  let mut result := result
  for row in [:inner.height] do
    let y := inner.y + row
    let line := lines.getD row ("", Style.default)
    result := result.writeString inner.x y (fitToWidth line.fst inner.width) line.snd
  return result

/-- Draw the editor panel -/
def drawEditor (frame : Frame) (state : AppState) (area : Rect) (focused : Bool) : Frame := Id.run do
  let title := s!"Editor - {state.getCurrentSceneTitle}"
  let (result, inner) := renderBox frame area (some title) (borderStyle focused) roundedBorderChars
  drawTextArea result inner state.editorTextArea focused (showLineNumbers := true)

private def formatChatMessage (msg : ChatMessage) : List (String × Style) :=
  let roleStyle := if msg.isUser then
    Style.fgColor Color.cyan |>.withModifier Modifier.mkBold
  else if msg.isAssistant then
    Style.fgColor Color.green |>.withModifier Modifier.mkBold
  else
    Style.fgColor Color.gray
  let roleName := if msg.isUser then "[You]" else if msg.isAssistant then "[AI]" else "[System]"
  let contentLines := msg.content.splitOn "\n" |>.map (fun line => (line, Style.default))
  (roleName, roleStyle) :: contentLines ++ [("", Style.default)]

/-- Draw the chat panel -/
def drawChat (frame : Frame) (state : AppState) (area : Rect) (focused : Bool) : Frame := Id.run do
  let title := if state.isStreaming then "AI Chat (streaming...)" else "AI Chat"
  let (result, inner) := renderBox frame area (some title) (borderStyle focused) roundedBorderChars

  let sections := vsplit inner [.fill, .fixed 3]
  let messagesArea := sections[0]!
  let inputArea := sections[1]!

  let baseLines := (state.chatMessages.toList.map formatChatMessage)
    |>.foldl (fun acc lines => acc ++ lines) []
  let allLines := if state.isStreaming && !state.streamBuffer.isEmpty then
    baseLines ++ [("[AI]", Style.fgColor Color.green |>.withModifier Modifier.mkBold)] ++
      (state.streamBuffer.splitOn "\n" |>.map (fun line => (line, Style.default)))
  else
    baseLines

  let visibleStart := if allLines.length > messagesArea.height then allLines.length - messagesArea.height else 0
  let visibleLines := allLines.drop visibleStart

  let mut result := result
  let mut row := 0
  for line in visibleLines do
    if row < messagesArea.height then
      result := result.writeString messagesArea.x (messagesArea.y + row)
        (fitToWidth line.fst messagesArea.width) line.snd
      row := row + 1

  let (result', inputInner) := renderBox result inputArea (some "Message")
    (borderStyle (focused && !state.isStreaming)) singleBorderChars
  return drawTextInput result' inputInner state.chatInput (focused && !state.isStreaming)

/-- Draw notes panel in list mode -/
def drawNotesListMode (frame : Frame) (state : AppState) (inner : Rect) (focused : Bool) : Frame := Id.run do
  let charStyle := if state.notesTab == 0 then Style.bold else Style.default
  let worldStyle := if state.notesTab == 1 then Style.bold else Style.default
  let tabSegments := [("[Characters]", charStyle), (" ", Style.default), ("[World]", worldStyle)]
  let mut result := writeSegments frame inner.x inner.y inner.width tabSegments

  let listArea := { inner with y := inner.y + 1, height := inner.height - 1 }
  let items := if state.notesTab == 0 then
    state.project.characters.map (·.name)
  else
    state.project.worldNotes.map (·.displayTitle)

  if items.isEmpty then
    let emptyMsg := if state.notesTab == 0 then "No characters (n=new)" else "No notes (n=new)"
    result := result.writeString listArea.x listArea.y (fitToWidth emptyMsg listArea.width) (Style.fgColor Color.gray)
    return result

  let selectedIdx := if state.notesTab == 0 then state.selectedCharacterIdx else state.selectedNoteIdx
  for row in [:listArea.height] do
    let text := items.getD row ""
    let style := if row == selectedIdx && focused then
      Style.default.withBg Color.blue |>.withFg Color.white
    else
      Style.default
    result := result.writeString listArea.x (listArea.y + row) (fitToWidth text listArea.width) style

  return result

/-- Draw notes panel in edit mode -/
def drawNotesEditMode (frame : Frame) (state : AppState) (inner : Rect) (focused : Bool) : Frame := Id.run do
  let typeLabel := if state.notesTab == 0 then "Character" else "World Note"
  let sections := vsplit inner [.fixed 1, .fixed 3, .fill]
  let headerArea := sections[0]!
  let nameArea := sections[1]!
  let contentArea := sections[2]!

  let headerText := s!"{typeLabel} - Tab: switch field | Ctrl+S: save | Esc: cancel"
  let mut result := frame.writeString headerArea.x headerArea.y
    (fitToWidth headerText headerArea.width) (Style.fgColor Color.cyan)

  let (result', nameInner) := renderBox result nameArea (some "Name")
    (borderStyle (focused && state.notesEditField == 0)) singleBorderChars
  result := drawTextInput result' nameInner state.notesNameInput (focused && state.notesEditField == 0)

  let (result'', contentInner) := renderBox result contentArea (some "Description")
    (borderStyle (focused && state.notesEditField == 1)) singleBorderChars
  drawTextArea result'' contentInner state.notesContentArea (focused && state.notesEditField == 1)

/-- Draw the notes panel -/
def drawNotes (frame : Frame) (state : AppState) (area : Rect) (focused : Bool) : Frame := Id.run do
  let title := if state.notesEditMode then
    if state.notesTab == 0 then "Edit Character" else "Edit Note"
  else
    "Notes"

  let (result, inner) := renderBox frame area (some title) (borderStyle focused) roundedBorderChars
  if state.notesEditMode then
    drawNotesEditMode result state inner focused
  else
    drawNotesListMode result state inner focused

/-- Draw the status bar -/
def drawStatus (frame : Frame) (state : AppState) (area : Rect) : Frame :=
  match state.errorMessage with
  | some err =>
    let errStyle := Style.default.withBg Color.red |>.withFg Color.white
    let fillLine := spaces area.width
    let frame := frame.writeString area.x area.y fillLine errStyle
    let errMsg := s!" Error: {err.take (area.width - 10)}"
    frame.writeString area.x area.y errMsg errStyle
  | none =>
    match state.statusMessage with
    | some status =>
      let statusStyle := Style.default.withBg Color.blue |>.withFg Color.white
      let fillLine := spaces area.width
      let frame := frame.writeString area.x area.y fillLine statusStyle
      let statusMsg := s!" {status.take (area.width - 4)}"
      frame.writeString area.x area.y statusMsg statusStyle
    | none =>
      let novel := state.project.novel
      let wordCount := state.project.totalWordCount
      let sceneInfo := state.getCurrentSceneTitle
      let dirtyIndicator := if state.project.isDirty then " [*]" else ""
      let leftInfo := s!" {novel.title}{dirtyIndicator} | {sceneInfo}"
      let rightInfo := s!"Words: {wordCount} | {state.focus} "
      let bgStyle := Style.default.withBg Color.gray |>.withFg Color.white
      let fillLine := spaces area.width
      let frame := frame.writeString area.x area.y fillLine bgStyle
      let frame := frame.writeString area.x area.y leftInfo bgStyle
      let rightX := if area.width > rightInfo.length then area.x + area.width - rightInfo.length else area.x
      frame.writeString rightX area.y rightInfo bgStyle

/-- Draw the help overlay -/
def drawHelp (frame : Frame) (area : Rect) : Frame := Id.run do
  let popupWidth := Nat.min 60 (area.width - 4)
  let popupHeight := Nat.min 28 (area.height - 4)
  let popupX := area.x + (area.width - popupWidth) / 2
  let popupY := area.y + (area.height - popupHeight) / 2
  let popupArea : Rect := { x := popupX, y := popupY, width := popupWidth, height := popupHeight }

  let dimStyle := Style.dim
  let dimRow := spaces area.width
  let mut result := frame
  for row in [:area.height] do
    result := result.writeString area.x (area.y + row) dimRow dimStyle

  let (result', inner) := renderBox result popupArea (some "Keyboard Shortcuts (? to close)")
    (Style.fgColor Color.cyan) roundedBorderChars
  result := result'

  let shortcuts : List (String × String) := [
    ("General", ""),
    ("  Tab / Shift+Tab", "Switch panels"),
    ("  Ctrl+S", "Save project"),
    ("  Ctrl+E", "Export to markdown"),
    ("  Ctrl+Q", "Quit (with confirmation)"),
    ("  ?", "Show/hide this help"),
    ("", ""),
    ("Navigation Panel", ""),
    ("  Up/Down", "Navigate chapters/scenes"),
    ("  Enter", "Load selected scene"),
    ("  Space", "Toggle chapter collapse"),
    ("  Ctrl+N", "New chapter"),
    ("  Ctrl+Shift+N", "New scene"),
    ("  Delete", "Delete chapter/scene"),
    ("", ""),
    ("Editor Panel (AI Writing)", ""),
    ("  Ctrl+Enter", "Continue writing"),
    ("  Ctrl+R", "Rewrite scene"),
    ("  Ctrl+B", "Brainstorm ideas"),
    ("  Ctrl+D", "Add dialogue"),
    ("  Ctrl+G", "Add description"),
    ("", ""),
    ("Notes Panel", ""),
    ("  Left/Right", "Switch tabs"),
    ("  n", "New character/note"),
    ("  Enter", "Edit selected"),
    ("  Tab", "Switch fields (edit mode)"),
    ("  Escape", "Cancel editing")
  ]

  let mut y := inner.y
  for line in shortcuts do
    if y < inner.y + inner.height then
      let key := line.fst
      let desc := line.snd
      if desc.isEmpty then
        result := result.writeString inner.x y (fitToWidth key inner.width) (Style.bold.withFg Color.yellow)
      else
        result := result.writeString inner.x y key (Style.fgColor Color.cyan)
        result := result.writeString (inner.x + 22) y (fitToWidth desc (inner.width - 22)) Style.default
    y := y + 1

  return result

/-- Main draw function -/
def draw (frame : Frame) (state : AppState) : Frame :=
  let areas := layoutPanels frame.area
  let frame := drawNavigation frame state areas.navigation (state.focus == .navigation)
  let frame := drawEditor frame state areas.editor (state.focus == .editor)
  let frame := drawChat frame state areas.chat (state.focus == .chat)
  let frame := drawNotes frame state areas.notes (state.focus == .notes)
  let frame := drawStatus frame state areas.status
  if state.mode == .help then
    drawHelp frame frame.area
  else
    frame

end Enchiridion.UI
