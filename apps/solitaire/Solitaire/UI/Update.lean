/-
  Solitaire.UI.Update
  Input handling and state updates
-/
import Solitaire.Game
import Terminus

namespace Solitaire.UI

open Solitaire.Core
open Solitaire.Game
open Terminus

/-- Update context -/
structure UpdateContext where
  seed : UInt64
  deriving Repr, Inhabited

/-- Helper to create Fin 4 safely -/
def mkFin4 (n : Nat) : Fin 4 :=
  if h : n < 4 then ⟨n, h⟩ else ⟨0, by decide⟩

/-- Helper to create Fin 7 safely -/
def mkFin7 (n : Nat) : Fin 7 :=
  if h : n < 7 then ⟨n, h⟩ else ⟨0, by decide⟩

/-- Move cursor left -/
def moveCursorLeft (state : GameState) : GameState :=
  let newCursor := match state.cursor with
    | .stock => .stock
    | .waste => .stock
    | .foundation idx =>
      if idx.val == 0 then .waste
      else .foundation (mkFin4 (idx.val - 1))
    | .tableau idx cardIdx =>
      if idx.val == 0 then .tableau idx cardIdx
      else .tableau (mkFin7 (idx.val - 1)) 0
  { state with cursor := newCursor }

/-- Move cursor right -/
def moveCursorRight (state : GameState) : GameState :=
  let newCursor := match state.cursor with
    | .stock => .waste
    | .waste => .foundation ⟨0, by decide⟩
    | .foundation idx =>
      if idx.val >= 3 then .foundation idx
      else .foundation (mkFin4 (idx.val + 1))
    | .tableau idx cardIdx =>
      if idx.val >= 6 then .tableau idx cardIdx
      else .tableau (mkFin7 (idx.val + 1)) 0
  { state with cursor := newCursor }

/-- Move cursor up -/
def moveCursorUp (state : GameState) : GameState :=
  let newCursor := match state.cursor with
    | .stock => .stock
    | .waste => .waste
    | .foundation _ => .waste
    | .tableau idx cardIdx =>
      let faceUpCount := state.tableaux[idx.val]!.faceUpCount
      if cardIdx + 1 < faceUpCount then
        .tableau idx (cardIdx + 1)
      else
        if idx.val < 2 then .stock
        else if idx.val < 5 then .foundation (mkFin4 (idx.val - 2))
        else .foundation ⟨3, by decide⟩
  { state with cursor := newCursor }

/-- Move cursor down -/
def moveCursorDown (state : GameState) : GameState :=
  let newCursor := match state.cursor with
    | .stock => .tableau ⟨0, by decide⟩ 0
    | .waste => .tableau ⟨1, by decide⟩ 0
    | .foundation idx =>
      .tableau (mkFin7 (min (idx.val + 2) 6)) 0
    | .tableau idx cardIdx =>
      if cardIdx > 0 then .tableau idx (cardIdx - 1)
      else .tableau idx 0
  { state with cursor := newCursor }

/-- Handle draw from stock or reset -/
def handleDraw (state : GameState) : GameState :=
  if canDraw state then state.draw
  else if canResetStock state then state.resetStock
  else state

/-- Select cards at current cursor position -/
def selectAtCursor (state : GameState) : GameState :=
  match state.cursor with
  | .waste =>
    if state.waste.isEmpty then state
    else { state with selection := some { pile := .waste, cardCount := 1 } }
  | .tableau idx cardIdx =>
    let faceUpCount := state.tableaux[idx.val]!.faceUpCount
    if faceUpCount == 0 then state
    else
      let count := cardIdx + 1
      { state with selection := some { pile := .tableau idx, cardCount := count } }
  | .foundation idx =>
    if state.foundations[idx.val]!.isEmpty then state
    else { state with selection := some { pile := .foundation idx, cardCount := 1 } }
  | .stock => state

/-- Try to place selection at current cursor position -/
def placeSelection (state : GameState) (sel : Selection) : GameState :=
  let result := match sel.pile, state.cursor with
    | .waste, .tableau toIdx _ =>
      if canWasteToTableau state toIdx then some (state.wasteToTableau toIdx) else none
    | .waste, .foundation toIdx =>
      if canWasteToFoundation state toIdx then some (state.wasteToFoundation toIdx) else none
    | .tableau fromIdx, .tableau toIdx _ =>
      if canTableauToTableau state fromIdx toIdx sel.cardCount then
        some (state.tableauToTableau fromIdx toIdx sel.cardCount)
      else none
    | .tableau fromIdx, .foundation toIdx =>
      if sel.cardCount == 1 && canTableauToFoundation state fromIdx toIdx then
        some (state.tableauToFoundation fromIdx toIdx)
      else none
    | .foundation fromIdx, .tableau toIdx _ =>
      if canFoundationToTableau state fromIdx toIdx then
        some (state.foundationToTableau fromIdx toIdx)
      else none
    | _, _ => none

  match result with
  | some newState => { newState with selection := none }
  | none => { state with selection := none }

/-- Check if cursor is on same pile as selection -/
def isSamePile (sel : Selection) (cursor : CursorPos) : Bool :=
  match sel.pile, cursor with
  | .waste, .waste => true
  | .tableau i, .tableau j _ => i == j
  | .foundation i, .foundation j => i == j
  | _, _ => false

/-- Handle selection/placement (Enter/Space) -/
def handleSelect (state : GameState) : GameState :=
  if state.cursor == .stock then handleDraw state
  else
    match state.selection with
    | none => selectAtCursor state
    | some sel =>
      if isSamePile sel state.cursor then
        let autoResult := state.autoFoundation sel.pile
        if autoResult.moveCount > state.moveCount then
          { autoResult with selection := none }
        else
          { state with selection := none }
      else
        placeSelection state sel

/-- Process input and update game state. Returns (newState, shouldQuit) -/
def update (ctx : UpdateContext) (state : GameState) (event : Option Event) : GameState × Bool := Id.run do
  match event with
  | none => (state, false)
  | some (.key k) =>
    if k.code == .char 'q' || k.code == .char 'Q' || k.isCtrlC then
      return (state, true)
    if k.code == .char 'r' || k.code == .char 'R' then
      return (GameState.new ctx.seed, false)
    if k.code == .char 'u' || k.code == .char 'U' then
      return (state.undo, false)
    if k.code == .char 's' || k.code == .char 'S' then
      return (handleDraw state, false)
    if k.code == .escape then
      return ({ state with selection := none }, false)

    match k.code with
    | .up | .char 'w' | .char 'W' => (moveCursorUp state, false)
    | .down => (moveCursorDown state, false)
    | .left | .char 'a' | .char 'A' => (moveCursorLeft state, false)
    | .right | .char 'd' | .char 'D' => (moveCursorRight state, false)
    | .space | .enter => (handleSelect state, false)
    | _ => (state, false)

  | some (.resize _ _) => (state, false)
  | _ => (state, false)

end Solitaire.UI
