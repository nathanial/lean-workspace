/-
  VirtualList Tests
  Regression tests for virtual-list local state retention.
-/
import AfferentTests.Framework
import Afferent.UI.Arbor
import Afferent.UI.Canopy.Reactive.Component
import Afferent.UI.Canopy.Widget.Data.VirtualList
import Reactive
import Trellis

namespace AfferentTests.VirtualListTests

open Crucible
open AfferentTests
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Reactive Reactive.Host
open Trellis

testSuite "VirtualList Tests"

partial def findFirstScrollId (w : Widget) : Option WidgetId :=
  match w with
  | .scroll id .. => some id
  | _ =>
      w.children.findSome? findFirstScrollId

test "virtualList preserves scroll offset across dynWidget rebuild when keyed" := do
  let (beforeRebuild, afterRebuild) ← runSpider do
    let (events, inputs) ← createInputs Afferent.FontRegistry.empty
    let (trigger, fire) ← newTriggerEvent (t := Spider) (a := Nat)
    let phaseDyn ← holdDyn 0 trigger
    let scrollDynRef ← SpiderM.liftIO <| IO.mkRef (none : Option (Dynamic Spider ScrollState))

    let (_, render) ← ReactiveM.run events do
      runWidget do
        let _ ← dynWidget phaseDyn fun _ => do
          let list ← virtualList 300 (fun _ => do
            Afferent.Arbor.spacer 280 24
          ) {
            width := 280
            height := 140
            itemHeight := 24
            overscan := 2
            instanceKey := some "scroll-regression"
          }
          SpiderM.liftIO <| scrollDynRef.set (some list.scrollState)
          pure ()
        pure ()

    let initialBuilder ← SpiderM.liftIO render.materialize
    let initialWidget := Afferent.Arbor.build initialBuilder
    let initialMeasured := Afferent.Arbor.measureWidget (M := Id) initialWidget 320 220
    let initialLayouts := Trellis.layout initialMeasured.node 320 220
    let initialHitIndex := Afferent.Arbor.buildHitTestIndex initialMeasured.widget initialLayouts

    let listWidgetId :=
      match findFirstScrollId initialMeasured.widget with
      | some wid => wid
      | none => panic! "virtual list should render a scroll widget"

    inputs.fireScroll {
      scroll := { x := 40, y := 40, deltaX := 0, deltaY := -4.0, modifiers := {} }
      hitPath := #[listWidgetId]
      layouts := initialLayouts
      componentMap := initialHitIndex.componentMap
    }

    let beforeRebuild ← match ← SpiderM.liftIO scrollDynRef.get with
      | some dyn =>
        let state ← dyn.sample
        pure state.offsetY
      | none => panic! "expected initial scroll dynamic from virtualList"

    fire 1
    let _ ← SpiderM.liftIO render.materialize

    let afterRebuild ← match ← SpiderM.liftIO scrollDynRef.get with
      | some dyn =>
        let state ← dyn.sample
        pure state.offsetY
      | none => panic! "expected rebuilt scroll dynamic from virtualList"

    pure (beforeRebuild, afterRebuild)

  ensure (beforeRebuild > 0.0) s!"expected pre-rebuild scroll offset > 0, got {beforeRebuild}"
  shouldBeNear afterRebuild beforeRebuild

end AfferentTests.VirtualListTests
