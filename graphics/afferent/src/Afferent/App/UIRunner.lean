/-
  Compatibility module.
  Canonical runner implementation lives at `Afferent.Runner.Loop`.
-/
import Afferent.Runner.Loop

namespace Afferent.App

abbrev LayoutMode := Afferent.Runner.LayoutMode
abbrev UIApp := Afferent.Runner.UIApp
abbrev LayoutInfo := Afferent.Runner.LayoutInfo

abbrev run := Afferent.Runner.run

end Afferent.App
