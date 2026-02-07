import Afferent.Arbor
import Tracker.Core.Types
import Tracker.GUI.Model

namespace Tracker.GUI

inductive Action where
  | loadRequested
  | loadSucceeded (root : System.FilePath) (issues : Array Issue)
  | loadFailed (message : String)
  | refresh
  | focusPrev
  | focusNext
  | focusSet (pane : FocusPane)
  | selectPrev
  | selectNext
  | selectIssue (id : Nat)
  | queryChanged (query : String)
  | statusFilterNext
  | toggleBlockedOnly
  | keyInput (key : Afferent.Arbor.Key)
  deriving Repr, Inhabited

end Tracker.GUI
