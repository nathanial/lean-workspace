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

private def formatPercent (v : Float) : String :=
  s!"{formatFloat (v * 100.0) 1}%"

private def formatStatsLines (stats : RunnerStats) : Array String :=
  let cacheTotal := stats.cacheHits + stats.cacheMisses
  let cacheHitRate :=
    if cacheTotal == 0 then 0.0
    else stats.cacheHits.toFloat / cacheTotal.toFloat
  let drawOps := stats.batchedCalls + stats.individualCalls
  let batchCallRate :=
    if drawOps == 0 then 0.0
    else stats.batchedCalls.toFloat / drawOps.toFloat
  let commandReduction :=
    if stats.commandCount == 0 then 0.0
    else
      let reduced := stats.commandCount.toFloat - stats.coalescedCommandCount.toFloat
      reduced / stats.commandCount.toFloat
  let avgTextsPerFlush :=
    if stats.textBatchFlushes == 0 then 0.0
    else stats.textsBatched.toFloat / stats.textBatchFlushes.toFloat
  let accountingGap := Float.abs stats.unaccountedMs
  let line1 := s!"frame {formatFloat stats.frameMs}ms • {formatFloat stats.fps 1} fps"
  let line2 := s!"begin {formatFloat stats.beginFrameMs}ms • input {formatFloat stats.inputMs}ms • reactive {formatFloat stats.reactiveMs}ms (prop {formatFloat stats.reactivePropagateMs}ms • render {formatFloat stats.reactiveRenderMs}ms)"
  let line3 := s!"layout {formatFloat stats.layoutMs}ms • index {formatFloat stats.indexMs}ms • collect {formatFloat stats.collectMs}ms • exec {formatFloat stats.executeMs}ms • end {formatFloat stats.endFrameMs}ms"
  let line4 := s!"index split build {formatFloat stats.indexBuildMs}ms • store {formatFloat stats.indexSnapshotStoreMs}ms • ids {formatFloat stats.indexInteractiveIdsMs}ms • reg {formatFloat stats.indexRegistrySetMs}ms"
  let line5 := s!"accounted {formatFloat stats.accountedMs}ms • unaccounted {formatFloat stats.unaccountedMs}ms (|gap| {formatFloat accountingGap}ms)"
  let line6 := s!"cmds raw {stats.commandCount} • coalesced {stats.coalescedCommandCount} • reduction {formatPercent commandReduction}"
  let line7 := s!"widgets {stats.widgetCount} • layouts {stats.layoutCount} • draws {stats.drawCalls}"
  let line8 := s!"draw calls batched {stats.batchedCalls} • single {stats.individualCalls} • batched rate {formatPercent batchCallRate}"
  let line9 := s!"batched rects {stats.rectsBatched} • strokeRects {stats.strokeRectsBatched} • circles {stats.circlesBatched} • lines {stats.linesBatched} • texts {stats.textsBatched}"
  let line10 := s!"text cmds {stats.textFillCommands} • text flushes {stats.textBatchFlushes} • avg/flush {formatFloat avgTextsPerFlush 1}"
  let line11 := s!"batch timings flatten {formatFloat stats.flattenMs}ms • coalesce {formatFloat stats.coalesceMs}ms • loop {formatFloat stats.batchLoopMs}ms • draw {formatFloat stats.drawCallMs}ms"
  let line12 := s!"cache hits {stats.cacheHits} • misses {stats.cacheMisses} • hit rate {formatPercent cacheHitRate}"
  #[line1, line2, line3, line4, line5, line6, line7, line8, line9, line10, line11, line12]

/-- Show frame stats under the tab content. -/
def statsFooter (env : DemoEnv) (elapsedTime : Dynamic Spider Float) : WidgetM Unit := do
  let footerHeight := 248.0 * env.screenScale
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
