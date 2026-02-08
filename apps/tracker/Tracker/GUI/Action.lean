import Afferent.UI.Arbor
import Tracker.Core.Types
import Tracker.GUI.Model

namespace Tracker.GUI

inductive Action where
  | loadRequested
  | loadSucceeded (root : System.FilePath) (issues : Array Issue)
  | loadFailed (message : String)
  | mutationApplied (message : String) (selectedIssueId : Option Nat)
      (root : System.FilePath) (issues : Array Issue)
  | mutationFailed (message : String)
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
  | createTitleChanged (title : String)
  | createDescriptionChanged (description : String)
  | createAssigneeChanged (assignee : String)
  | createLabelsChanged (labels : String)
  | createPriorityNext
  | createSubmitted
  | editTitleChanged (title : String)
  | editDescriptionChanged (description : String)
  | editAssigneeChanged (assignee : String)
  | editLabelsChanged (labels : String)
  | editPriorityNext
  | editStatusNext
  | saveEdits
  | progressChanged (message : String)
  | addProgressSubmitted
  | closeCommentChanged (comment : String)
  | closeSubmitted
  | reopenSubmitted
  | keyInput (key : Afferent.Arbor.Key)
  deriving Repr, Inhabited

end Tracker.GUI
