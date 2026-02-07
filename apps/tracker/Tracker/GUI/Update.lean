import Afferent.Arbor
import Tracker.GUI.Action
import Tracker.GUI.Effect
import Tracker.GUI.Model

namespace Tracker.GUI

private def focusPrevPane : FocusPane → FocusPane
  | .issues => .actions
  | .detail => .issues
  | .actions => .detail

private def focusNextPane : FocusPane → FocusPane
  | .issues => .detail
  | .detail => .actions
  | .actions => .issues

def actionFromKey (key : Afferent.Arbor.Key) : Option Action :=
  match key with
  | .tab => some .focusNext
  | .left => some .focusPrev
  | .right => some .focusNext
  | .up => some .selectPrev
  | .down => some .selectNext
  | .char 'h' => some .focusPrev
  | .char 'l' => some .focusNext
  | .char 'k' => some .selectPrev
  | .char 'j' => some .selectNext
  | _ => none

private def setStatusForSelection (model : Model) : Model :=
  { model with status := s!"Selected {model.selectedTitle}" }

private def applyNonKeyAction (model : Model) (action : Action) : Model × Array Effect :=
  match action with
  | .focusPrev =>
      let next := { model with focusPane := focusPrevPane model.focusPane, status := "Focus moved" }
      (next, #[])
  | .focusNext =>
      let next := { model with focusPane := focusNextPane model.focusPane, status := "Focus moved" }
      (next, #[])
  | .focusSet pane =>
      ({ model with focusPane := pane, status := s!"Focus: {pane.label}" }, #[])
  | .selectPrev =>
      match model.issueCount with
      | 0 => (model, #[])
      | _ =>
          let nextIndex :=
            if model.selectedIssue == 0 then model.issueCount - 1 else model.selectedIssue - 1
          let next := setStatusForSelection { model with selectedIssue := nextIndex }
          (next, #[])
  | .selectNext =>
      match model.issueCount with
      | 0 => (model, #[])
      | _ =>
          let nextIndex := (model.selectedIssue + 1) % model.issueCount
          let next := setStatusForSelection { model with selectedIssue := nextIndex }
          (next, #[])
  | .selectIssue index =>
      let next := setStatusForSelection { model with selectedIssue := model.clampIssueIndex index }
      (next, #[])
  | .keyInput _ =>
      (model, #[])

def update (model : Model) (action : Action) : Model × Array Effect :=
  match action with
  | .keyInput key =>
      match actionFromKey key with
      | some translated => applyNonKeyAction model translated
      | none => (model, #[])
  | nonKey =>
      applyNonKeyAction model nonKey

end Tracker.GUI
