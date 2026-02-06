/-
  Lighthouse UI Draw
  Main rendering orchestration
-/

import Terminus
import Lighthouse.State.AppState
import Lighthouse.UI.Layout
import Lighthouse.UI.Views.Entity
import Lighthouse.UI.Views.Transaction
import Lighthouse.UI.Views.Attribute
import Lighthouse.UI.Views.Query

namespace Lighthouse.UI.Draw

open Terminus
open Lighthouse

/-- Get tab index from view -/
def viewToTabIndex (v : View) : Nat :=
  match v with
  | .entity => 0
  | .transaction => 1
  | .attribute => 2
  | .query => 3

/-- Draw the tab bar -/
def drawTabs (frame : Frame) (state : AppState) (area : Rect) : Frame := Id.run do
  if area.width == 0 || area.height == 0 then
    return frame

  let fillLine := String.ofList (List.replicate area.width ' ')
  let mut result := frame.writeString area.x area.y fillLine Style.default

  let selected := viewToTabIndex state.view
  let tab0 := if selected == 0 then "[1:Entities]" else " 1:Entities "
  let tab1 := if selected == 1 then "[2:Transactions]" else " 2:Transactions "
  let tab2 := if selected == 2 then "[3:Attributes]" else " 3:Attributes "
  let tab3 := if selected == 3 then "[4:Query]" else " 4:Query "
  let tabsLine := s!"{tab0} | {tab1} | {tab2} | {tab3}"

  result := result.writeString area.x area.y tabsLine (Style.default.withFg Color.cyan)
  result

/-- Draw the status bar -/
def drawStatus (frame : Frame) (state : AppState) (area : Rect) : Frame := Id.run do
  let bgStyle := Style.default.withBg Color.gray |>.withFg Color.white

  -- Fill background
  let fillLine := String.ofList (List.replicate area.width ' ')
  let mut result := frame.writeString area.x area.y fillLine bgStyle

  -- Left side: database info
  let leftInfo := s!" {state.dbPath} | {state.entityState.entities.size} entities"
  result := result.writeString area.x area.y leftInfo bgStyle

  -- Right side: help or status message
  let rightInfo := match state.statusMessage with
    | some msg => msg
    | none => match state.inputMode with
      | .query => "Esc:cancel Enter:search"
      | _ => "q:quit Tab:switch 1-4:views /:query"

  let rightX := area.x + area.width - rightInfo.length - 1
  result := result.writeString rightX area.y rightInfo bgStyle

  result

/-- Main draw function -/
def draw (frame : Frame) (state : AppState) : Frame := Id.run do
  let areas := layoutPanels frame.area

  -- Draw tabs at top
  let mut result := drawTabs frame state areas.tabs

  -- Draw main content based on current view
  result := match state.view with
    | .entity => Views.Entity.draw result state areas.main
    | .transaction => Views.Transaction.draw result state areas.main
    | .attribute => Views.Attribute.draw result state areas.main
    | .query => Views.Query.draw result state areas.main

  -- Draw status bar
  result := drawStatus result state areas.status

  result

end Lighthouse.UI.Draw
