/-
  Enchiridion Application State
  Main state structure for the application
-/

import Terminus
import Terminus.Reactive.Input
import Terminus.Reactive.TextArea
import Enchiridion.Core.Types
import Enchiridion.Model.Novel
import Enchiridion.Model.Project
import Enchiridion.State.Focus

namespace Enchiridion

open Terminus

abbrev TextInputState := Terminus.Reactive.TextInputState
abbrev TextAreaState := Terminus.Reactive.TextAreaState

def textInputFromString (value : String) : TextInputState :=
  { text := value, cursor := value.length }

def textAreaFromString (value : String) : TextAreaState :=
  Terminus.Reactive.TextAreaState.fromString value

def textAreaToString (value : TextAreaState) : String :=
  Terminus.Reactive.TextAreaState.getText value

def handleTextInputKey (input : TextInputState) (key : KeyEvent) : TextInputState :=
  match key.code with
  | .char c =>
    if c.val >= 32 then
      Terminus.Reactive.TextInputState.insertChar input c none
    else
      input
  | .space => Terminus.Reactive.TextInputState.insertChar input ' ' none
  | .backspace => Terminus.Reactive.TextInputState.backspace input
  | .delete => Terminus.Reactive.TextInputState.delete input
  | .left => Terminus.Reactive.TextInputState.moveLeft input
  | .right => Terminus.Reactive.TextInputState.moveRight input
  | .home => Terminus.Reactive.TextInputState.moveHome input
  | .end => Terminus.Reactive.TextInputState.moveEnd input
  | _ => input

def handleTextAreaKey (input : TextAreaState) (key : KeyEvent) : TextAreaState :=
  let updated := match key.code with
    | .char c =>
      if c.val >= 32 then
        Terminus.Reactive.TextAreaState.insertChar input c
      else
        input
    | .space => Terminus.Reactive.TextAreaState.insertChar input ' '
    | .enter => Terminus.Reactive.TextAreaState.insertNewline input
    | .tab => Terminus.Reactive.TextAreaState.insertTab input 2
    | .backspace => Terminus.Reactive.TextAreaState.backspace input
    | .delete => Terminus.Reactive.TextAreaState.delete input
    | .left => Terminus.Reactive.TextAreaState.moveLeft input
    | .right => Terminus.Reactive.TextAreaState.moveRight input
    | .up => Terminus.Reactive.TextAreaState.moveUp input
    | .down => Terminus.Reactive.TextAreaState.moveDown input
    | .home => Terminus.Reactive.TextAreaState.moveHome input
    | .end => Terminus.Reactive.TextAreaState.moveEnd input
    | .pageUp => Terminus.Reactive.TextAreaState.pageUp input 20
    | .pageDown => Terminus.Reactive.TextAreaState.pageDown input 20
    | _ => input
  Terminus.Reactive.TextAreaState.ensureCursorVisible updated 20

/-- AI writing action types -/
inductive AIWritingAction where
  | continue_    -- Continue writing from cursor (underscore to avoid keyword)
  | rewrite     -- Rewrite the current scene content
  | brainstorm  -- Generate ideas for what happens next
  | dialogue    -- Add dialogue
  | description -- Add a description
  deriving Repr, BEq, Inhabited

namespace AIWritingAction

def toString : AIWritingAction → String
  | .continue_ => "Continue"
  | .rewrite => "Rewrite"
  | .brainstorm => "Brainstorm"
  | .dialogue => "Dialogue"
  | .description => "Description"

instance : ToString AIWritingAction where
  toString := AIWritingAction.toString

/-- Get the prompt instruction for each action -/
def instruction : AIWritingAction → String
  | .continue_ => "Continue the story from where it left off, maintaining the same style and tone. Write 2-3 paragraphs."
  | .rewrite => "Rewrite the following scene content, improving the prose while keeping the same meaning and events. Return only the rewritten text."
  | .brainstorm => "Suggest 3-5 creative ideas for what could happen next in this scene. Be specific and consider the established characters and plot."
  | .dialogue => "Write a natural dialogue exchange for this scene. Include dialogue tags and brief action beats. Match the characters' voices."
  | .description => "Write a vivid sensory description for this scene. Engage sight, sound, smell, touch. Set the mood and atmosphere."

