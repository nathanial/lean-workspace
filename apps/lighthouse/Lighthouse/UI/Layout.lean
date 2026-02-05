/-
  Lighthouse UI Layout
  Panel area calculations
-/

import Terminus

namespace Lighthouse.UI

open Terminus

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
