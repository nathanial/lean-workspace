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

private structure CoalesceBuckets where
  bucket0 : Array RenderCommand := #[]  -- fillRect
  bucket1 : Array RenderCommand := #[]  -- fillCircle
  bucket2 : Array RenderCommand := #[]  -- strokeRect
  bucket3 : Array RenderCommand := #[]  -- strokeCircle
  bucket4 : Array RenderCommand := #[]  -- strokeLine
  bucket5 : Array RenderCommand := #[]  -- strokeArcInstanced
  bucket6 : Array RenderCommand := #[]  -- drawFragment
  bucket7 : Array RenderCommand := #[]  -- fillText
  bucket8 : Array RenderCommand := #[]  -- fillPolygonInstanced
  bucket9 : Array RenderCommand := #[]  -- fillTessellatedBatch

private def updateTransformStackForCommand
    (stack : Array Transform) (cmd : RenderCommand) : Array Transform :=
  let current := stack.back?.getD Transform.identity
  match cmd with
  | .pushTranslate dx dy =>
    stack.push (current.translated dx dy)
  | .pushScale sx sy =>
    stack.push (current.scaled sx sy)
  | .pushRotate angle =>
    stack.push (current.rotated angle)
  | .popTransform =>
    if stack.size > 1 then stack.pop else stack
  | .save =>
    stack.push current
  | .restore =>
    if stack.size > 1 then stack.pop else stack
  | _ =>
    stack

private def bucketPush (b : CoalesceBuckets) (cmd : RenderCommand) : CoalesceBuckets :=
  match cmd.category.sortPriority with
  | 0 => { b with bucket0 := b.bucket0.push cmd }
  | 1 => { b with bucket1 := b.bucket1.push cmd }
  | 2 => { b with bucket2 := b.bucket2.push cmd }
  | 3 => { b with bucket3 := b.bucket3.push cmd }
  | 4 => { b with bucket4 := b.bucket4.push cmd }
  | 5 => { b with bucket5 := b.bucket5.push cmd }
  | 6 => { b with bucket6 := b.bucket6.push cmd }
  | 7 => { b with bucket7 := b.bucket7.push cmd }
  | 8 => { b with bucket8 := b.bucket8.push cmd }
  | _ => { b with bucket9 := b.bucket9.push cmd }

private def bucketCount (b : CoalesceBuckets) : Nat :=
  b.bucket0.size + b.bucket1.size + b.bucket2.size + b.bucket3.size + b.bucket4.size +
  b.bucket5.size + b.bucket6.size + b.bucket7.size + b.bucket8.size + b.bucket9.size

private def bucketsToEvents (b : CoalesceBuckets) : Array Afferent.Render.RenderEvent :=
  let cmds :=
    b.bucket0 ++ b.bucket1 ++ b.bucket2 ++ b.bucket3 ++ b.bucket4 ++
    b.bucket5 ++ b.bucket6 ++ b.bucket7 ++ b.bucket8 ++ b.bucket9
  cmds.map Afferent.Render.eventOfCommand

private structure CoalesceTransducerState where
  transformStack : Array Transform := #[Transform.identity]
  buckets : CoalesceBuckets := {}
  boundedCommands : Nat := 0
  coalescedCommands : Nat := 0
  emittedBarriers : Nat := 0

