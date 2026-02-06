/-
  Lighthouse Attribute Index View
  Browse by attribute
-/

import Terminus
import Ledger
import Lighthouse.State.AppState
import Lighthouse.UI.Layout

namespace Lighthouse.UI.Views.Attribute

open Terminus
open Ledger
open Lighthouse

/-- Get the border style based on focus -/
def borderStyle (focused : Bool) : Style :=
  if focused then Style.default.withFg Color.cyan else Style.default

/-- Format a value for display -/
def formatValue (v : Value) : String :=
  match v with
  | .ref eid => s!"-> {eid.id}"
  | .string s => s!"\"{s.take 40}\""
  | .int i => toString i
  | .float f => toString f
  | .bool b => toString b
  | .instant i => s!"instant({i})"
  | .keyword k => s!":{k}"
  | .bytes _ => "<bytes>"

/-- Draw the attribute index view -/
def draw (frame : Frame) (state : AppState) (area : Rect) : Frame := Id.run do
  let (listArea, detailArea) := UI.splitHorizontal area 40

  -- Left pane: Attribute list
  let mut result := UI.drawPanel frame listArea
    s!"Attributes ({state.attrState.attributes.size})"
    (state.paneFocus == .left)
  let listInner := UI.panelInner listArea

  -- Show attributes with entity counts
  let visibleHeight := listInner.height
  let startIdx := state.attrState.scrollOffset
  let endIdx := min (startIdx + visibleHeight) state.attrState.attributes.size

  for i in [startIdx:endIdx] do
    let row := listInner.y + (i - startIdx)
    if row >= listInner.y + listInner.height then break

    match state.attrState.attributes[i]? with
    | some attr =>
      let count := state.db.entitiesWithAttr attr |>.length
      let isSelected := i == state.attrState.selectedIdx
      let marker := if isSelected then "> " else "  "
      let text := s!"{marker}{attr.name} ({count})"
      let style := if isSelected
        then Style.reversed.withFg Color.cyan
        else Style.default
      result := result.writeString listInner.x row text style
    | none => pure ()

  -- Right pane: Entities with this attribute
  result := UI.drawPanel result detailArea "Values" (state.paneFocus == .right)
  let detailInner := UI.panelInner detailArea

  -- Show entities with selected attribute and their values
  match state.attrState.attributes[state.attrState.selectedIdx]? with
  | some attr =>
    let entities := state.attrState.matchingEntities
    if entities.isEmpty then
      result := result.writeString detailInner.x detailInner.y "(no entities)" Style.dim
    else
      let mut row := detailInner.y
      for i in [0:entities.size] do
        if row >= detailInner.y + detailInner.height then break
        match entities[i]? with
        | some eid =>
          let values := state.db.get eid attr
          let valueStr := match values.head? with
            | some v => formatValue v
            | none => "(no value)"

          let isSelected := i == state.attrState.entityIdx && state.paneFocus == .right
          let marker := if isSelected then "> " else "  "
          let text := s!"{marker}Entity {eid.id}: {valueStr}"
          let style := if isSelected
            then Style.reversed.withFg Color.cyan
            else Style.default
          result := result.writeString detailInner.x row text style
          row := row + 1
        | none => pure ()
  | none =>
    result := result.writeString detailInner.x detailInner.y "(no attribute selected)" Style.dim

  result

/-- Refresh matching entities when attribute selection changes -/
def refreshMatchingEntities (state : AppState) : AppState :=
  match state.attrState.attributes[state.attrState.selectedIdx]? with
  | some attr =>
    let entities := state.db.entitiesWithAttr attr
    { state with
        attrState.matchingEntities := entities.toArray,
        attrState.entityIdx := 0 }
  | none => state

/-- Update attribute view state based on input -/
def update (state : AppState) (key : KeyEvent) : AppState :=
  if state.paneFocus == .left then
    match key.code with
    | .up | .char 'k' =>
      let newIdx := if state.attrState.selectedIdx > 0
        then state.attrState.selectedIdx - 1
        else 0
      -- Adjust scroll if needed
      let newOffset := if newIdx < state.attrState.scrollOffset
        then newIdx
        else state.attrState.scrollOffset
      let state := { state with
          attrState.selectedIdx := newIdx,
          attrState.scrollOffset := newOffset }
      refreshMatchingEntities state
    | .down | .char 'j' =>
      let maxIdx := if state.attrState.attributes.size > 0
        then state.attrState.attributes.size - 1
        else 0
      let newIdx := min (state.attrState.selectedIdx + 1) maxIdx
      let state := { state with attrState.selectedIdx := newIdx }
      refreshMatchingEntities state
    | .enter | .right | .char 'l' =>
      { state with paneFocus := .right, attrState.entityIdx := 0 }
    | _ => state
  else  -- Right pane
    match key.code with
    | .left | .char 'h' | .escape =>
      { state with paneFocus := .left }
    | .up | .char 'k' =>
      let newIdx := if state.attrState.entityIdx > 0
        then state.attrState.entityIdx - 1
        else 0
      { state with attrState.entityIdx := newIdx }
    | .down | .char 'j' =>
      let maxIdx := if state.attrState.matchingEntities.size > 0
        then state.attrState.matchingEntities.size - 1
        else 0
      let newIdx := min (state.attrState.entityIdx + 1) maxIdx
      { state with attrState.entityIdx := newIdx }
    | .enter =>
      -- Jump to entity in Entity view
      match state.attrState.matchingEntities[state.attrState.entityIdx]? with
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

end Lighthouse.UI.Views.Attribute
