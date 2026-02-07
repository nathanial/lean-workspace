import Tracker.GUI.Action

namespace Tracker.GUI

inductive Effect where
  | none
  deriving Repr, Inhabited

abbrev Dispatch := Action → IO Unit

def runEffects (_dispatch : Dispatch) (_effects : Array Effect) : IO Unit :=
  pure ()

end Tracker.GUI