/-- Whether the result should be inserted into the editor -/
def shouldInsertIntoEditor : AIWritingAction → Bool
  | .continue_ => true
  | .rewrite => true
  | .dialogue => true
  | .description => true
  | .brainstorm => false  -- Ideas stay in chat

end AIWritingAction

/-- Chat message for AI conversation -/
structure ChatMessage where
  id : EntityId
  role : String  -- "user", "assistant", or "system"
  content : String
  timestamp : Timestamp
  isStreaming : Bool := false
  deriving Repr, Inhabited

namespace ChatMessage

def create (role : String) (content : String) : IO ChatMessage := do
  let id ← EntityId.generate
  let ts ← Timestamp.now
  return { id := id, role := role, content := content, timestamp := ts }

def isUser (msg : ChatMessage) : Bool := msg.role == "user"
def isAssistant (msg : ChatMessage) : Bool := msg.role == "assistant"
def isSystem (msg : ChatMessage) : Bool := msg.role == "system"

end ChatMessage

/-- Main application state -/
structure AppState where
  -- Data
  project : Project

  -- UI Focus
  focus : PanelFocus := .editor
  mode : AppMode := .normal

  -- Navigation panel state
  selectedChapterIdx : Nat := 0
  selectedSceneIdx : Nat := 0
  navCollapsed : Array Bool := #[]  -- Track collapsed state per chapter

  -- Editor panel state
  editorTextArea : TextAreaState := textAreaFromString ""
  currentChapterId : Option EntityId := none
  currentSceneId : Option EntityId := none

  -- Chat panel state
  chatMessages : Array ChatMessage := #[]
  chatInput : TextInputState := {}
  isStreaming : Bool := false
  streamBuffer : String := ""
  cancelStreaming : Bool := false  -- Set by Escape to cancel streaming

  -- Notes panel state
  notesTab : Nat := 0  -- 0 = Characters, 1 = World
  selectedCharacterIdx : Nat := 0
  selectedNoteIdx : Nat := 0
  notesEditMode : Bool := false  -- True when editing a character/note
  notesEditField : Nat := 0  -- 0 = name/title, 1 = description/content
  notesNameInput : TextInputState := {}
  notesContentArea : TextAreaState := textAreaFromString ""

  -- AI configuration
  openRouterApiKey : String := ""
  selectedModel : String := "anthropic/claude-3.5-sonnet"

  -- AI writing actions
  pendingAIWritingAction : Option AIWritingAction := none
  insertAIResponseIntoEditor : Bool := false  -- When true, completed AI response goes into editor

  -- Status
  statusMessage : Option String := none
  errorMessage : Option String := none

  -- Pending actions (to be executed in IO context)
  pendingNewChapter : Bool := false
  pendingNewScene : Bool := false
  pendingSave : Bool := false
  pendingExport : Bool := false  -- Export to markdown
  pendingAIMessage : Option String := none  -- User message to send to AI
  pendingNewCharacter : Bool := false
  pendingNewWorldNote : Bool := false

  -- Quit confirmation (for unsaved changes warning)
  quitConfirmPending : Bool := false

  deriving Inhabited

namespace AppState

/-- Create initial app state with empty project -/
def create : IO AppState := do
  let project ← Project.empty
  return { project := project }

/-- Create app state with a given project -/
def fromProject (project : Project) : AppState :=
  { project := project
    navCollapsed := project.novel.chapters.map (fun _ => false) }

/-- Switch focus to next panel -/
def nextFocus (state : AppState) : AppState :=
  if state.mode.allowsPanelSwitch then
    { state with focus := state.focus.next }
  else
    state

/-- Switch focus to previous panel -/
def prevFocus (state : AppState) : AppState :=
  if state.mode.allowsPanelSwitch then
    { state with focus := state.focus.prev }
  else
    state

/-- Set focus directly -/
def setFocus (state : AppState) (focus : PanelFocus) : AppState :=
  if state.mode.allowsPanelSwitch then
    { state with focus := focus }
  else
    state

/-- Set status message -/
def setStatus (state : AppState) (msg : String) : AppState :=
  { state with statusMessage := some msg }

