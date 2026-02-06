/-
  Lighthouse Entity Browser View
  Browse entities and their attributes
-/

import Terminus
import Ledger
import Lighthouse.State.AppState
import Lighthouse.UI.Layout

namespace Lighthouse.UI.Views.Entity

open Terminus
open Ledger
open Lighthouse

/-- Get the border style based on focus -/
def borderStyle (focused : Bool) : Style :=
  if focused then Style.default.withFg Color.cyan else Style.default

/-- Format a value for display -/
def formatValue (v : Value) : String :=
  match v with
  | .ref eid => s!"-> Entity {eid.id}"
  | .string s => s!"\"{s}\""
  | .int i => toString i
  | .float f => toString f
  | .bool b => toString b
  | .instant i => s!"instant({i})"
  | .keyword k => s!":{k}"
  | .bytes _ => "<bytes>"

/-- Check if a value is a reference -/
def isRef (v : Value) : Bool :=
  match v with
  | .ref _ => true
  | _ => false

/-- Draw the entity browser view -/
def draw (frame : Frame) (state : AppState) (area : Rect) : Frame := Id.run do
  let (listArea, detailArea) := UI.splitHorizontal area 35

  -- Left pane: Entity list
  let mut result := UI.drawPanel frame listArea
    s!"Entities ({state.entityState.entities.size})"
    (state.paneFocus == .left)
  let listInner := UI.panelInner listArea

  -- Build entity list items
  let visibleHeight := listInner.height
  let startIdx := state.entityState.scrollOffset
  let endIdx := min (startIdx + visibleHeight) state.entityState.entities.size

  for i in [startIdx:endIdx] do
    let row := listInner.y + (i - startIdx)
    if row >= listInner.y + listInner.height then break

    match state.entityState.entities[i]? with
    | some eid =>
      let isSelected := i == state.entityState.selectedIdx
      let marker := if isSelected then "> " else "  "
      let text := s!"{marker}Entity {eid.id}"
      let style := if isSelected
        then Style.reversed.withFg Color.cyan
        else Style.default
      result := result.writeString listInner.x row text style
    | none => pure ()

  -- Right pane: Entity details
  result := UI.drawPanel result detailArea "Details" (state.paneFocus == .right)
  let detailInner := UI.panelInner detailArea

  -- Show selected entity's datoms
  match state.entityState.entities[state.entityState.selectedIdx]? with
  | some eid =>
    let datoms := state.db.entity eid
    -- Group by attribute for cleaner display
    let mut row := detailInner.y

    -- Show entity ID header
    let headerStyle := Style.bold.withFg Color.yellow
    result := result.writeString detailInner.x row s!"Entity {eid.id}" headerStyle
    row := row + 1

    if datoms.isEmpty then
      result := result.writeString detailInner.x row "(no attributes)" Style.dim
    else
      -- Show each datom
      for d in datoms do
        if row >= detailInner.y + detailInner.height then break
        if d.added then  -- Only show current assertions
          let attrStyle := Style.default.withFg Color.green
          let valueStyle := if isRef d.value
            then Style.default.withFg Color.cyan
            else Style.default
          let attrText := s!"{d.attr.name}: "
          let valueText := formatValue d.value

          result := result.writeString detailInner.x row attrText attrStyle
          result := result.writeString (detailInner.x + attrText.length) row valueText valueStyle
          row := row + 1
  | none =>
    result := result.writeString detailInner.x detailInner.y "(no entity selected)" Style.dim

  result

/-- Update entity view state based on input -/
def update (state : AppState) (key : KeyEvent) : AppState :=
  if state.paneFocus == .left then
    match key.code with
    | .up | .char 'k' =>
      let newIdx := if state.entityState.selectedIdx > 0
        then state.entityState.selectedIdx - 1
        else 0
      -- Adjust scroll if needed
      let newOffset := if newIdx < state.entityState.scrollOffset
        then newIdx
        else state.entityState.scrollOffset
      { state with
          entityState.selectedIdx := newIdx,
          entityState.scrollOffset := newOffset }
    | .down | .char 'j' =>
      let maxIdx := state.entityState.entities.size - 1
      let newIdx := min (state.entityState.selectedIdx + 1) maxIdx
      { state with entityState.selectedIdx := newIdx }
    | .enter | .right | .char 'l' =>
      { state with paneFocus := .right, entityState.datomIdx := 0 }
    | _ => state
  else  -- Right pane
    match key.code with
    | .left | .char 'h' | .escape =>
      { state with paneFocus := .left }
    | .up | .char 'k' =>
      let newIdx := if state.entityState.datomIdx > 0
        then state.entityState.datomIdx - 1
        else 0
      { state with entityState.datomIdx := newIdx }
    | .down | .char 'j' =>
      { state with entityState.datomIdx := state.entityState.datomIdx + 1 }
    | .enter =>
      -- Follow entity reference if selected datom is a ref
      match state.entityState.entities[state.entityState.selectedIdx]? with
      | some eid =>
        let datoms := state.db.entity eid |>.filter (·.added)
        match datoms[state.entityState.datomIdx]? with
        | some d =>
          match d.value with
          | .ref targetEid =>
            -- Find target entity in list
            match state.entityState.entities.toList.findIdx? (· == targetEid) with
            | some idx =>
              -- Push current entity to history
              let history := { state.entityState.history with
                stack := eid :: state.entityState.history.stack }
              { state with
                  entityState.selectedIdx := idx,
                  entityState.datomIdx := 0,
                  entityState.history := history,
                  paneFocus := .left }
            | none => state
          | _ => state
        | none => state
      | none => state
    | .char 'b' =>
      -- Go back in history
      match state.entityState.history.stack with
      | prevEid :: rest =>
        match state.entityState.entities.toList.findIdx? (· == prevEid) with
        | some idx =>
          { state with
              entityState.selectedIdx := idx,
              entityState.history.stack := rest,
              paneFocus := .left }
        | none => state
      | [] => state
    | _ => state

end Lighthouse.UI.Views.Entity
