/-
  Lighthouse Transaction Log View
  View transaction history with time-travel
-/

import Terminus
import Ledger
import Lighthouse.State.AppState
import Lighthouse.UI.Layout

namespace Lighthouse.UI.Views.Transaction

open Terminus
open Ledger
open Lighthouse

/-- Format a datom for display -/
def formatDatom (d : Datom) : String :=
  let op := if d.added then "+" else "-"
  let valueStr := match d.value with
    | .ref eid => s!"-> {eid.id}"
    | .string s => s!"\"{s.take 30}\""
    | .int i => toString i
    | .float f => toString f
    | .bool b => toString b
    | .instant i => s!"instant({i})"
    | .keyword k => s!":{k}"
    | .bytes _ => "<bytes>"
  s!"{op} [{d.entity.id}] {d.attr.name} = {valueStr}"

/-- Draw the transaction log view -/
def draw (frame : Frame) (state : AppState) (area : Rect) : Frame := Id.run do
  let title := if state.txState.timeTravelActive
    then match state.selectedTxId with
      | some txId => s!"Transaction Log (viewing as of tx {txId.id})"
      | none => "Transaction Log (time-travel active)"
    else "Transaction Log"

  let block := Block.rounded
    |>.withTitle title
    |>.withBorderStyle Style.default

  let mut result := frame.render block area
  let inner := block.innerArea area

  if state.txState.txIds.isEmpty then
    result := result.writeString inner.x inner.y "(no transactions)" Style.dim
    return result

  -- Calculate visible range
  let mut row := inner.y
  let mut lineIdx := 0

  for hi : i in [0:state.txState.txIds.size] do
    if row >= inner.y + inner.height then break

    match state.txState.txIds[i]? with
    | some txId =>
      let isSelected := i == state.txState.selectedIdx
      let isExpanded := state.txState.expanded.getD i false

      -- Get transaction data
      let txData := state.conn.txData txId
      let datomCount := match txData with
        | some e => e.datoms.size
        | none => 0

      -- Draw transaction header
      let marker := if isSelected then "> " else "  "
      let expandIcon := if isExpanded then "▼ " else "▶ "
      let headerText := s!"{marker}{expandIcon}Tx {txId.id} | {datomCount} datoms"
      let headerStyle := if isSelected
        then Style.reversed.withFg Color.yellow
        else Style.default.withFg Color.yellow

      result := result.writeString inner.x row headerText headerStyle
      row := row + 1
      lineIdx := lineIdx + 1

      -- If expanded, show datoms
      if isExpanded then
        match txData with
        | some entry =>
          for d in entry.datoms do
            if row >= inner.y + inner.height then break
            let datomText := s!"    {formatDatom d}"
            let style := if d.added
              then Style.default.withFg Color.green
              else Style.default.withFg Color.red
            result := result.writeString inner.x row datomText style
            row := row + 1
            lineIdx := lineIdx + 1
        | none => pure ()
    | none => pure ()

  -- Show time-travel hint at bottom if not active
  if !state.txState.timeTravelActive && row < inner.y + inner.height then
    let hintY := inner.y + inner.height - 1
    let hint := "Press 't' to view database at selected transaction"
    result := result.writeString inner.x hintY hint Style.dim

  result

/-- Update transaction view state based on input -/
def update (state : AppState) (key : KeyEvent) : AppState :=
  match key.code with
  | .up | .char 'k' =>
    let newIdx := if state.txState.selectedIdx > 0
      then state.txState.selectedIdx - 1
      else 0
    { state with txState.selectedIdx := newIdx }
  | .down | .char 'j' =>
    let maxIdx := if state.txState.txIds.size > 0
      then state.txState.txIds.size - 1
      else 0
    let newIdx := min (state.txState.selectedIdx + 1) maxIdx
    { state with txState.selectedIdx := newIdx }
  | .enter | .space =>
    -- Toggle expand
    let idx := state.txState.selectedIdx
    if idx < state.txState.expanded.size then
      let newExpanded := state.txState.expanded.set! idx (!state.txState.expanded[idx]!)
      { state with txState.expanded := newExpanded }
    else
      state
  | .char 't' =>
    -- Toggle time-travel mode
    if state.txState.timeTravelActive then
      -- Return to current database
      { state with
          txState.timeTravelActive := false,
          db := state.conn.db,
          statusMessage := some "Returned to current database" }
    else
      -- Time-travel to selected transaction
      match state.selectedTxId with
      | some txId =>
        let dbAtTx := state.conn.asOf txId
        { state with
            txState.timeTravelActive := true,
            db := dbAtTx,
            statusMessage := some s!"Viewing database as of transaction {txId.id}" }
      | none => state
  | _ => state

end Lighthouse.UI.Views.Transaction