/-- Clear status message -/
def clearStatus (state : AppState) : AppState :=
  { state with statusMessage := none }

/-- Set error message -/
def setError (state : AppState) (msg : String) : AppState :=
  { state with errorMessage := some msg }

/-- Clear error message -/
def clearError (state : AppState) : AppState :=
  { state with errorMessage := none }

/-- Get current scene content -/
def getCurrentSceneContent (state : AppState) : Option String := do
  let chapterId ← state.currentChapterId
  let sceneId ← state.currentSceneId
  let scene ← state.project.novel.getScene chapterId sceneId
  return scene.content

/-- Get current scene title -/
def getCurrentSceneTitle (state : AppState) : String :=
  match state.currentChapterId, state.currentSceneId with
  | some chapterId, some sceneId =>
    match state.project.novel.getScene chapterId sceneId with
    | some scene => scene.title
    | none => "No Scene"
  | _, _ => "No Scene Selected"

/-- Load scene into editor -/
def loadScene (state : AppState) (chapterId : EntityId) (sceneId : EntityId) : AppState :=
  match state.project.novel.getScene chapterId sceneId with
  | some scene =>
    let textArea := textAreaFromString scene.content
    -- Find the chapter and scene indices for navigation sync
    let novel := state.project.novel
    let chapterIdx := novel.chapters.findIdx? (·.id == chapterId) |>.getD state.selectedChapterIdx
    let sceneIdx := match novel.getChapter chapterId with
      | some chapter => chapter.scenes.findIdx? (·.id == sceneId) |>.getD state.selectedSceneIdx
      | none => state.selectedSceneIdx
    { state with
        currentChapterId := some chapterId
        currentSceneId := some sceneId
        editorTextArea := textArea
        selectedChapterIdx := chapterIdx
        selectedSceneIdx := sceneIdx }
  | none => state

/-- Save current editor content to scene -/
def saveCurrentScene (state : AppState) : AppState :=
  match state.currentChapterId, state.currentSceneId with
  | some chapterId, some sceneId =>
    let content := textAreaToString state.editorTextArea
    let project := state.project.updateNovel fun novel =>
      novel.updateScene chapterId sceneId fun scene =>
        { scene.updateWordCount with content := content }
    { state with project := project }
  | _, _ => state

/-- Add a chat message -/
def addChatMessage (state : AppState) (msg : ChatMessage) : AppState :=
  { state with chatMessages := state.chatMessages.push msg }

/-- Update the last chat message (for streaming) -/
def updateLastChatMessage (state : AppState) (content : String) : AppState :=
  if state.chatMessages.isEmpty then state
  else
    let lastIdx := state.chatMessages.size - 1
    let msgs := state.chatMessages.modify lastIdx fun msg =>
      { msg with content := content }
    { state with chatMessages := msgs }

/-- Add a new chapter to the novel -/
def addNewChapter (state : AppState) (chapter : Chapter) : AppState :=
  let project := state.project.updateNovel (·.addChapter chapter)
  let chapterIdx := project.novel.chapters.size - 1
  { state with
      project := project
      selectedChapterIdx := chapterIdx
      selectedSceneIdx := 0
      navCollapsed := state.navCollapsed.push false }

/-- Add a new scene to the current chapter -/
def addNewScene (state : AppState) (scene : Scene) : AppState :=
  let novel := state.project.novel
  if state.selectedChapterIdx < novel.chapters.size then
    let chapter := novel.chapters[state.selectedChapterIdx]!
    let project := state.project.updateNovel fun n =>
      n.updateChapter chapter.id (·.addScene scene)
    let sceneIdx := chapter.scenes.size  -- New scene will be at this index
    { state with
        project := project
        selectedSceneIdx := sceneIdx }
  else
    state

