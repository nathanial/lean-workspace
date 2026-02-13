/-
  Afferent Render Stream Pipeline
  Stream events -> transducer pipeline -> draw packets -> sink execution.
-/
import Afferent.Output.Canvas
import Afferent.Core.Transform
import Afferent.Graphics.Text.Font
import Afferent.Graphics.Text.Measurer
import Afferent.UI.Arbor
import Afferent.Draw.Optimize.Coalesce
import Afferent.Render.Stream
import Afferent.Render.Plan.Packet
import Afferent.Render.Sink.Execute
import Afferent.Render.Sink.Batches

namespace Afferent.Widget

open Afferent
open Afferent.Arbor

private def coalesceCommandsWithClip (bounded : Array BoundedCommand) : Array RenderCommand :=
  let cmds := coalesceByCategoryWithClip bounded
  let cmds := mergeInstancedPolygons cmds
  let cmds := mergeInstancedArcs cmds
  cmds

private structure CoalesceTransducerState where
  pending : Array RenderCommand := #[]
  boundedCommands : Nat := 0
  coalescedCommands : Nat := 0
  emittedBarriers : Nat := 0

private def flushCoalescePending (state : CoalesceTransducerState)
    : CoalesceTransducerState × Array Afferent.Render.RenderEvent :=
  if state.pending.isEmpty then
    (state, #[])
  else
    let bounded := computeBoundedCommands state.pending
    let coalesced := coalesceCommandsWithClip bounded
    let out := coalesced.map Afferent.Render.eventOfCommand
    let barrierCount := out.foldl (init := 0) fun acc ev =>
      match ev with
      | .barrier _ => acc + 1
      | _ => acc
    ({ state with
      pending := #[]
      boundedCommands := state.boundedCommands + bounded.size
      coalescedCommands := state.coalescedCommands + coalesced.size
      emittedBarriers := state.emittedBarriers + barrierCount }, out)

private def coalesceTransducer
    : Afferent.Render.Transducer Afferent.Render.RenderEvent Afferent.Render.RenderEvent CoalesceTransducerState where
  init := {}
  step state ev :=
    match ev with
    | .cmd cmd =>
      ({ state with pending := state.pending.push cmd }, #[])
    | .barrier kind =>
      match Afferent.Render.barrierToCommand? kind with
      | some cmd =>
        ({ state with pending := state.pending.push cmd }, #[])
      | none =>
        let (state, out) := flushCoalescePending state
        (state, out.push (.barrier kind))
    | .frameStart frameId =>
      let (state, out) := flushCoalescePending state
      (state, out.push (.frameStart frameId))
    | .frameEnd frameId =>
      let (state, out) := flushCoalescePending state
      (state, out.push (.frameEnd frameId))
  done state := (flushCoalescePending state).2

private structure PacketTransducerState where
  rectBatch : Array RectBatchEntry := #[]
  strokeRectBatch : Array StrokeRectBatchEntry := #[]
  currentStrokeLineWidth : Float := 0.0
  circleBatch : Array CircleBatchEntry := #[]
  strokeCircleBatch : Array StrokeCircleBatchEntry := #[]
  currentStrokeCircleLineWidth : Float := 0.0
  stats : BatchStats := {}

private def noteSeenCommand (state : PacketTransducerState) (cmd : RenderCommand) : PacketTransducerState :=
  let textInc :=
    match cmd with
    | .fillText .. => 1
    | _ => 0
  let stats := { state.stats with
    totalCommands := state.stats.totalCommands + 1
    textFillCommands := state.stats.textFillCommands + textInc }
  { state with stats := stats }

private def flushRectsT (state : PacketTransducerState)
    : PacketTransducerState × Array DrawPacket :=
  if state.rectBatch.isEmpty then
    (state, #[])
  else
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      rectsBatched := state.stats.rectsBatched + state.rectBatch.size }
    ({ state with rectBatch := #[], stats := stats }, #[.fillRectBatch state.rectBatch])

private def flushStrokeRectsT (state : PacketTransducerState)
    : PacketTransducerState × Array DrawPacket :=
  if state.strokeRectBatch.isEmpty then
    (state, #[])
  else
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      strokeRectsBatched := state.stats.strokeRectsBatched + state.strokeRectBatch.size }
    ({ state with strokeRectBatch := #[], stats := stats },
      #[.strokeRectBatch state.strokeRectBatch state.currentStrokeLineWidth])

private def flushCirclesT (state : PacketTransducerState)
    : PacketTransducerState × Array DrawPacket :=
  if state.circleBatch.isEmpty then
    (state, #[])
  else
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      circlesBatched := state.stats.circlesBatched + state.circleBatch.size }
    ({ state with circleBatch := #[], stats := stats }, #[.fillCircleBatch state.circleBatch])

private def flushStrokeCirclesT (state : PacketTransducerState)
    : PacketTransducerState × Array DrawPacket :=
  if state.strokeCircleBatch.isEmpty then
    (state, #[])
  else
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      circlesBatched := state.stats.circlesBatched + state.strokeCircleBatch.size }
    ({ state with strokeCircleBatch := #[], stats := stats },
      #[.strokeCircleBatch state.strokeCircleBatch state.currentStrokeCircleLineWidth])

private def flushAllT (state : PacketTransducerState)
    : PacketTransducerState × Array DrawPacket :=
  let (state, out0) := flushRectsT state
  let (state, out1) := flushStrokeRectsT state
  let (state, out2) := flushCirclesT state
  let (state, out3) := flushStrokeCirclesT state
  (state, out0 ++ out1 ++ out2 ++ out3)

private def flushForFillRectT (state : PacketTransducerState)
    : PacketTransducerState × Array DrawPacket :=
  let (state, out0) := flushStrokeRectsT state
  let (state, out1) := flushCirclesT state
  let (state, out2) := flushStrokeCirclesT state
  (state, out0 ++ out1 ++ out2)

private def flushForStrokeRectT (state : PacketTransducerState)
    : PacketTransducerState × Array DrawPacket :=
  let (state, out0) := flushRectsT state
  let (state, out1) := flushCirclesT state
  let (state, out2) := flushStrokeCirclesT state
  (state, out0 ++ out1 ++ out2)

private def flushForFillCircleT (state : PacketTransducerState)
    : PacketTransducerState × Array DrawPacket :=
  let (state, out0) := flushRectsT state
  let (state, out1) := flushStrokeRectsT state
  let (state, out2) := flushStrokeCirclesT state
  (state, out0 ++ out1 ++ out2)

private def flushForStrokeCircleT (state : PacketTransducerState)
    : PacketTransducerState × Array DrawPacket :=
  let (state, out0) := flushRectsT state
  let (state, out1) := flushStrokeRectsT state
  let (state, out2) := flushCirclesT state
  (state, out0 ++ out1 ++ out2)

private def packetOfRenderCommand : RenderCommand → DrawPacket
  | .fillRect rect color cornerRadius =>
    .fillRect rect color cornerRadius
  | .fillRectStyle rect style cornerRadius =>
    .fillRectStyle rect style cornerRadius
  | .strokeRect rect color lineWidth cornerRadius =>
    .strokeRect rect color lineWidth cornerRadius
  | .strokeRectBatch data count lineWidth =>
    .strokeRectPacked data count lineWidth
  | .fillCircle center radius color =>
    .fillCircle center radius color
  | .fillCircleBatch data count =>
    .fillCirclePacked data count
  | .strokeCircle center radius color lineWidth =>
    .strokeCircle center radius color lineWidth
  | .strokeLine p1 p2 color lineWidth =>
    .strokeLine p1 p2 color lineWidth
  | .strokeLineBatch data count lineWidth =>
    .strokeLineBatch data count lineWidth
  | .fillText text x y font color =>
    .fillText text x y font color
  | .fillTextBlock text rect font color align valign =>
    .fillTextBlock text rect font color align valign
  | .fillPolygon points color =>
    .fillPolygon points color
  | .strokePolygon points color lineWidth =>
    .strokePolygon points color lineWidth
  | .fillPath path color =>
    .fillPath path color
  | .fillPathStyle path style =>
    .fillPathStyle path style
  | .strokePath path color lineWidth =>
    .strokePath path color lineWidth
  | .fillPolygonInstanced pathHash vertices indices instances centerX centerY =>
    .fillPolygonInstanced pathHash vertices indices instances centerX centerY
  | .strokeArcInstanced instances segments =>
    .strokeArcInstanced instances segments
  | .drawFragment fragmentHash primitiveType params instanceCount =>
    .drawFragment fragmentHash primitiveType params instanceCount
  | .fillTessellatedBatch vertices indices vertexCount =>
    .fillTessellatedBatch vertices indices vertexCount
  | .pushClip rect =>
    .pushClip rect
  | .popClip =>
    .popClip
  | .pushTranslate dx dy =>
    .pushTranslate dx dy
  | .pushRotate angle =>
    .pushRotate angle
  | .pushScale sx sy =>
    .pushScale sx sy
  | .popTransform =>
    .popTransform
  | .save =>
    .save
  | .restore =>
    .restore

private def emitDirectPacket (state : PacketTransducerState) (cmd : RenderCommand)
    : PacketTransducerState × Array DrawPacket :=
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
  ({ state with stats := stats }, #[packetOfRenderCommand cmd])

private def packetTransducer
    : Afferent.Render.Transducer Afferent.Render.RenderEvent DrawPacket PacketTransducerState where
  init := {}
  step state ev :=
    match ev with
    | .frameStart _ =>
      flushAllT state
    | .frameEnd _ =>
      flushAllT state
    | .barrier kind =>
      let (state, out0) := flushAllT state
      match Afferent.Render.barrierToCommand? kind with
      | some cmd =>
        let state := noteSeenCommand state cmd
        let (state, out1) := emitDirectPacket state cmd
        (state, out0 ++ out1)
      | none =>
        (state, out0)
    | .cmd cmd =>
      let state := noteSeenCommand state cmd
      match cmd with
      | .fillRect rect color cornerRadius =>
        let (state, out0) := flushForFillRectT state
        let entry : RectBatchEntry := {
          x := rect.origin.x, y := rect.origin.y
          width := rect.size.width, height := rect.size.height
          r := color.r, g := color.g, b := color.b, a := color.a
          cornerRadius := cornerRadius
        }
        ({ state with rectBatch := state.rectBatch.push entry }, out0)

      | .strokeRect rect color lineWidth cornerRadius =>
        let (state, out0) := flushForStrokeRectT state
        if state.strokeRectBatch.isEmpty || state.currentStrokeLineWidth == lineWidth then
          let entry : StrokeRectBatchEntry := {
            x := rect.origin.x, y := rect.origin.y
            width := rect.size.width, height := rect.size.height
            r := color.r, g := color.g, b := color.b, a := color.a
            cornerRadius := cornerRadius
          }
          ({ state with
            strokeRectBatch := state.strokeRectBatch.push entry
            currentStrokeLineWidth := lineWidth }, out0)
        else
          let (state, out1) := flushStrokeRectsT state
          let entry : StrokeRectBatchEntry := {
            x := rect.origin.x, y := rect.origin.y
            width := rect.size.width, height := rect.size.height
            r := color.r, g := color.g, b := color.b, a := color.a
            cornerRadius := cornerRadius
          }
          ({ state with
            strokeRectBatch := #[entry]
            currentStrokeLineWidth := lineWidth }, out0 ++ out1)

      | .fillCircle center radius color =>
        let (state, out0) := flushForFillCircleT state
        let entry : CircleBatchEntry := {
          centerX := center.x, centerY := center.y, radius := radius
          r := color.r, g := color.g, b := color.b, a := color.a
        }
        ({ state with circleBatch := state.circleBatch.push entry }, out0)

      | .strokeCircle center radius color lineWidth =>
        let (state, out0) := flushForStrokeCircleT state
        if state.strokeCircleBatch.isEmpty || state.currentStrokeCircleLineWidth == lineWidth then
          let entry : StrokeCircleBatchEntry := {
            centerX := center.x, centerY := center.y, radius := radius
            r := color.r, g := color.g, b := color.b, a := color.a
          }
          ({ state with
            strokeCircleBatch := state.strokeCircleBatch.push entry
            currentStrokeCircleLineWidth := lineWidth }, out0)
        else
          let (state, out1) := flushStrokeCirclesT state
          let entry : StrokeCircleBatchEntry := {
            centerX := center.x, centerY := center.y, radius := radius
            r := color.r, g := color.g, b := color.b, a := color.a
          }
          ({ state with
            strokeCircleBatch := #[entry]
            currentStrokeCircleLineWidth := lineWidth }, out0 ++ out1)

      | _ =>
        let (state, out0) := flushAllT state
        let (state, out1) := emitDirectPacket state cmd
        (state, out0 ++ out1)
  done state := (flushAllT state).2

/-- Execute a first-class render stream and return stats plus stage trace.
    Production path: coalescing transducer >>> packetization transducer >>> sink execution. -/
def executeRenderStreamWithStatsAndTrace (reg : FontRegistry)
    (stream : Afferent.Render.RenderStream) : CanvasM (BatchStats × RenderTrace) := do
  let frameId :=
    match stream.find? (fun ev =>
      match ev with
      | .frameStart _ => true
      | _ => false) with
    | some (.frameStart id) => id
    | _ => 0

  let pipeline := Afferent.Render.Transducer.compose coalesceTransducer packetTransducer

  let tPipeline0 ← IO.monoNanosNow
  let ((coalesceState, packetState), packets) :=
    Afferent.Render.Transducer.runArrayWithState pipeline stream
  let tPipeline1 ← IO.monoNanosNow

  let tSink0 ← IO.monoNanosNow
  let mut drawCallNs : Nat := 0
  for packet in packets do
    drawCallNs := drawCallNs + (← executeDrawPacket reg packet)
  let tSink1 ← IO.monoNanosNow

  let timePipelineMs := (tPipeline1 - tPipeline0).toFloat / 1000000.0
  let timeSinkMs := (tSink1 - tSink0).toFloat / 1000000.0
  let timeDrawCallsMs := drawCallNs.toFloat / 1000000.0

  let stats := { packetState.stats with
    timeFlattenMs := 0.0
    timeCoalesceMs := 0.0
    timeBatchLoopMs := timePipelineMs
    timeDrawCallsMs := timeDrawCallsMs
    timeTextPackMs := 0.0
    timeTextFFIMs := 0.0 }

  let coalescedCount := coalesceState.coalescedCommands + coalesceState.emittedBarriers

  let trace : RenderTrace := {
    frameId := frameId
    normalizedEvents := stream.size
    coalescedCommands := coalescedCount
    packets := packets.size
    stages := #[
      { name := "stream-pipeline", inputCount := stream.size, outputCount := packets.size, elapsedMs := timePipelineMs },
      { name := "sink", inputCount := packets.size, outputCount := packets.size, elapsedMs := timeSinkMs }
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
