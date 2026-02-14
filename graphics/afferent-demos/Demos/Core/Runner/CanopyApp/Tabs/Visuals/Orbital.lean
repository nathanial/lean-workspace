/-
  Demo Runner - Canopy app visuals Orbital tab content.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Demos.Visuals.Orbital
import Trellis

open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

namespace Demos
def orbitalTabContent (env : DemoEnv) : WidgetM Unit := do
  let elapsedTime ← useElapsedTime
  let _ ← dynWidget elapsedTime fun t => do
    emit (orbitalWidget t env.screenScale env.fontMedium env.orbitalCount env.orbitalParams)
  pure ()

end Demos