/-- Delete a chapter by index -/
def deleteChapter (state : AppState) (chapterIdx : Nat) : AppState :=
  let novel := state.project.novel
  if h : chapterIdx < novel.chapters.size then
    let chapters := novel.chapters.eraseIdx chapterIdx
    let project := { state.project with novel := { novel with chapters := chapters }, isDirty := true }
    let newSelectedIdx := if chapterIdx > 0 then chapterIdx - 1 else 0
    let newNavCollapsed := if h2 : chapterIdx < state.navCollapsed.size then
      state.navCollapsed.eraseIdx chapterIdx
    else
      state.navCollapsed
    { state with
        project := project
        selectedChapterIdx := newSelectedIdx
        selectedSceneIdx := 0
        navCollapsed := newNavCollapsed
        currentChapterId := none
        currentSceneId := none }
  else
    state

/-- Delete a scene from the current chapter -/
def deleteScene (state : AppState) (sceneIdx : Nat) : AppState :=
  let novel := state.project.novel
  if state.selectedChapterIdx < novel.chapters.size then
    let chapter := novel.chapters[state.selectedChapterIdx]!
    if h : sceneIdx < chapter.scenes.size then
      let scenes := chapter.scenes.eraseIdx sceneIdx
      let project := state.project.updateNovel fun n =>
        n.updateChapter chapter.id fun c => { c with scenes := scenes }
      let newSelectedIdx := if sceneIdx > 0 then sceneIdx - 1 else 0
      { state with
          project := project
          selectedSceneIdx := newSelectedIdx
          currentChapterId := none
          currentSceneId := none }
    else
      state
  else
    state

/-- Request creation of a new chapter (will be executed in IO context) -/
def requestNewChapter (state : AppState) : AppState :=
  { state with pendingNewChapter := true }

/-- Request creation of a new scene (will be executed in IO context) -/
def requestNewScene (state : AppState) : AppState :=
  { state with pendingNewScene := true }

/-- Request save (will be executed in IO context) -/
def requestSave (state : AppState) : AppState :=
  { state with pendingSave := true }

/-- Request AI message (will be executed in IO context) -/
def requestAIMessage (state : AppState) (message : String) : AppState :=
  { state with pendingAIMessage := some message }

/-- Request new character (will be executed in IO context) -/
def requestNewCharacter (state : AppState) : AppState :=
  { state with pendingNewCharacter := true }

/-- Request new world note (will be executed in IO context) -/
def requestNewWorldNote (state : AppState) : AppState :=
  { state with pendingNewWorldNote := true }

/-- Request export to markdown -/
def requestExport (state : AppState) : AppState :=
  { state with pendingExport := true }

/-- Clear pending actions -/
def clearPendingActions (state : AppState) : AppState :=
  { state with
      pendingNewChapter := false
      pendingNewScene := false
      pendingSave := false
      pendingExport := false
      pendingAIMessage := none
      pendingNewCharacter := false
      pendingNewWorldNote := false }

/-- Check if there are any pending actions -/
def hasPendingActions (state : AppState) : Bool :=
  state.pendingNewChapter || state.pendingNewScene || state.pendingSave ||
  state.pendingExport || state.pendingAIMessage.isSome ||
  state.pendingNewCharacter || state.pendingNewWorldNote

/-- Enter edit mode for the selected character -/
def editSelectedCharacter (state : AppState) : AppState :=
  if state.selectedCharacterIdx < state.project.characters.size then
    let char := state.project.characters[state.selectedCharacterIdx]!
    let nameInput := textInputFromString char.name
    let contentArea := textAreaFromString char.description
    { state with
        notesEditMode := true
        notesEditField := 0
        notesNameInput := nameInput
        notesContentArea := contentArea }
  else
    state

/-- Enter edit mode for the selected world note -/
def editSelectedWorldNote (state : AppState) : AppState :=
  if state.selectedNoteIdx < state.project.worldNotes.size then
    let note := state.project.worldNotes[state.selectedNoteIdx]!
    let nameInput := textInputFromString note.title
    let contentArea := textAreaFromString note.content
    { state with
        notesEditMode := true
        notesEditField := 0
        notesNameInput := nameInput
        notesContentArea := contentArea }
  else
    state

/-- Save edits to the selected character -/
def saveCharacterEdits (state : AppState) : AppState :=
  if state.selectedCharacterIdx < state.project.characters.size then
    let chars := state.project.characters.modify state.selectedCharacterIdx fun char =>
      { char with
          name := state.notesNameInput.text
          description := textAreaToString state.notesContentArea }
    let project := { state.project with characters := chars, isDirty := true }
    { state with
        project := project
        notesEditMode := false }
  else
    { state with notesEditMode := false }

