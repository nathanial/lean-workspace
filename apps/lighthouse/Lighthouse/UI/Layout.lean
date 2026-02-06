/-
  Lighthouse UI Layout
  Panel area calculations
-/

import Terminus

namespace Lighthouse.UI

open Terminus

/-- Draw a simple bordered panel with optional title. -/
def drawPanel (frame : Frame) (area : Rect) (title : String) (focused : Bool := false) : Frame := Id.run do
  if area.width == 0 || area.height == 0 then
    return frame

  let borderStyle :=
    if focused then Style.default.withFg Color.cyan else Style.default

  if area.width < 2 || area.height < 2 then
    return frame.writeString area.x area.y (title.take area.width) borderStyle

  let horizontal := String.ofList (List.replicate (area.width - 2) '-')
  let topBottom := s!"+{horizontal}+"

  let mut result := frame.writeString area.x area.y topBottom borderStyle

  for y in [area.y + 1 : area.y + area.height - 1] do
    result := result.writeString area.x y "|" borderStyle
    result := result.writeString (area.x + area.width - 1) y "|" borderStyle

  result := result.writeString area.x (area.y + area.height - 1) topBottom borderStyle

  if !title.isEmpty && area.width > 4 then
    let titleText := title.take (area.width - 4)
    result := result.writeString (area.x + 2) area.y titleText borderStyle

  result

/-- Inner drawable area for a bordered panel. -/
def panelInner (area : Rect) : Rect :=
  area.inner 1

/-- Computed panel areas for the main layout -/
structure PanelAreas where
  tabs : Rect
  main : Rect
  status : Rect
  deriving Repr, Inhabited

/-- Calculate the main panel areas -/
def layoutPanels (area : Rect) : PanelAreas :=
  -- Vertical: tabs (1) | main (fill) | status (1)
  let sections := vsplit area [.fixed 1, .fill, .fixed 1]
  {
    tabs := sections.getD 0 default
    main := sections.getD 1 default
    status := sections.getD 2 default
  }

/-- Split an area horizontally for entity/attribute views -/
def splitHorizontal (area : Rect) (leftPercent : Nat) : Rect × Rect :=
  let sections := hsplit area [.percent leftPercent, .fill]
  (sections.getD 0 default, sections.getD 1 default)

/-- Split an area vertically for query view -/
def splitVertical (area : Rect) (topHeight : Nat) : Rect × Rect :=
  let sections := vsplit area [.fixed topHeight, .fill]
  (sections.getD 0 default, sections.getD 1 default)

end Lighthouse.UI
