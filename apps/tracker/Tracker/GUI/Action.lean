import Afferent.Arbor
import Tracker.GUI.Model

namespace Tracker.GUI

inductive Action where
  | focusPrev
  | focusNext
  | focusSet (pane : FocusPane)
  | selectPrev
  | selectNext
  | selectIssue (index : Nat)
  | keyInput (key : Afferent.Arbor.Key)
  deriving Repr, Inhabited

end Tracker.GUI