/-- Save edits to the selected world note -/
def saveWorldNoteEdits (state : AppState) : AppState :=
  if state.selectedNoteIdx < state.project.worldNotes.size then
    let notes := state.project.worldNotes.modify state.selectedNoteIdx fun note =>
      { note with
          title := state.notesNameInput.text
          content := textAreaToString state.notesContentArea }
    let project := { state.project with worldNotes := notes, isDirty := true }
    { state with
        project := project
        notesEditMode := false }
  else
    { state with notesEditMode := false }

/-- Add a new character to the project -/
def addNewCharacter (state : AppState) (char : Character) : AppState :=
  let project := { state.project with
    characters := state.project.characters.push char
    isDirty := true }
  { state with
      project := project
      selectedCharacterIdx := project.characters.size - 1 }

/-- Add a new world note to the project -/
def addNewWorldNote (state : AppState) (note : WorldNote) : AppState :=
  let project := { state.project with
    worldNotes := state.project.worldNotes.push note
    isDirty := true }
  { state with
      project := project
      selectedNoteIdx := project.worldNotes.size - 1 }

/-- Delete the selected character -/
def deleteSelectedCharacter (state : AppState) : AppState :=
  if h : state.selectedCharacterIdx < state.project.characters.size then
    let chars := state.project.characters.eraseIdx state.selectedCharacterIdx
    let project := { state.project with characters := chars, isDirty := true }
    let newIdx := if state.selectedCharacterIdx > 0 then state.selectedCharacterIdx - 1 else 0
    { state with
        project := project
        selectedCharacterIdx := newIdx }
  else
    state

/-- Delete the selected world note -/
def deleteSelectedWorldNote (state : AppState) : AppState :=
  if h : state.selectedNoteIdx < state.project.worldNotes.size then
    let notes := state.project.worldNotes.eraseIdx state.selectedNoteIdx
    let project := { state.project with worldNotes := notes, isDirty := true }
    let newIdx := if state.selectedNoteIdx > 0 then state.selectedNoteIdx - 1 else 0
    { state with
        project := project
        selectedNoteIdx := newIdx }
  else
    state

/-- Request an AI writing action -/
def requestAIWritingAction (state : AppState) (action : AIWritingAction) : AppState :=
  { state with
      pendingAIWritingAction := some action
      insertAIResponseIntoEditor := action.shouldInsertIntoEditor }

/-- Get the prompt message for an AI writing action -/
def getAIWritingActionMessage (_state : AppState) (action : AIWritingAction) : String :=
  action.instruction

/-- Clear the pending AI writing action -/
def clearAIWritingAction (state : AppState) : AppState :=
  { state with pendingAIWritingAction := none }

/-- Insert text at the current cursor position in the editor -/
def insertTextAtCursor (state : AppState) (text : String) : AppState :=
  let textArea := state.editorTextArea
  -- Insert at cursor position by manipulating lines
  let currentLine := textArea.lines.getD textArea.line ""
  let before := currentLine.take textArea.column
  let after := currentLine.drop textArea.column
  -- Split the text into lines
  let newLines := text.splitOn "\n"
  match newLines with
  | [] => state
  | [single] =>
    -- Single line: insert inline
    let newLine := before ++ single ++ after
    let lines := textArea.lines.set! textArea.line newLine
    let newCursorCol := textArea.column + single.length
    { state with editorTextArea := { textArea with lines := lines, column := newCursorCol } }
  | first :: rest =>
    -- Multi-line: more complex insertion
    let firstLine := before ++ first
    let lastPart := rest.getLast?.getD ""
    let lastLine := lastPart ++ after
    let middleLines := rest.dropLast
    let beforeLines := textArea.lines.extract 0 textArea.line
    let afterLines := textArea.lines.extract (textArea.line + 1) textArea.lines.size
    let newLines := beforeLines.push firstLine
      |>.append middleLines.toArray
      |>.push lastLine
      |>.append afterLines
    let newCursorRow := textArea.line + rest.length
    let newCursorCol := lastPart.length
    { state with editorTextArea := { textArea with
        lines := newLines
        line := newCursorRow
        column := newCursorCol } }

