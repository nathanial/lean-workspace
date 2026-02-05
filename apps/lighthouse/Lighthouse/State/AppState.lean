/-
  Lighthouse State
  Main application state and per-view states
-/

import Terminus
import Ledger
import Lighthouse.Core.Types

namespace Lighthouse

open Terminus
open Ledger
open Ledger.Persist

/-- Navigation history for following entity references -/
structure NavHistory where
  stack : List EntityId := []
  deriving Repr, Inhabited

/-- State for Entity Browser view -/
structure EntityViewState where
  /-- All entity IDs in the database -/
  entities : Array EntityId := #[]
  /-- Currently selected entity index in list -/
  selectedIdx : Nat := 0
  /-- Scroll offset for entity list -/
  scrollOffset : Nat := 0
  /-- Selected datom index in detail pane -/
  datomIdx : Nat := 0
  /-- Navigation history for back navigation -/
  history : NavHistory := {}
  deriving Repr, Inhabited

/-- State for Transaction Log view -/
structure TxViewState where
  /-- All transaction IDs (most recent first) -/
  txIds : Array TxId := #[]
  /-- Currently selected transaction index -/
  selectedIdx : Nat := 0
  /-- Scroll offset for transaction list -/
  scrollOffset : Nat := 0
  /-- Expanded transactions (show datoms) -/
  expanded : Array Bool := #[]
  /-- Time-travel mode: view database at selected tx -/
  timeTravelActive : Bool := false
  deriving Repr, Inhabited

/-- State for Attribute Index view -/
structure AttrViewState where
  /-- All unique attributes in database -/
  attributes : Array Attribute := #[]
  /-- Currently selected attribute index -/
  selectedIdx : Nat := 0
  /-- Scroll offset for attribute list -/
  scrollOffset : Nat := 0
  /-- Entities with selected attribute (for right pane) -/
  matchingEntities : Array EntityId := #[]
  /-- Selected entity in right pane -/
  entityIdx : Nat := 0
  deriving Repr, Inhabited

/-- State for Query Interface view -/
structure QueryViewState where
  /-- Query input buffer -/
  inputBuffer : String := ""
  /-- Query input cursor position -/
  inputCursor : Nat := 0
  /-- Query results (entity IDs) -/
  results : Array EntityId := #[]
  /-- Selected result index -/
  selectedIdx : Nat := 0
  /-- Last error message -/
  errorMessage : Option String := none
  deriving Repr, Inhabited

/-- Main application state -/
structure AppState where
  -- Database
  /-- Persistent connection to ledger database -/
  conn : PersistentConnection
  /-- Current database snapshot (may be time-traveled) -/
  db : Db

  -- View state
  /-- Current active view -/
  view : View := default  -- entity
  /-- Focus within split-pane views -/
  paneFocus : PaneFocus := default  -- left
  /-- Input mode -/
  inputMode : InputMode := default  -- normal

  -- Per-view state
  entityState : EntityViewState := {}
  txState : TxViewState := {}
  attrState : AttrViewState := {}
  queryState : QueryViewState := {}

  -- Global state
  /-- Database file path (for display) -/
  dbPath : String := ""
  /-- Status message to display -/
  statusMessage : Option String := none

namespace AppState

/-- Get the currently selected entity ID in entity view -/
def selectedEntity (s : AppState) : Option EntityId :=
  s.entityState.entities[s.entityState.selectedIdx]?

/-- Get the currently selected transaction ID -/
def selectedTxId (s : AppState) : Option TxId :=
  s.txState.txIds[s.txState.selectedIdx]?

/-- Get the currently selected attribute -/
def selectedAttr (s : AppState) : Option Attribute :=
  s.attrState.attributes[s.attrState.selectedIdx]?

end AppState

end Lighthouse
