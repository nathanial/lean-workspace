/-
  Demo Runner - Canopy app visuals LineCaps tab content.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Demos.Visuals.LineCaps
import Trellis

open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

namespace Demos
def lineCapsTabContent (env : DemoEnv) : WidgetM Unit := do
  let elapsedTime ← useElapsedTime
  let _ ← dynWidget elapsedTime fun _ => do
    emit (lineCapsWidget env.screenScale env.fontSmall env.fontMedium)
  pure ()

end Demos
