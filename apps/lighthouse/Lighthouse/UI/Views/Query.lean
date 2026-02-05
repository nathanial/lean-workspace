/-
  Lighthouse Query Interface View
  Simple query interface for finding entities
-/

import Terminus
import Ledger
import Lighthouse.State.AppState
import Lighthouse.UI.Layout

namespace Lighthouse.UI.Views.Query

open Terminus
open Ledger
open Lighthouse

/-- Execute a simple query and return results -/
def executeQuery (db : Db) (queryText : String) : Except String (Array EntityId) := do
  let query := queryText.trim
  if query.isEmpty then
    return #[]

  -- Parse query format: ":attr" or ":attr=value"
  if !query.startsWith ":" then
    throw "Query must start with ':' (e.g., :user/name or :card/title=\"Hello\")"

  if query.contains '=' then
    -- Parse attr=value
    let parts := query.splitOn "="
    match parts with
    | [attrPart, valuePart] =>
      let attr := Attribute.mk attrPart
      -- Remove quotes from value if present
      let value := valuePart.replace "\"" "" |>.trim
      let results := db.findByAttrValue attr (Value.string value)
      return results.toArray
    | _ => throw "Invalid query format. Use :attr or :attr=\"value\""
  else
    -- Just attribute lookup
    let attr := Attribute.mk query
    let results := db.entitiesWithAttr attr
    return results.toArray

/-- Draw the query interface view -/
def draw (frame : Frame) (state : AppState) (area : Rect) : Frame := Id.run do
  let (inputArea, resultsArea) := UI.splitVertical area 5

  -- Top: Query input
  let inputBlock := Block.rounded
    |>.withTitle "Query"

  let mut result := frame.render inputBlock inputArea
  let inputInner := inputBlock.innerArea inputArea

  -- Show query input
  let queryText := state.queryState.inputBuffer
  let displayText := if queryText.isEmpty
    then "Enter query: :attr or :attr=\"value\""
    else queryText
  let textStyle := if queryText.isEmpty then Style.dim else Style.default
  result := result.writeString inputInner.x inputInner.y displayText textStyle

  -- Show cursor
  if state.inputMode == .query then
    let cursorX := inputInner.x + state.queryState.inputCursor
    result := result.writeString cursorX inputInner.y "_" Style.blink

  -- Show error if present
  match state.queryState.errorMessage with
  | some err =>
    let errStyle := Style.default.withFg Color.red
    result := result.writeString inputInner.x (inputInner.y + 1) s!"Error: {err}" errStyle
  | none => pure ()

  -- Bottom: Results
  let resultsBlock := Block.rounded
    |>.withTitle s!"Results ({state.queryState.results.size})"

  result := result.render resultsBlock resultsArea
  let resultsInner := resultsBlock.innerArea resultsArea

  if state.queryState.results.isEmpty then
    let hint := if state.queryState.inputBuffer.isEmpty
      then "Press '/' to start typing a query"
      else "No results found"
    result := result.writeString resultsInner.x resultsInner.y hint Style.dim
  else
    -- Show results
    let mut row := resultsInner.y
    for hi : i in [0:state.queryState.results.size] do
      if row >= resultsInner.y + resultsInner.height then break
      match state.queryState.results[i]? with
      | some eid =>
        let isSelected := i == state.queryState.selectedIdx
        let marker := if isSelected then "> " else "  "

        -- Get some attributes for preview
        let datoms := state.db.entity eid |>.filter (·.added) |>.take 3
        let attrs := datoms.map (·.attr.name) |> String.intercalate ", "
        let preview := if attrs.isEmpty then "" else s!" ({attrs}...)"

        let text := s!"{marker}Entity {eid.id}{preview}"
        let style := if isSelected
          then Style.reversed.withFg Color.cyan
          else Style.default
        result := result.writeString resultsInner.x row text style
        row := row + 1
      | none => pure ()

  result

/-- Update query view state based on input -/
def update (state : AppState) (key : KeyEvent) : AppState :=
  if state.inputMode == .query then
    -- Query input mode
    match key.code with
    | .escape =>
      { state with inputMode := .normal }
    | .enter =>
      -- Execute query
      let queryText := state.queryState.inputBuffer
      match executeQuery state.db queryText with
      | .ok results =>
        { state with
            inputMode := .normal,
            queryState.results := results,
            queryState.selectedIdx := 0,
            queryState.errorMessage := none }
      | .error err =>
        { state with
            inputMode := .normal,
            queryState.results := #[],
            queryState.errorMessage := some err }
    | .backspace =>
      if state.queryState.inputCursor > 0 then
        let before := state.queryState.inputBuffer.take (state.queryState.inputCursor - 1)
        let after := state.queryState.inputBuffer.drop state.queryState.inputCursor
        { state with
            queryState.inputBuffer := before ++ after,
            queryState.inputCursor := state.queryState.inputCursor - 1 }
      else state
    | .char c =>
      let before := state.queryState.inputBuffer.take state.queryState.inputCursor
      let after := state.queryState.inputBuffer.drop state.queryState.inputCursor
      { state with
          queryState.inputBuffer := before ++ String.singleton c ++ after,
          queryState.inputCursor := state.queryState.inputCursor + 1 }
    | .space =>
      let before := state.queryState.inputBuffer.take state.queryState.inputCursor
      let after := state.queryState.inputBuffer.drop state.queryState.inputCursor
      { state with
          queryState.inputBuffer := before ++ " " ++ after,
          queryState.inputCursor := state.queryState.inputCursor + 1 }
    | .left =>
      if state.queryState.inputCursor > 0 then
        { state with queryState.inputCursor := state.queryState.inputCursor - 1 }
      else state
    | .right =>
      if state.queryState.inputCursor < state.queryState.inputBuffer.length then
        { state with queryState.inputCursor := state.queryState.inputCursor + 1 }
      else state
    | _ => state
  else
    -- Normal mode - navigate results
    match key.code with
    | .char '/' =>
      -- Start query input
      { state with inputMode := .query }
    | .up | .char 'k' =>
      let newIdx := if state.queryState.selectedIdx > 0
        then state.queryState.selectedIdx - 1
        else 0
      { state with queryState.selectedIdx := newIdx }
    | .down | .char 'j' =>
      let maxIdx := if state.queryState.results.size > 0
        then state.queryState.results.size - 1
        else 0
      let newIdx := min (state.queryState.selectedIdx + 1) maxIdx
      { state with queryState.selectedIdx := newIdx }
    | .enter =>
      -- Jump to entity in Entity view
      match state.queryState.results[state.queryState.selectedIdx]? with
      | some targetEid =>
        match state.entityState.entities.toList.findIdx? (· == targetEid) with
        | some idx =>
          { state with
              view := .entity,
              entityState.selectedIdx := idx,
              paneFocus := .left }
        | none => state
      | none => state
    | _ => state

end Lighthouse.UI.Views.Query