/-- Append text to the end of the editor content -/
def appendTextToEditor (state : AppState) (text : String) : AppState :=
  let textArea := state.editorTextArea
  let currentText := textAreaToString textArea
  -- Add a separator if the current text doesn't end with newlines
  let separator := if currentText.isEmpty then ""
    else if currentText.endsWith "\n\n" then ""
    else if currentText.endsWith "\n" then "\n"
    else "\n\n"
  let newText := currentText ++ separator ++ text
  let newTextArea := textAreaFromString newText
  -- Move cursor to end
  let lastRow := newTextArea.lines.size - 1
  let lastCol := (newTextArea.lines.getD lastRow "").length
  { state with
      editorTextArea := { newTextArea with line := lastRow, column := lastCol }
      project := state.project.markDirty }

/-- Replace the entire editor content -/
def replaceEditorContent (state : AppState) (text : String) : AppState :=
  let newTextArea := textAreaFromString text
  { state with
      editorTextArea := newTextArea
      project := state.project.markDirty }

/-- Handle completed AI response - insert into editor if appropriate -/
def handleAIWritingResponse (state : AppState) (response : String) : AppState :=
  if state.insertAIResponseIntoEditor then
    match state.pendingAIWritingAction with
    | some .rewrite => state.replaceEditorContent response
    | some _ => state.appendTextToEditor response
    | none => state
  else
    state

/-- Toggle help mode -/
def toggleHelp (state : AppState) : AppState :=
  if state.mode == .help then
    { state with mode := .normal }
  else
    { state with mode := .help }

/-- Show help mode -/
def showHelp (state : AppState) : AppState :=
  { state with mode := .help }

/-- Hide help mode -/
def hideHelp (state : AppState) : AppState :=
  { state with mode := .normal }

/-- Get detailed word count statistics -/
def getWordCountStats (state : AppState) : String :=
  let novel := state.project.novel
  let totalWords := state.project.totalWordCount
  let chapterCount := novel.chapters.size
  let sceneCount := novel.chapters.foldl (fun acc ch => acc + ch.scenes.size) 0
  let charCount := state.project.characters.size
  let noteCount := state.project.worldNotes.size
  s!"{totalWords} words | {chapterCount} chapters | {sceneCount} scenes | {charCount} characters | {noteCount} notes"

/-- Export novel to markdown format -/
def exportToMarkdown (state : AppState) : String := Id.run do
  let novel := state.project.novel
  let mut md := s!"# {novel.title}\n\n"
  if !novel.author.isEmpty then
    md := md ++ s!"**Author:** {novel.author}\n\n"
  if !novel.genre.isEmpty then
    md := md ++ s!"**Genre:** {novel.genre}\n\n"
  if !novel.synopsis.isEmpty then
    md := md ++ s!"## Synopsis\n\n{novel.synopsis}\n\n"

  md := md ++ "---\n\n"

  for chapter in novel.chapters do
    md := md ++ s!"## {chapter.title}\n\n"
    if !chapter.synopsis.isEmpty then
      md := md ++ s!"*{chapter.synopsis}*\n\n"
    for scene in chapter.scenes do
      md := md ++ s!"### {scene.title}\n\n"
      if !scene.content.isEmpty then
        md := md ++ s!"{scene.content}\n\n"

  -- Add characters section if any
  if !state.project.characters.isEmpty then
    md := md ++ "---\n\n## Characters\n\n"
    for char in state.project.characters do
      md := md ++ s!"### {char.name}\n\n"
      if !char.description.isEmpty then
        md := md ++ s!"{char.description}\n\n"

  -- Add world notes section if any
  if !state.project.worldNotes.isEmpty then
    md := md ++ "---\n\n## World Notes\n\n"
    for note in state.project.worldNotes do
      md := md ++ s!"### {note.title}\n\n"
      md := md ++ s!"*Category: {note.category}*\n\n"
      if !note.content.isEmpty then
        md := md ++ s!"{note.content}\n\n"

  return md

end AppState

end Enchiridion
