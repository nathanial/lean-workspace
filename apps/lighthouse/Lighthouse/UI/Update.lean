/-
  Lighthouse UI Update
  Input handling and state updates
-/

import Terminus
import Lighthouse.State.AppState
import Lighthouse.UI.Views.Entity
import Lighthouse.UI.Views.Transaction
import Lighthouse.UI.Views.Attribute
import Lighthouse.UI.Views.Query

namespace Lighthouse.UI.Update

open Terminus
open Lighthouse

/-- Get the next view in cycle -/
def nextView (v : View) : View :=
  match v with
  | .entity => .transaction
  | .transaction => .attribute
  | .attribute => .query
  | .query => .entity

/-- Get the previous view in cycle -/
def prevView (v : View) : View :=
  match v with
  | .entity => .query
  | .transaction => .entity
  | .attribute => .transaction
  | .query => .attribute

/-- Handle global key events that apply across all views -/
def handleGlobalKeys (state : AppState) (key : KeyEvent) : Option (AppState × Bool) :=
  -- If in query input mode, don't handle global keys (except quit)
  if state.inputMode == .query then
    if key.code == .char 'q' && key.modifiers.ctrl then
      some (state, true)  -- Ctrl+Q quits even in input mode
    else
      none  -- Let view handle it
  else
    match key.code with
    -- Quit
    | .char 'q' => some (state, true)

    -- View switching with number keys
    | .char '1' =>
      some ({ state with view := .entity, paneFocus := .left }, false)
    | .char '2' =>
      some ({ state with view := .transaction, paneFocus := .left }, false)
    | .char '3' =>
      let state := { state with view := .attribute, paneFocus := .left }
      some (Views.Attribute.refreshMatchingEntities state, false)
    | .char '4' =>
      some ({ state with view := .query, paneFocus := .left }, false)

    -- Tab to cycle views
    | .tab =>
      if key.modifiers.shift then
        let newView := prevView state.view
        let state := { state with view := newView, paneFocus := .left }
        let state := if newView == .attribute
          then Views.Attribute.refreshMatchingEntities state
          else state
        some (state, false)
      else
        let newView := nextView state.view
        let state := { state with view := newView, paneFocus := .left }
        let state := if newView == .attribute
          then Views.Attribute.refreshMatchingEntities state
          else state
        some (state, false)

    | _ => none

/-- Main update function -/
def update (state : AppState) (event : Option Event) : AppState × Bool :=
  match event with
  | none => (state, false)  -- No input this frame
  | some (.key key) =>
    -- Try global keys first
    match handleGlobalKeys state key with
    | some result => result
    | none =>
      -- Delegate to view-specific handler
      let newState := match state.view with
        | .entity => Views.Entity.update state key
        | .transaction => Views.Transaction.update state key
        | .attribute => Views.Attribute.update state key
        | .query => Views.Query.update state key
      (newState, false)
  | _ => (state, false)  -- Ignore mouse/resize events for now

end Lighthouse.UI.Update
