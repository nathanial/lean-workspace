/-
  Demo Runner - Canopy app helpers.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Trellis

open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

namespace Demos

private def roundTo (v : Float) (places : Nat) : Float :=
  let factor := (10 : Float) ^ places.toFloat
  (v * factor).round / factor

private def formatFloat (v : Float) (places : Nat := 2) : String :=
  let s := toString (roundTo v places)
  if s.any (· == '.') then
    let s := s.dropRightWhile (· == '0')
    if s.endsWith "." then s.dropRight 1 else s
  else
    s

private def formatStatsLines (stats : RunnerStats) : Array String :=
  let accountingGap := Float.abs stats.unaccountedMs
  let line1 := s!"frame {formatFloat stats.frameMs}ms • {formatFloat stats.fps 1} fps"
  let line2 := s!"begin {formatFloat stats.beginFrameMs}ms • input {formatFloat stats.inputMs}ms • reactive {formatFloat stats.reactiveMs}ms (prop {formatFloat stats.reactivePropagateMs}ms • render {formatFloat stats.reactiveRenderMs}ms)"
  let line3 := s!"layout {formatFloat stats.layoutMs}ms • index {formatFloat stats.indexMs}ms • collect {formatFloat stats.collectMs}ms • exec {formatFloat stats.executeMs}ms • end {formatFloat stats.endFrameMs}ms"
  let line4 := s!"index split build {formatFloat stats.indexBuildMs}ms • store {formatFloat stats.indexSnapshotStoreMs}ms • ids {formatFloat stats.indexInteractiveIdsMs}ms • reg {formatFloat stats.indexRegistrySetMs}ms"
  let line5 := s!"accounted {formatFloat stats.accountedMs}ms • unaccounted {formatFloat stats.unaccountedMs}ms (|gap| {formatFloat accountingGap}ms)"
  let line6 := s!"cmds {stats.commandCount} • widgets {stats.widgetCount} • layouts {stats.layoutCount} • draws {stats.drawCalls}"
  let line7 := s!"exec split draw {formatFloat stats.executeDrawMs}ms • custom {formatFloat stats.executeCustomMs}ms • overhead {formatFloat stats.executeOverheadMs}ms"
  #[line1, line2, line3, line4, line5, line6, line7]

/-- Show frame stats under the tab content. -/
def statsFooter (env : DemoEnv) (elapsedTime : Dynamic Spider Float) : WidgetM Unit := do
  let footerHeight := 318.0 * env.screenScale
  let footerStyle : BoxStyle := {
    backgroundColor := some (Color.gray 0.08)
    padding := EdgeInsets.symmetric (6.0 * env.screenScale) (4.0 * env.screenScale)
    width := .percent 1.0
    height := .length footerHeight
    flexItem := some (FlexItem.fixed footerHeight)
  }
  column' (gap := 2.0 * env.screenScale) (style := footerStyle) do
    let _ ← dynWidget elapsedTime fun _ => do
      let stats ← SpiderM.liftIO env.statsRef.get
      let lines := formatStatsLines stats
      for line in lines do
        caption' line
      pure ()
    pure ()

end Demos