private def flushCoalesceBuckets (state : CoalesceTransducerState)
    : CoalesceTransducerState × Array Afferent.Render.RenderEvent :=
  let count := bucketCount state.buckets
  if count == 0 then
    (state, #[])
  else
    let out := bucketsToEvents state.buckets
    let barrierCount := out.foldl (init := 0) fun acc ev =>
      match ev with
      | .barrier _ => acc + 1
      | _ => acc
    ({ state with
      buckets := {}
      coalescedCommands := state.coalescedCommands + count
      emittedBarriers := state.emittedBarriers + barrierCount }, out)

private def coalesceStepCommand (state : CoalesceTransducerState) (cmd : RenderCommand)
    : CoalesceTransducerState × Array Afferent.Render.RenderEvent :=
  let transform := state.transformStack.back?.getD Transform.identity
  let (flatCmd, _bounds) := flattenCommand cmd transform
  let transformStack := updateTransformStackForCommand state.transformStack cmd
  let state := { state with transformStack := transformStack, boundedCommands := state.boundedCommands + 1 }
  if flatCmd.category == .other then
    let (state, out0) := flushCoalesceBuckets state
    let ev := Afferent.Render.eventOfCommand flatCmd
    let barrierInc := match ev with | .barrier _ => 1 | _ => 0
    ({ state with
      coalescedCommands := state.coalescedCommands + 1
      emittedBarriers := state.emittedBarriers + barrierInc }, out0.push ev)
  else
    ({ state with buckets := bucketPush state.buckets flatCmd }, #[])

private def coalesceTransducer
    : Afferent.Render.Transducer Afferent.Render.RenderEvent Afferent.Render.RenderEvent CoalesceTransducerState where
  init := {}
  step state ev :=
    match ev with
    | .cmd cmd =>
      coalesceStepCommand state cmd
    | .barrier kind =>
      match Afferent.Render.barrierToCommand? kind with
      | some cmd =>
        coalesceStepCommand state cmd
      | none =>
        let (state, out0) := flushCoalesceBuckets state
        ({ state with emittedBarriers := state.emittedBarriers + 1 }, out0.push (.barrier kind))
    | .frameStart frameId =>
      let (state, out) := flushCoalesceBuckets state
      (state, out.push (.frameStart frameId))
    | .frameEnd frameId =>
      let (state, out) := flushCoalesceBuckets state
      (state, out.push (.frameEnd frameId))
  done state := (flushCoalesceBuckets state).2

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

private structure SinkFoldState where
  packets : Nat := 0
  drawCallNs : Nat := 0

private def consumePacket (reg : FontRegistry) (sink : SinkFoldState) (packet : DrawPacket)
    : CanvasM SinkFoldState := do
  let ns ← executeDrawPacket reg packet
  pure {
    packets := sink.packets + 1
    drawCallNs := sink.drawCallNs + ns
  }

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

  let tRun0 ← IO.monoNanosNow
  let ((coalesceState, packetState), sinkState) ←
    Afferent.Render.Transducer.runFoldWithStateM pipeline stream ({} : SinkFoldState)
      (consumePacket reg)
  let tRun1 ← IO.monoNanosNow

  let timeTotalMs := (tRun1 - tRun0).toFloat / 1000000.0
  let timeDrawCallsMs := sinkState.drawCallNs.toFloat / 1000000.0
  let timePipelineMs := max 0.0 (timeTotalMs - timeDrawCallsMs)
  let timeSinkMs := timeDrawCallsMs

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
    packets := sinkState.packets
    stages := #[
      { name := "stream-pipeline", inputCount := stream.size, outputCount := sinkState.packets, elapsedMs := timePipelineMs },
      { name := "sink", inputCount := sinkState.packets, outputCount := sinkState.packets, elapsedMs := timeSinkMs }
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
  let pipeline := Afferent.Render.Transducer.compose coalesceTransducer packetTransducer

  let mut transducerState := pipeline.init
  let mut sinkState : SinkFoldState := {}

  let stepEvent
      (state : CoalesceTransducerState × PacketTransducerState)
      (sink : SinkFoldState)
      (ev : Afferent.Render.RenderEvent)
      : CanvasM ((CoalesceTransducerState × PacketTransducerState) × SinkFoldState) := do
    let (next, packets) := pipeline.step state ev
    let mut sink := sink
    for packet in packets do
      sink ← consumePacket reg sink packet
    pure (next, sink)

  let tRun0 ← IO.monoNanosNow
  let (s0, k0) ← stepEvent transducerState sinkState (.frameStart 0)
  transducerState := s0
  sinkState := k0
  for cmd in cmds do
    let (s, k) ← stepEvent transducerState sinkState (Afferent.Render.eventOfCommand cmd)
    transducerState := s
    sinkState := k
  let (s1, k1) ← stepEvent transducerState sinkState (.frameEnd 0)
  transducerState := s1
  sinkState := k1
  for packet in pipeline.done transducerState do
    sinkState ← consumePacket reg sinkState packet
  let tRun1 ← IO.monoNanosNow

  let (_coalesceState, packetState) := transducerState
  let timeTotalMs := (tRun1 - tRun0).toFloat / 1000000.0
  let timeDrawCallsMs := sinkState.drawCallNs.toFloat / 1000000.0
  let timePipelineMs := max 0.0 (timeTotalMs - timeDrawCallsMs)

  pure { packetState.stats with
    timeFlattenMs := 0.0
    timeCoalesceMs := 0.0
    timeBatchLoopMs := timePipelineMs
    timeDrawCallsMs := timeDrawCallsMs
    timeTextPackMs := 0.0
    timeTextFFIMs := 0.0 }

/-- Execute an array of RenderCommands using the render stream pipeline. -/
def executeCommandsBatched (reg : FontRegistry)
    (cmds : Array Afferent.Arbor.RenderCommand) : CanvasM Unit := do
  let _ ← executeCommandsBatchedWithStats reg cmds

end Afferent.Widget
