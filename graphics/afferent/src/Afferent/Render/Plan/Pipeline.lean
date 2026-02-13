/-
  Afferent Render Stream Pipeline
  Normalize -> coalesce -> packet plan -> sink execution.
-/
import Afferent.Output.Canvas
import Afferent.Core.Transform
import Afferent.Graphics.Text.Font
import Afferent.Graphics.Text.Measurer
import Afferent.UI.Arbor
import Afferent.Draw.Optimize.Coalesce
import Afferent.Render.Stream
import Afferent.Render.Plan.Packet
import Afferent.Render.Sink.Interpreter
import Afferent.Render.Sink.Batches
import Afferent.Render.Sink.Execute

namespace Afferent.Widget

open Afferent
open Afferent.Arbor

private structure PacketPlanState where
  rectBatch : Array RectBatchEntry
  strokeRectBatch : Array StrokeRectBatchEntry
  currentStrokeLineWidth : Float
  circleBatch : Array CircleBatchEntry
  strokeCircleBatch : Array StrokeCircleBatchEntry
  currentStrokeCircleLineWidth : Float
  packets : Array DrawPacket
  stats : BatchStats

private def initPacketPlanState (totalCommands : Nat) (textFillCommands : Nat) : PacketPlanState :=
  { rectBatch := #[]
    strokeRectBatch := #[]
    currentStrokeLineWidth := 0.0
    circleBatch := #[]
    strokeCircleBatch := #[]
    currentStrokeCircleLineWidth := 0.0
    packets := #[]
    stats := { totalCommands := totalCommands, textFillCommands := textFillCommands } }

private def coalesceCommandsWithClip (bounded : Array BoundedCommand) : Array RenderCommand :=
  let cmds := coalesceByCategoryWithClip bounded
  let cmds := mergeInstancedPolygons cmds
  let cmds := mergeInstancedArcs cmds
  cmds

private def flushRectsPlan (state : PacketPlanState) : PacketPlanState :=
  if state.rectBatch.isEmpty then
    state
  else
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      rectsBatched := state.stats.rectsBatched + state.rectBatch.size }
    { state with
      rectBatch := #[]
      packets := state.packets.push (.fillRectBatch state.rectBatch)
      stats := stats }

private def flushStrokeRectsPlan (state : PacketPlanState) : PacketPlanState :=
  if state.strokeRectBatch.isEmpty then
    state
  else
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      strokeRectsBatched := state.stats.strokeRectsBatched + state.strokeRectBatch.size }
    { state with
      strokeRectBatch := #[]
      packets := state.packets.push (.strokeRectBatch state.strokeRectBatch state.currentStrokeLineWidth)
      stats := stats }

private def flushCirclesPlan (state : PacketPlanState) : PacketPlanState :=
  if state.circleBatch.isEmpty then
    state
  else
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      circlesBatched := state.stats.circlesBatched + state.circleBatch.size }
    { state with
      circleBatch := #[]
      packets := state.packets.push (.fillCircleBatch state.circleBatch)
      stats := stats }

private def flushStrokeCirclesPlan (state : PacketPlanState) : PacketPlanState :=
  if state.strokeCircleBatch.isEmpty then
    state
  else
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      circlesBatched := state.stats.circlesBatched + state.strokeCircleBatch.size }
    { state with
      strokeCircleBatch := #[]
      packets := state.packets.push (.strokeCircleBatch state.strokeCircleBatch state.currentStrokeCircleLineWidth)
      stats := stats }

private def flushAllPlan (state : PacketPlanState) : PacketPlanState :=
  let state := flushRectsPlan state
  let state := flushStrokeRectsPlan state
  let state := flushCirclesPlan state
  let state := flushStrokeCirclesPlan state
  state

private def flushForFillRectPlan (state : PacketPlanState) : PacketPlanState :=
  let state := flushStrokeRectsPlan state
  let state := flushCirclesPlan state
  let state := flushStrokeCirclesPlan state
  state

private def flushForStrokeRectPlan (state : PacketPlanState) : PacketPlanState :=
  let state := flushRectsPlan state
  let state := flushCirclesPlan state
  let state := flushStrokeCirclesPlan state
  state

