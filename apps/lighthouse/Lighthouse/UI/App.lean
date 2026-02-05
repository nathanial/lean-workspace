/-
  Lighthouse UI App
  Main application runner
-/

import Terminus
import Ledger
import Lighthouse.Core.Types
import Lighthouse.State.AppState
import Lighthouse.UI.Draw
import Lighthouse.UI.Update

namespace Lighthouse.UI

open Terminus
open Ledger
open Ledger.Persist
open Lighthouse

/-- Collect all unique entity IDs from the database -/
def collectEntities (db : Db) : Array EntityId :=
  let datoms := db.datoms
  let entityIds := datoms.map (·.entity)
  -- Remove duplicates while preserving order
  let seen := entityIds.foldl (init := (#[] : Array EntityId)) fun acc eid =>
    if acc.contains eid then acc else acc.push eid
  seen

/-- Collect all unique attributes from the database -/
def collectAttributes (db : Db) : Array Attribute :=
  let datoms := db.datoms
  let attrs := datoms.map (·.attr)
  -- Remove duplicates while preserving order
  let seen := attrs.foldl (init := (#[] : Array Attribute)) fun acc attr =>
    if acc.contains attr then acc else acc.push attr
  seen

/-- Initialize application state from database file -/
def initState (dbPath : String) : IO AppState := do
  IO.println s!"Loading database: {dbPath}"

  let conn ← PersistentConnection.create dbPath
  let db := conn.db

  -- Collect entities
  let entities := collectEntities db
  IO.println s!"Found {entities.size} entities"

  -- Collect attributes
  let attributes := collectAttributes db
  IO.println s!"Found {attributes.size} unique attributes"

  -- Collect transaction IDs (most recent first)
  let txIds := conn.allTxIds.reverse.toArray
  IO.println s!"Found {txIds.size} transactions"

  -- Initialize entity matching for attribute view
  let matchingEntities := match attributes[0]? with
    | some attr => db.entitiesWithAttr attr |>.toArray
    | none => #[]

  return {
    conn := conn
    db := db
    dbPath := dbPath
    entityState := {
      entities := entities
      selectedIdx := 0
      scrollOffset := 0
    }
    txState := {
      txIds := txIds
      selectedIdx := 0
      expanded := (List.replicate txIds.size false).toArray
    }
    attrState := {
      attributes := attributes
      selectedIdx := 0
      matchingEntities := matchingEntities
    }
    queryState := {}
  }

/-- Run the application -/
def run (dbPath : String) : IO Unit := do
  let initialState ← initState dbPath
  App.runApp initialState Draw.draw Update.update

end Lighthouse.UI
