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

structure Model where
  focusPane : FocusPane := .issues
  selectedIssue : Nat := 0
  issueTitles : Array String := #[
    "#1 Scaffold reactive GUI shell",
    "#2 Wire storage read path",
    "#3 Add issue editor workflow"
  ]
  status : String := "Ready"
  deriving Repr, BEq, Inhabited

def Model.initial : Model := {}

def Model.issueCount (model : Model) : Nat :=
  model.issueTitles.size

def Model.clampIssueIndex (model : Model) (idx : Nat) : Nat :=
  match model.issueTitles.size with
  | 0 => 0
  | n + 1 => min idx n

def Model.selectedTitle (model : Model) : String :=
  model.issueTitles.getD model.selectedIssue "(none)"

end Tracker.GUI