private def flushForFillCirclePlan (state : PacketPlanState) : PacketPlanState :=
  let state := flushRectsPlan state
  let state := flushStrokeRectsPlan state
  let state := flushStrokeCirclesPlan state
  state

private def flushForStrokeCirclePlan (state : PacketPlanState) : PacketPlanState :=
  let state := flushRectsPlan state
  let state := flushStrokeRectsPlan state
  let state := flushCirclesPlan state
  state

private def pushCommandPacket (state : PacketPlanState) (cmd : RenderCommand) : PacketPlanState :=
  let stats :=
    match cmd with
    | .fillCircleBatch _ count =>
      { state.stats with
        batchedCalls := state.stats.batchedCalls + 1
        circlesBatched := state.stats.circlesBatched + count }
    | .strokeRectBatch _ count _ =>
      { state.stats with
        batchedCalls := state.stats.batchedCalls + 1
        strokeRectsBatched := state.stats.strokeRectsBatched + count }
    | .drawFragment .. =>
      { state.stats with batchedCalls := state.stats.batchedCalls + 1 }
    | _ =>
      { state.stats with individualCalls := state.stats.individualCalls + 1 }
  { state with
    packets := state.packets.push (.command cmd)
    stats := stats }

private def planPackets (cmds : Array RenderCommand) : PacketPlanState := Id.run do
  let textFillCommands := cmds.foldl (init := 0) fun acc cmd =>
    match cmd with
    | .fillText .. => acc + 1
    | _ => acc
  let mut state := initPacketPlanState cmds.size textFillCommands
  for cmd in cmds do
    match cmd with
    | .fillRect rect color cornerRadius =>
      state := flushForFillRectPlan state
      let entry : RectBatchEntry := {
        x := rect.origin.x, y := rect.origin.y
        width := rect.size.width, height := rect.size.height
        r := color.r, g := color.g, b := color.b, a := color.a
        cornerRadius := cornerRadius
      }
      state := { state with rectBatch := state.rectBatch.push entry }

    | .strokeRect rect color lineWidth cornerRadius =>
      state := flushForStrokeRectPlan state
      if state.strokeRectBatch.isEmpty || state.currentStrokeLineWidth == lineWidth then
        let entry : StrokeRectBatchEntry := {
          x := rect.origin.x, y := rect.origin.y
          width := rect.size.width, height := rect.size.height
          r := color.r, g := color.g, b := color.b, a := color.a
          cornerRadius := cornerRadius
        }
        state := { state with
          strokeRectBatch := state.strokeRectBatch.push entry
          currentStrokeLineWidth := lineWidth }
      else
        state := flushStrokeRectsPlan state
        let entry : StrokeRectBatchEntry := {
          x := rect.origin.x, y := rect.origin.y
          width := rect.size.width, height := rect.size.height
          r := color.r, g := color.g, b := color.b, a := color.a
          cornerRadius := cornerRadius
        }
        state := { state with
          strokeRectBatch := #[entry]
          currentStrokeLineWidth := lineWidth }

    | .fillCircle center radius color =>
      state := flushForFillCirclePlan state
      let entry : CircleBatchEntry := {
        centerX := center.x, centerY := center.y, radius := radius
        r := color.r, g := color.g, b := color.b, a := color.a
      }
      state := { state with circleBatch := state.circleBatch.push entry }

    | .strokeCircle center radius color lineWidth =>
      state := flushForStrokeCirclePlan state
      if state.strokeCircleBatch.isEmpty || state.currentStrokeCircleLineWidth == lineWidth then
        let entry : StrokeCircleBatchEntry := {
          centerX := center.x, centerY := center.y, radius := radius
          r := color.r, g := color.g, b := color.b, a := color.a
        }
        state := { state with
          strokeCircleBatch := state.strokeCircleBatch.push entry
          currentStrokeCircleLineWidth := lineWidth }
      else
        state := flushStrokeCirclesPlan state
        let entry : StrokeCircleBatchEntry := {
          centerX := center.x, centerY := center.y, radius := radius
          r := color.r, g := color.g, b := color.b, a := color.a
        }
        state := { state with
          strokeCircleBatch := #[entry]
          currentStrokeCircleLineWidth := lineWidth }

    | _ =>
      state := flushAllPlan state
      state := pushCommandPacket state cmd

  flushAllPlan state

