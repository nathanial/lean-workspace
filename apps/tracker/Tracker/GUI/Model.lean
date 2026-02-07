import Tracker.Core.Types
import Tracker.Core.Storage
import Tracker.Core.Util

namespace Tracker.GUI

inductive FocusPane where
  | issues
  | detail
  | actions
  deriving Repr, BEq, Inhabited

def FocusPane.label : FocusPane → String
  | .issues => "Issues"
  | .detail => "Detail"
  | .actions => "Actions"

inductive StatusFilter where
  | active
  | open_
  | inProgress
  | closed
  | all
  deriving Repr, BEq, Inhabited

namespace StatusFilter

def label : StatusFilter → String
  | .active => "active"
  | .open_ => "open"
  | .inProgress => "in-progress"
  | .closed => "closed"
  | .all => "all"

def next : StatusFilter → StatusFilter
  | .active => .open_
  | .open_ => .inProgress
  | .inProgress => .closed
  | .closed => .all
  | .all => .active

end StatusFilter

structure Model where
  focusPane : FocusPane := .issues
  root : Option System.FilePath := none
  issues : Array Issue := #[]
  selectedIssueId : Option Nat := none
  statusFilter : StatusFilter := .active
  blockedOnly : Bool := false
  query : String := ""
  loading : Bool := false
  error : Option String := none
  status : String := "Idle"
  deriving Repr, Inhabited

def Model.initial : Model := { status := "Starting GUI..." }

private def matchesStatus (filter : StatusFilter) (issue : Issue) : Bool :=
  match filter with
  | .active => issue.status.isOpen
  | .open_ => issue.status == .open_
  | .inProgress => issue.status == .inProgress
  | .closed => issue.status == .closed
  | .all => true

private def applyQuery (issues : Array Issue) (query : String) : Array Issue :=
  if Util.trim query |>.isEmpty then issues
  else Storage.searchIssuesIn issues query

/-- In-memory filtered issue set used by list/detail views. -/
def Model.filteredIssues (model : Model) : Array Issue :=
  let base := model.issues.filter fun issue =>
    let statusOk := matchesStatus model.statusFilter issue
    let blockedOk := !model.blockedOnly || Storage.isEffectivelyBlocked issue model.issues
    statusOk && blockedOk
  applyQuery base model.query

/-- Ensure selection points at a currently-visible issue, if any. -/
def Model.normalizeSelection (model : Model) : Model :=
  let visible := model.filteredIssues
  let firstVisibleId : Option Nat :=
    if h : 0 < visible.size then
      some visible[0].id
    else
      none
  let nextSelection :=
    match model.selectedIssueId with
    | some id =>
      if visible.any (fun issue => issue.id == id) then some id
      else firstVisibleId
    | none =>
      firstVisibleId
  { model with selectedIssueId := nextSelection }

def Model.selectedIssue? (model : Model) : Option Issue := do
  let selectedId ← model.selectedIssueId
  model.issues.find? (fun issue => issue.id == selectedId)

def Model.filteredCount (model : Model) : Nat :=
  model.filteredIssues.size

def Model.totalCount (model : Model) : Nat :=
  model.issues.size

end Tracker.GUI