/-- Execute a first-class render stream and return stats plus stage trace. -/
def executeRenderStreamWithStatsAndTrace (reg : FontRegistry)
    (stream : Afferent.Render.RenderStream) : CanvasM (BatchStats × RenderTrace) := do
  let frameId :=
    match stream.find? (fun ev =>
      match ev with
      | .frameStart _ => true
      | _ => false) with
    | some (.frameStart id) => id
    | _ => 0

  let rawCmds := Afferent.Render.commandsFromStream stream

  let tFlatten0 ← IO.monoNanosNow
  let bounded := computeBoundedCommands rawCmds
  let tFlatten1 ← IO.monoNanosNow

  let tCoalesce0 ← IO.monoNanosNow
  let coalesced := coalesceCommandsWithClip bounded
  let tCoalesce1 ← IO.monoNanosNow

  let tPlan0 ← IO.monoNanosNow
  let planned := planPackets coalesced
  let tPlan1 ← IO.monoNanosNow

  let tSink0 ← IO.monoNanosNow
  let mut drawCallNs : Nat := 0
  for packet in planned.packets do
    drawCallNs := drawCallNs + (← executeDrawPacket reg packet)
  let tSink1 ← IO.monoNanosNow

  let timeFlattenMs := (tFlatten1 - tFlatten0).toFloat / 1000000.0
  let timeCoalesceMs := (tCoalesce1 - tCoalesce0).toFloat / 1000000.0
  let timePlanMs := (tPlan1 - tPlan0).toFloat / 1000000.0
  let timeSinkMs := (tSink1 - tSink0).toFloat / 1000000.0
  let timeDrawCallsMs := drawCallNs.toFloat / 1000000.0

  let stats := { planned.stats with
    timeFlattenMs := timeFlattenMs
    timeCoalesceMs := timeCoalesceMs
    timeBatchLoopMs := timePlanMs
    timeDrawCallsMs := timeDrawCallsMs
    timeTextPackMs := 0.0
    timeTextFFIMs := 0.0 }

  let trace : RenderTrace := {
    frameId := frameId
    normalizedEvents := stream.size
    coalescedCommands := coalesced.size
    packets := planned.packets.size
    stages := #[
      { name := "flatten", inputCount := rawCmds.size, outputCount := bounded.size, elapsedMs := timeFlattenMs },
      { name := "coalesce", inputCount := bounded.size, outputCount := coalesced.size, elapsedMs := timeCoalesceMs },
      { name := "batch-plan", inputCount := coalesced.size, outputCount := planned.packets.size, elapsedMs := timePlanMs },
      { name := "sink", inputCount := planned.packets.size, outputCount := planned.packets.size, elapsedMs := timeSinkMs }
    ]
  }

  pure (stats, trace)

/-- Execute a first-class render stream and return only batch stats. -/
def executeRenderStreamWithStats (reg : FontRegistry)
    (stream : Afferent.Render.RenderStream) : CanvasM BatchStats := do
  let (stats, _) ← executeRenderStreamWithStatsAndTrace reg stream
  pure stats

/-- Execute an array of RenderCommands using the render stream pipeline.
    This is the primary production execution entrypoint for Arbor output. -/
def executeCommandsBatchedWithStats (reg : FontRegistry)
    (cmds : Array Afferent.Arbor.RenderCommand) : CanvasM BatchStats := do
  let stream := Afferent.Render.streamFromCommands cmds
  executeRenderStreamWithStats reg stream

/-- Execute an array of RenderCommands using the render stream pipeline. -/
def executeCommandsBatched (reg : FontRegistry)
    (cmds : Array Afferent.Arbor.RenderCommand) : CanvasM Unit := do
  let _ ← executeCommandsBatchedWithStats reg cmds

end Afferent.Widget
