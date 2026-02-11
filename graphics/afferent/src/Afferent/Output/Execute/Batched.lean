/-
  Afferent Widget Backend Batched Execution
-/
import Afferent.Output.Canvas
import Afferent.Core.Transform
import Afferent.Graphics.Text.Font
import Afferent.Graphics.Text.Measurer
import Afferent.UI.Arbor
import Afferent.Output.Execute.Interpreter
import Afferent.Output.Execute.Batches
import Afferent.Output.Execute.Coalesce

namespace Afferent.Widget

open Afferent
open Afferent.Arbor

/-- Snap text positions to device pixels for axis-aligned transforms (scale + translate only). -/
private def snapTextPosition (x y : Float) (transform : Transform) : (Float × Float) :=
  let eps : Float := 1.0e-4
  let axisAligned := Float.abs transform.b <= eps && Float.abs transform.c <= eps
  if axisAligned && transform.a != 0.0 && transform.d != 0.0 then
    let snappedX := (Float.round (transform.a * x + transform.tx) - transform.tx) / transform.a
    let snappedY := (Float.round (transform.d * y + transform.ty) - transform.ty) / transform.d
    (snappedX, snappedY)
  else
    (x, y)

private structure BatchState where
  rectBatch : Array RectBatchEntry
  strokeRectBatch : Array StrokeRectBatchEntry
  currentStrokeLineWidth : Float
  circleBatch : Array CircleBatchEntry
  strokeCircleBatch : Array StrokeCircleBatchEntry
  currentStrokeCircleLineWidth : Float
  textBatch : Array TextBatchEntry
  currentTextFontId : Option FontId
  fragmentParamsBatch : Array Float
  currentFragmentHash : Option UInt64
  stats : BatchStats
  drawCallTimeNs : Nat

private def initBatchState (totalCommands : Nat) : BatchState :=
  { rectBatch := #[]
    strokeRectBatch := #[]
    currentStrokeLineWidth := 0.0
    circleBatch := #[]
    strokeCircleBatch := #[]
    currentStrokeCircleLineWidth := 0.0
    textBatch := #[]
    currentTextFontId := none
    fragmentParamsBatch := #[]
    currentFragmentHash := none
    stats := { totalCommands := totalCommands }
    drawCallTimeNs := 0 }

private def coalesceCommandsWithClip (bounded : Array BoundedCommand) : Array RenderCommand :=
  let cmds := coalesceByCategoryWithClip bounded
  let cmds := mergeInstancedPolygons cmds
  let cmds := mergeInstancedArcs cmds
  cmds

private def computeLineMeta (lineCmds : Array RenderCommand) : (Nat × Float) :=
  Id.run do
    let mut lineCount : Nat := 0
    let mut uniformLineWidth : Float := 1.0
    for cmd in lineCmds do
      match cmd with
      | .strokeLine _ _ _ lw =>
        if lineCount == 0 then uniformLineWidth := lw
        lineCount := lineCount + 1
      | .strokeLineBatch _ count lw =>
        if lineCount == 0 then uniformLineWidth := lw
        lineCount := lineCount + count
      | _ => pure ()
    return (lineCount, uniformLineWidth)

private def ensureLineBuffer (lineCount : Nat) : CanvasM (Option FFI.FloatBuffer) := do
  if lineCount == 0 then
    pure none
  else
    let requiredFloats := lineCount * 9
    let canvas ← CanvasM.getCanvas
    let canvas ←
      match canvas.floatBuffer with
      | some buf =>
        if canvas.floatBufferCapacity >= requiredFloats then
          pure canvas
        else
          FFI.FloatBuffer.destroy buf
          let newBuf ← FFI.FloatBuffer.create requiredFloats.toUSize
          pure { canvas with floatBuffer := some newBuf, floatBufferCapacity := requiredFloats }
      | none =>
        let newBuf ← FFI.FloatBuffer.create requiredFloats.toUSize
        pure { canvas with floatBuffer := some newBuf, floatBufferCapacity := requiredFloats }
    CanvasM.setCanvas canvas
    pure canvas.floatBuffer

private def flushRects (state : BatchState) : CanvasM BatchState := do
  if state.rectBatch.isEmpty then
    pure state
  else
    let t0 ← IO.monoNanosNow
    executeFillRectBatch state.rectBatch
    let t1 ← IO.monoNanosNow
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      rectsBatched := state.stats.rectsBatched + state.rectBatch.size }
    pure { state with
      rectBatch := #[]
      stats := stats
      drawCallTimeNs := state.drawCallTimeNs + (t1 - t0) }

private def flushStrokeRects (state : BatchState) : CanvasM BatchState := do
  if state.strokeRectBatch.isEmpty then
    pure state
  else
    let t0 ← IO.monoNanosNow
    executeStrokeRectBatch state.strokeRectBatch state.currentStrokeLineWidth
    let t1 ← IO.monoNanosNow
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      strokeRectsBatched := state.stats.strokeRectsBatched + state.strokeRectBatch.size }
    pure { state with
      strokeRectBatch := #[]
      stats := stats
      drawCallTimeNs := state.drawCallTimeNs + (t1 - t0) }

private def flushCircles (state : BatchState) : CanvasM BatchState := do
  if state.circleBatch.isEmpty then
    pure state
  else
    let t0 ← IO.monoNanosNow
    executeFillCircleBatch state.circleBatch
    let t1 ← IO.monoNanosNow
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      circlesBatched := state.stats.circlesBatched + state.circleBatch.size }
    pure { state with
      circleBatch := #[]
      stats := stats
      drawCallTimeNs := state.drawCallTimeNs + (t1 - t0) }

private def flushStrokeCircles (state : BatchState) : CanvasM BatchState := do
  if state.strokeCircleBatch.isEmpty then
    pure state
  else
    let t0 ← IO.monoNanosNow
    executeStrokeCircleBatch state.strokeCircleBatch state.currentStrokeCircleLineWidth
    let t1 ← IO.monoNanosNow
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      circlesBatched := state.stats.circlesBatched + state.strokeCircleBatch.size }
    pure { state with
      strokeCircleBatch := #[]
      stats := stats
      drawCallTimeNs := state.drawCallTimeNs + (t1 - t0) }

private def flushTexts (reg : FontRegistry) (state : BatchState) : CanvasM BatchState := do
  if state.textBatch.isEmpty then
    pure state
  else
    match state.currentTextFontId with
    | some fontId =>
      match reg.get fontId with
      | some font =>
        let t0 ← IO.monoNanosNow
        executeTextBatch font state.textBatch
        let t1 ← IO.monoNanosNow
        let stats := { state.stats with
          batchedCalls := state.stats.batchedCalls + 1
          textsBatched := state.stats.textsBatched + state.textBatch.size }
        pure { state with
          textBatch := #[]
          currentTextFontId := none
          stats := stats
          drawCallTimeNs := state.drawCallTimeNs + (t1 - t0) }
      | none =>
        pure { state with textBatch := #[], currentTextFontId := none }
    | none =>
      pure { state with textBatch := #[], currentTextFontId := none }

private def flushFragments (state : BatchState) : CanvasM BatchState := do
  if state.fragmentParamsBatch.isEmpty then
    pure state
  else
    match state.currentFragmentHash with
    | some fragmentHash =>
      let canvas ← CanvasM.getCanvas
      let cache ← canvas.fragmentCache.get
      let (maybePipeline, newCache) ← Shader.getOrCompileGlobal cache canvas.ctx.renderer fragmentHash
      canvas.fragmentCache.set newCache
      match maybePipeline with
      | some pipeline =>
        let t0 ← IO.monoNanosNow
        let (canvasWidth, canvasHeight) ← canvas.ctx.getCurrentSize
        match (← Shader.lookupFragment fragmentHash) with
        | some fragment =>
          let params := state.fragmentParamsBatch
          if fragment.paramsPackedFloatCount == fragment.paramsFloatCount then
            FFI.Fragment.draw canvas.ctx.renderer pipeline params canvasWidth canvasHeight
          else if fragment.paramsPackedFloatCount == 0 ||
              params.size % fragment.paramsPackedFloatCount != 0 then
            FFI.Fragment.draw canvas.ctx.renderer pipeline params canvasWidth canvasHeight
          else
            let batchCount := params.size / fragment.paramsPackedFloatCount
            let requiredFloats := batchCount * fragment.paramsFloatCount
            let canvas ← CanvasM.getCanvas
            let canvas ←
              match canvas.fragmentBuffer with
              | some buf =>
                if canvas.fragmentBufferCapacity >= requiredFloats then
                  pure canvas
                else
                  FFI.FloatBuffer.destroy buf
                  let newBuf ← FFI.FloatBuffer.create requiredFloats.toUSize
                  pure { canvas with fragmentBuffer := some newBuf, fragmentBufferCapacity := requiredFloats }
              | none =>
                let newBuf ← FFI.FloatBuffer.create requiredFloats.toUSize
                pure { canvas with fragmentBuffer := some newBuf, fragmentBufferCapacity := requiredFloats }
            CanvasM.setCanvas canvas
            match canvas.fragmentBuffer with
            | some buf =>
              FFI.FloatBuffer.writePadded buf params
                fragment.paramsPackedFloatCount.toUInt32
                fragment.paramsFloatCount.toUInt32
                fragment.paramsPackOffsets
              FFI.Fragment.drawBuffer canvas.ctx.renderer pipeline buf canvasWidth canvasHeight
            | none =>
              FFI.Fragment.draw canvas.ctx.renderer pipeline params canvasWidth canvasHeight
        | none =>
          FFI.Fragment.draw canvas.ctx.renderer pipeline state.fragmentParamsBatch canvasWidth canvasHeight
        let t1 ← IO.monoNanosNow
        let stats := { state.stats with batchedCalls := state.stats.batchedCalls + 1 }
        pure { state with
          fragmentParamsBatch := #[]
          currentFragmentHash := none
          stats := stats
          drawCallTimeNs := state.drawCallTimeNs + (t1 - t0) }
      | none =>
        pure { state with fragmentParamsBatch := #[], currentFragmentHash := none }
    | none =>
      pure { state with fragmentParamsBatch := #[], currentFragmentHash := none }

private def flushAll (reg : FontRegistry) (state : BatchState) : CanvasM BatchState := do
  let state ← flushRects state
  let state ← flushStrokeRects state
  let state ← flushCircles state
  let state ← flushStrokeCircles state
  let state ← flushTexts reg state
  let state ← flushFragments state
  pure state

private def flushForFillRect (reg : FontRegistry) (state : BatchState) : CanvasM BatchState := do
  let state ← flushStrokeRects state
  let state ← flushCircles state
  let state ← flushTexts reg state
  pure state

private def flushForStrokeRect (reg : FontRegistry) (state : BatchState) : CanvasM BatchState := do
  let state ← flushRects state
  let state ← flushCircles state
  let state ← flushTexts reg state
  pure state

private def flushForFillCircle (reg : FontRegistry) (state : BatchState) : CanvasM BatchState := do
  let state ← flushRects state
  let state ← flushStrokeRects state
  let state ← flushStrokeCircles state
  let state ← flushTexts reg state
  pure state

private def flushForStrokeCircle (reg : FontRegistry) (state : BatchState) : CanvasM BatchState := do
  let state ← flushRects state
  let state ← flushStrokeRects state
  let state ← flushCircles state
  let state ← flushTexts reg state
  pure state

private def flushForFillText (state : BatchState) : CanvasM BatchState := do
  let state ← flushRects state
  let state ← flushStrokeRects state
  let state ← flushCircles state
  let state ← flushStrokeCircles state
  pure state

private def flushForDrawFragment (reg : FontRegistry) (state : BatchState) : CanvasM BatchState := do
  let state ← flushRects state
  let state ← flushStrokeRects state
  let state ← flushCircles state
  let state ← flushStrokeCircles state
  let state ← flushTexts reg state
  pure state

private def handleFillRect (reg : FontRegistry) (state : BatchState) (rect : Rect)
    (color : Color) (cornerRadius : Float) : CanvasM BatchState := do
  let state ←
    if state.strokeRectBatch.isEmpty && state.circleBatch.isEmpty &&
        state.textBatch.isEmpty then
      pure state
    else
      flushForFillRect reg state
  let entry : RectBatchEntry := {
    x := rect.origin.x, y := rect.origin.y
    width := rect.size.width, height := rect.size.height
    r := color.r, g := color.g, b := color.b, a := color.a
    cornerRadius := cornerRadius
  }
  pure { state with rectBatch := state.rectBatch.push entry }

private def handleStrokeRect (reg : FontRegistry) (state : BatchState) (rect : Rect)
    (color : Color) (lineWidth : Float) (cornerRadius : Float) : CanvasM BatchState := do
  let state ←
    if state.rectBatch.isEmpty && state.circleBatch.isEmpty &&
        state.textBatch.isEmpty then
      pure state
    else
      flushForStrokeRect reg state
  if state.strokeRectBatch.isEmpty || state.currentStrokeLineWidth == lineWidth then
    let entry : StrokeRectBatchEntry := {
      x := rect.origin.x, y := rect.origin.y
      width := rect.size.width, height := rect.size.height
      r := color.r, g := color.g, b := color.b, a := color.a
      cornerRadius := cornerRadius
    }
    pure { state with
      strokeRectBatch := state.strokeRectBatch.push entry
      currentStrokeLineWidth := lineWidth }
  else
    let state ← flushStrokeRects state
    let entry : StrokeRectBatchEntry := {
      x := rect.origin.x, y := rect.origin.y
      width := rect.size.width, height := rect.size.height
      r := color.r, g := color.g, b := color.b, a := color.a
      cornerRadius := cornerRadius
    }
    pure { state with
      strokeRectBatch := #[entry]
      currentStrokeLineWidth := lineWidth }

private def handleFillCircle (reg : FontRegistry) (state : BatchState) (center : Point)
    (radius : Float) (color : Color) : CanvasM BatchState := do
  let state ←
    if state.rectBatch.isEmpty && state.strokeRectBatch.isEmpty &&
        state.strokeCircleBatch.isEmpty && state.textBatch.isEmpty then
      pure state
    else
      flushForFillCircle reg state
  let entry : CircleBatchEntry := {
    centerX := center.x, centerY := center.y, radius := radius
    r := color.r, g := color.g, b := color.b, a := color.a
  }
  pure { state with circleBatch := state.circleBatch.push entry }

private def handleFillCircleBatch (reg : FontRegistry) (state : BatchState)
    (data : Array Float) (count : Nat) : CanvasM BatchState := do
  let state ← flushCircles state
  if count > 0 then
    let t0 ← IO.monoNanosNow
    executeCommand reg (.fillCircleBatch data count)
    let t1 ← IO.monoNanosNow
    let stats := { state.stats with
      batchedCalls := state.stats.batchedCalls + 1
      circlesBatched := state.stats.circlesBatched + count }
    pure { state with
      stats := stats
      drawCallTimeNs := state.drawCallTimeNs + (t1 - t0) }
  else
    pure state

private def handleStrokeCircle (reg : FontRegistry) (state : BatchState) (center : Point)
    (radius : Float) (color : Color) (lineWidth : Float) : CanvasM BatchState := do
  let state ←
    if state.rectBatch.isEmpty && state.strokeRectBatch.isEmpty &&
        state.circleBatch.isEmpty && state.textBatch.isEmpty then
      pure state
    else
      flushForStrokeCircle reg state
  if state.strokeCircleBatch.isEmpty || state.currentStrokeCircleLineWidth == lineWidth then
    let entry : StrokeCircleBatchEntry := {
      centerX := center.x, centerY := center.y, radius := radius
      r := color.r, g := color.g, b := color.b, a := color.a
    }
    pure { state with
      strokeCircleBatch := state.strokeCircleBatch.push entry
      currentStrokeCircleLineWidth := lineWidth }
  else
    let state ← flushStrokeCircles state
    let entry : StrokeCircleBatchEntry := {
      centerX := center.x, centerY := center.y, radius := radius
      r := color.r, g := color.g, b := color.b, a := color.a
    }
    pure { state with
      strokeCircleBatch := #[entry]
      currentStrokeCircleLineWidth := lineWidth }

private def handleFillText (reg : FontRegistry) (state : BatchState) (text : String)
    (x y : Float) (fontId : FontId) (color : Color) : CanvasM BatchState := do
  let state ←
    if state.rectBatch.isEmpty && state.strokeRectBatch.isEmpty &&
        state.circleBatch.isEmpty && state.strokeCircleBatch.isEmpty then
      pure state
    else
      flushForFillText state
  let canvas ← CanvasM.getCanvas
  let transform := canvas.state.transform
  let transformArr := transform.toArray
  let (sx, sy) := snapTextPosition x y transform
  if state.textBatch.isEmpty || state.currentTextFontId == some fontId then
    let entry : TextBatchEntry := {
      text, x := sx, y := sy
      r := color.r, g := color.g, b := color.b, a := color.a
      transform := transformArr
    }
    pure { state with
      textBatch := state.textBatch.push entry
      currentTextFontId := some fontId }
  else
    let state ← flushTexts reg state
    let entry : TextBatchEntry := {
      text, x := sx, y := sy
      r := color.r, g := color.g, b := color.b, a := color.a
      transform := transformArr
    }
    pure { state with
      textBatch := #[entry]
      currentTextFontId := some fontId }

private def handleDrawFragment (reg : FontRegistry) (state : BatchState) (fragmentHash : UInt64)
    (params : Array Float) : CanvasM BatchState := do
  let state ←
    if state.rectBatch.isEmpty && state.strokeRectBatch.isEmpty &&
        state.circleBatch.isEmpty && state.strokeCircleBatch.isEmpty &&
        state.textBatch.isEmpty then
      pure state
    else
      flushForDrawFragment reg state
  if state.currentFragmentHash == some fragmentHash then
    let mut merged := state.fragmentParamsBatch
    for value in params do
      merged := merged.push value
    pure { state with fragmentParamsBatch := merged }
  else
    let state ← if state.fragmentParamsBatch.isEmpty then
      pure state
    else
      flushFragments state
    pure { state with
      fragmentParamsBatch := params
      currentFragmentHash := some fragmentHash }

private def handleNonBatchable (reg : FontRegistry) (state : BatchState)
    (cmd : RenderCommand) : CanvasM BatchState := do
  let state ← flushAll reg state
  executeCommand reg cmd
  let stats := { state.stats with individualCalls := state.stats.individualCalls + 1 }
  pure { state with stats := stats }

private def handleCommand (reg : FontRegistry) (state : BatchState)
    (cmd : RenderCommand) : CanvasM BatchState := do
  match cmd with
  | .fillRect rect color cornerRadius =>
    handleFillRect reg state rect color cornerRadius
  | .strokeRect rect color lineWidth cornerRadius =>
    handleStrokeRect reg state rect color lineWidth cornerRadius
  | .fillCircle center radius color =>
    handleFillCircle reg state center radius color
  | .fillCircleBatch data count =>
    handleFillCircleBatch reg state data count
  | .strokeCircle center radius color lineWidth =>
    handleStrokeCircle reg state center radius color lineWidth
  | .fillText text x y fontId color =>
    handleFillText reg state text x y fontId color
  | .strokeLine _ _ _ _ =>
    handleNonBatchable reg state cmd
  | .drawFragment fragmentHash _ params _ =>
    handleDrawFragment reg state fragmentHash params
  | _ =>
    handleNonBatchable reg state cmd

private def processCommands (reg : FontRegistry) (cmds : Array RenderCommand)
    (state : BatchState) : CanvasM BatchState := do
  let mut state := state
  let mut i := 0
  while h : i < cmds.size do
    state ← handleCommand reg state cmds[i]
    i := i + 1
  flushAll reg state

private def drawLines (state : BatchState) (lineCmds : Array RenderCommand) (lineCount : Nat)
    (uniformLineWidth : Float) (lineBuffer : Option FFI.FloatBuffer)
    (canvasWidth canvasHeight : Float) : CanvasM BatchState := do
  if lineCount == 0 then
    pure state
  else
    match lineBuffer with
    | some buf =>
      let mut bufIdx : USize := 0
      for cmd in lineCmds do
        match cmd with
        | .strokeLine p1 p2 color _ =>
          buf.setVec9 bufIdx p1.x p1.y p2.x p2.y color.r color.g color.b color.a 0.0
          bufIdx := bufIdx + 9
        | .strokeLineBatch data count _ =>
          if count > 0 then
            for j in [:count] do
              let base := j * 9
              let x1 := data[base]!
              let y1 := data[base + 1]!
              let x2 := data[base + 2]!
              let y2 := data[base + 3]!
              let r := data[base + 4]!
              let g := data[base + 5]!
              let b := data[base + 6]!
              let a := data[base + 7]!
              let pad := data[base + 8]!
              buf.setVec9 bufIdx x1 y1 x2 y2 r g b a pad
              bufIdx := bufIdx + 9
        | _ => pure ()
      let canvas ← CanvasM.getCanvas
      let t0 ← IO.monoNanosNow
      canvas.ctx.renderer.drawLineBatchBuffer buf lineCount.toUInt32 uniformLineWidth canvasWidth canvasHeight
      let t1 ← IO.monoNanosNow
      let stats := { state.stats with
        linesBatched := lineCount
        batchedCalls := state.stats.batchedCalls + 1 }
      pure { state with
        stats := stats
        drawCallTimeNs := state.drawCallTimeNs + (t1 - t0) }
    | none => pure state

/-- Maintain transform stack while streaming commands, matching `computeBoundedCommands`. -/
private def applyTransformStack (stack : Array Transform) (cmd : RenderCommand) : Array Transform :=
  match cmd with
  | .pushTranslate dx dy =>
      let current := stack.back?.getD Transform.identity
      stack.push (current.translated dx dy)
  | .pushScale sx sy =>
      let current := stack.back?.getD Transform.identity
      stack.push (current.scaled sx sy)
  | .pushRotate angle =>
      let current := stack.back?.getD Transform.identity
      stack.push (current.rotated angle)
  | .save =>
      stack.push (stack.back?.getD Transform.identity)
  | .popTransform | .restore =>
      if stack.size > 1 then stack.pop else stack
  | _ => stack

/-- Flatten only the geometry needed by batch executors.
    Avoids bounds computation used by overlap/coalescing paths. -/
private def flattenForBatch (cmd : RenderCommand) (transform : Transform) : RenderCommand :=
  if transform == Transform.identity then
    cmd
  else
    match cmd with
    | .fillRect rect color cornerRadius =>
      let topLeft := transform.apply rect.origin
      .fillRect ⟨topLeft, rect.size⟩ color cornerRadius
    | .fillRectStyle rect style cornerRadius =>
      let topLeft := transform.apply rect.origin
      .fillRectStyle ⟨topLeft, rect.size⟩ style cornerRadius
    | .strokeRect rect color lineWidth cornerRadius =>
      let topLeft := transform.apply rect.origin
      .strokeRect ⟨topLeft, rect.size⟩ color lineWidth cornerRadius
    | .fillCircle center radius color =>
      .fillCircle (transform.apply center) radius color
    | .strokeCircle center radius color lineWidth =>
      .strokeCircle (transform.apply center) radius color lineWidth
    | .strokeLineBatch data count lineWidth =>
      Id.run do
        if count == 0 then
          return .strokeLineBatch data count lineWidth
        let mut out : Array Float := Array.mkEmpty data.size
        for i in [0:count] do
          let base := i * 9
          let x1 := data[base]!
          let y1 := data[base + 1]!
          let x2 := data[base + 2]!
          let y2 := data[base + 3]!
          let tp1 := transform.apply ⟨x1, y1⟩
          let tp2 := transform.apply ⟨x2, y2⟩
          let r := data[base + 4]!
          let g := data[base + 5]!
          let b := data[base + 6]!
          let a := data[base + 7]!
          let p := data[base + 8]!
          out := out.push tp1.x |>.push tp1.y |>.push tp2.x |>.push tp2.y
                     |>.push r |>.push g |>.push b |>.push a |>.push p
        return .strokeLineBatch out count lineWidth
    | _ => cmd

/-- Incremental command sink that directly feeds the batch executor.
    This avoids building intermediate bounded/coalesced command arrays. -/
structure BatchCommandSink where
  reg : FontRegistry
  canvasRef : IO.Ref Canvas
  stateRef : IO.Ref BatchState
  totalCommandsRef : IO.Ref Nat
  transformStackRef : IO.Ref (Array Transform)

def BatchCommandSink.new (reg : FontRegistry) (canvas : Canvas) : IO BatchCommandSink := do
  pure {
    reg := reg
    canvasRef := (← IO.mkRef canvas)
    stateRef := (← IO.mkRef (initBatchState 0))
    totalCommandsRef := (← IO.mkRef 0)
    transformStackRef := (← IO.mkRef #[Transform.identity])
  }

private def BatchCommandSink.bumpCommandCount (sink : BatchCommandSink) : IO Unit :=
  sink.totalCommandsRef.modify (· + 1)

private def BatchCommandSink.bumpCommandCountBy (sink : BatchCommandSink) (count : Nat) : IO Unit :=
  if count > 0 then
    sink.totalCommandsRef.modify (· + count)
  else
    pure ()

private def BatchCommandSink.runStateStep (sink : BatchCommandSink)
    (step : BatchState → CanvasM BatchState) : IO BatchState := do
  let state ← sink.stateRef.get
  let canvas ← sink.canvasRef.get
  let (state', canvas') ← CanvasM.run canvas (step state)
  sink.stateRef.set state'
  sink.canvasRef.set canvas'
  pure state'

private def BatchCommandSink.processFillRectFlat (sink : BatchCommandSink) (rect : Rect)
    (color : Color) (cornerRadius : Float) : IO Unit := do
  let state0 ← sink.stateRef.get
  let state ←
    if state0.strokeRectBatch.isEmpty && state0.circleBatch.isEmpty &&
        state0.textBatch.isEmpty then
      pure state0
    else
      sink.runStateStep (flushForFillRect sink.reg)
  let entry : RectBatchEntry := {
    x := rect.origin.x, y := rect.origin.y
    width := rect.size.width, height := rect.size.height
    r := color.r, g := color.g, b := color.b, a := color.a
    cornerRadius := cornerRadius
  }
  sink.stateRef.set { state with rectBatch := state.rectBatch.push entry }

private def BatchCommandSink.processStrokeRectFlat (sink : BatchCommandSink) (rect : Rect)
    (color : Color) (lineWidth : Float) (cornerRadius : Float) : IO Unit := do
  let state0 ← sink.stateRef.get
  let state ←
    if state0.rectBatch.isEmpty && state0.circleBatch.isEmpty &&
        state0.textBatch.isEmpty then
      pure state0
    else
      sink.runStateStep (flushForStrokeRect sink.reg)
  if state.strokeRectBatch.isEmpty || state.currentStrokeLineWidth == lineWidth then
    let entry : StrokeRectBatchEntry := {
      x := rect.origin.x, y := rect.origin.y
      width := rect.size.width, height := rect.size.height
      r := color.r, g := color.g, b := color.b, a := color.a
      cornerRadius := cornerRadius
    }
    sink.stateRef.set { state with
      strokeRectBatch := state.strokeRectBatch.push entry
      currentStrokeLineWidth := lineWidth }
  else
    let state ← sink.runStateStep flushStrokeRects
    let entry : StrokeRectBatchEntry := {
      x := rect.origin.x, y := rect.origin.y
      width := rect.size.width, height := rect.size.height
      r := color.r, g := color.g, b := color.b, a := color.a
      cornerRadius := cornerRadius
    }
    sink.stateRef.set { state with
      strokeRectBatch := #[entry]
      currentStrokeLineWidth := lineWidth }

private def BatchCommandSink.processFillCircleFlat (sink : BatchCommandSink) (center : Point)
    (radius : Float) (color : Color) : IO Unit := do
  let state0 ← sink.stateRef.get
  let state ←
    if state0.rectBatch.isEmpty && state0.strokeRectBatch.isEmpty &&
        state0.strokeCircleBatch.isEmpty && state0.textBatch.isEmpty then
      pure state0
    else
      sink.runStateStep (flushForFillCircle sink.reg)
  let entry : CircleBatchEntry := {
    centerX := center.x, centerY := center.y, radius := radius
    r := color.r, g := color.g, b := color.b, a := color.a
  }
  sink.stateRef.set { state with circleBatch := state.circleBatch.push entry }

private def BatchCommandSink.processStrokeCircleFlat (sink : BatchCommandSink) (center : Point)
    (radius : Float) (color : Color) (lineWidth : Float) : IO Unit := do
  let state0 ← sink.stateRef.get
  let state ←
    if state0.rectBatch.isEmpty && state0.strokeRectBatch.isEmpty &&
        state0.circleBatch.isEmpty && state0.textBatch.isEmpty then
      pure state0
    else
      sink.runStateStep (flushForStrokeCircle sink.reg)
  if state.strokeCircleBatch.isEmpty || state.currentStrokeCircleLineWidth == lineWidth then
    let entry : StrokeCircleBatchEntry := {
      centerX := center.x, centerY := center.y, radius := radius
      r := color.r, g := color.g, b := color.b, a := color.a
    }
    sink.stateRef.set { state with
      strokeCircleBatch := state.strokeCircleBatch.push entry
      currentStrokeCircleLineWidth := lineWidth }
  else
    let state ← sink.runStateStep flushStrokeCircles
    let entry : StrokeCircleBatchEntry := {
      centerX := center.x, centerY := center.y, radius := radius
      r := color.r, g := color.g, b := color.b, a := color.a
    }
    sink.stateRef.set { state with
      strokeCircleBatch := #[entry]
      currentStrokeCircleLineWidth := lineWidth }

private def BatchCommandSink.processFillTextFlat (sink : BatchCommandSink) (text : String)
    (x y : Float) (fontId : FontId) (color : Color) : IO Unit := do
  let state0 ← sink.stateRef.get
  let state ←
    if state0.rectBatch.isEmpty && state0.strokeRectBatch.isEmpty &&
        state0.circleBatch.isEmpty && state0.strokeCircleBatch.isEmpty then
      pure state0
    else
      sink.runStateStep flushForFillText
  let canvas ← sink.canvasRef.get
  let transform := canvas.state.transform
  let transformArr := transform.toArray
  let (sx, sy) := snapTextPosition x y transform
  if state.textBatch.isEmpty || state.currentTextFontId == some fontId then
    let entry : TextBatchEntry := {
      text, x := sx, y := sy
      r := color.r, g := color.g, b := color.b, a := color.a
      transform := transformArr
    }
    sink.stateRef.set { state with
      textBatch := state.textBatch.push entry
      currentTextFontId := some fontId }
  else
    let state ← sink.runStateStep (flushTexts sink.reg)
    let entry : TextBatchEntry := {
      text, x := sx, y := sy
      r := color.r, g := color.g, b := color.b, a := color.a
      transform := transformArr
    }
    sink.stateRef.set { state with
      textBatch := #[entry]
      currentTextFontId := some fontId }

private def BatchCommandSink.processFlat (sink : BatchCommandSink)
    (cmd : RenderCommand) : IO Unit := do
  match cmd with
  | .fillRect rect color cornerRadius =>
    sink.processFillRectFlat rect color cornerRadius
  | .strokeRect rect color lineWidth cornerRadius =>
    sink.processStrokeRectFlat rect color lineWidth cornerRadius
  | .fillCircle center radius color =>
    sink.processFillCircleFlat center radius color
  | .strokeCircle center radius color lineWidth =>
    sink.processStrokeCircleFlat center radius color lineWidth
  | .fillText text x y fontId color =>
    sink.processFillTextFlat text x y fontId color
  | _ =>
    let _ ← sink.runStateStep (fun state => handleCommand sink.reg state cmd)
    pure ()

def BatchCommandSink.emit (sink : BatchCommandSink) (cmd : RenderCommand) : IO Unit := do
  let stack ← sink.transformStackRef.get
  let current := stack.back?.getD Transform.identity
  let flatCmd := flattenForBatch cmd current
  sink.processFlat flatCmd
  sink.transformStackRef.set (applyTransformStack stack cmd)
  sink.bumpCommandCount

def BatchCommandSink.emitFillRect (sink : BatchCommandSink) (rect : Rect)
    (color : Color) (cornerRadius : Float) : IO Unit := do
  let stack ← sink.transformStackRef.get
  let current := stack.back?.getD Transform.identity
  let cmd := flattenForBatch (.fillRect rect color cornerRadius) current
  match cmd with
  | .fillRect flatRect flatColor flatCornerRadius =>
    sink.processFillRectFlat flatRect flatColor flatCornerRadius
  | _ =>
    sink.processFlat cmd
  sink.bumpCommandCount

def BatchCommandSink.emitStrokeRect (sink : BatchCommandSink) (rect : Rect)
    (color : Color) (lineWidth : Float) (cornerRadius : Float) : IO Unit := do
  let stack ← sink.transformStackRef.get
  let current := stack.back?.getD Transform.identity
  let cmd := flattenForBatch (.strokeRect rect color lineWidth cornerRadius) current
  match cmd with
  | .strokeRect flatRect flatColor flatLineWidth flatCornerRadius =>
    sink.processStrokeRectFlat flatRect flatColor flatLineWidth flatCornerRadius
  | _ =>
    sink.processFlat cmd
  sink.bumpCommandCount

def BatchCommandSink.emitFillText (sink : BatchCommandSink) (text : String)
    (x y : Float) (font : FontId) (color : Color) : IO Unit := do
  sink.processFillTextFlat text x y font color
  sink.bumpCommandCount

def BatchCommandSink.emitPushClip (sink : BatchCommandSink) (rect : Rect) : IO Unit := do
  sink.processFlat (.pushClip rect)
  sink.bumpCommandCount

def BatchCommandSink.emitPopClip (sink : BatchCommandSink) : IO Unit := do
  sink.processFlat .popClip
  sink.bumpCommandCount

def BatchCommandSink.emitSave (sink : BatchCommandSink) : IO Unit := do
  let stack ← sink.transformStackRef.get
  sink.transformStackRef.set (applyTransformStack stack .save)
  sink.processFlat .save
  sink.bumpCommandCount

def BatchCommandSink.emitRestore (sink : BatchCommandSink) : IO Unit := do
  let stack ← sink.transformStackRef.get
  sink.transformStackRef.set (applyTransformStack stack .restore)
  sink.processFlat .restore
  sink.bumpCommandCount

def BatchCommandSink.emitPushTranslate (sink : BatchCommandSink) (dx dy : Float) : IO Unit := do
  let stack ← sink.transformStackRef.get
  sink.transformStackRef.set (applyTransformStack stack (.pushTranslate dx dy))
  sink.processFlat (.pushTranslate dx dy)
  sink.bumpCommandCount

def BatchCommandSink.emitPopTransform (sink : BatchCommandSink) : IO Unit := do
  let stack ← sink.transformStackRef.get
  sink.transformStackRef.set (applyTransformStack stack .popTransform)
  sink.processFlat .popTransform
  sink.bumpCommandCount

def BatchCommandSink.emitAll (sink : BatchCommandSink) (cmds : Array RenderCommand) : IO Unit := do
  if cmds.isEmpty then
    pure ()
  else
    let mut stack := (← sink.transformStackRef.get)
    for cmd in cmds do
      let current := stack.back?.getD Transform.identity
      let flatCmd := flattenForBatch cmd current
      sink.processFlat flatCmd
      stack := applyTransformStack stack cmd
    sink.transformStackRef.set stack
    sink.bumpCommandCountBy cmds.size

def BatchCommandSink.toRenderSink (sink : BatchCommandSink) : Afferent.Arbor.RenderCommandSink :=
  { emit := sink.emit
    emitAll := sink.emitAll
    emitFillRect? := some sink.emitFillRect
    emitStrokeRect? := some sink.emitStrokeRect
    emitFillText? := some sink.emitFillText
    emitPushClip? := some sink.emitPushClip
    emitPopClip? := some sink.emitPopClip
    emitSave? := some sink.emitSave
    emitRestore? := some sink.emitRestore
    emitPushTranslate? := some sink.emitPushTranslate
    emitPopTransform? := some sink.emitPopTransform }

def BatchCommandSink.finish (sink : BatchCommandSink) : IO (BatchStats × Canvas × Nat) := do
  let tExec0 ← IO.monoNanosNow
  let state' ← sink.runStateStep (flushAll sink.reg)
  let tExec1 ← IO.monoNanosNow
  let canvas' ← sink.canvasRef.get
  let totalCommands ← sink.totalCommandsRef.get
  let executeTimeNs := tExec1 - tExec0
  let executeTimeMs := executeTimeNs.toFloat / 1000000.0
  let drawCallTimeMs := state'.drawCallTimeNs.toFloat / 1000000.0
  let stats := { state'.stats with
    totalCommands := totalCommands
    timeFlattenMs := 0.0
    timeCoalesceMs := 0.0
    timeBatchLoopMs := executeTimeMs
    timeDrawCallsMs := drawCallTimeMs
  }
  pure (stats, canvas', executeTimeNs)

/-- Execute an array of RenderCommands using CanvasM with batching optimization.
    First coalesces commands within scopes to maximize batching opportunities, then
    groups consecutive fillRect commands (per-instance cornerRadius),
    consecutive strokeRect commands with the same lineWidth (per-instance cornerRadius),
    and consecutive fillCircle commands into batched draw calls.
    Returns batch statistics for performance monitoring. -/
def executeCommandsBatchedWithStats (reg : FontRegistry) (cmds : Array Afferent.Arbor.RenderCommand) : CanvasM BatchStats := do
  let canvas ← CanvasM.getCanvas
  let sink ← BatchCommandSink.new reg canvas
  sink.emitAll cmds
  let (stats, canvas', _) ← sink.finish
  CanvasM.setCanvas canvas'
  pure stats

/-- Execute an array of RenderCommands using CanvasM with batching optimization.
    Coalesces commands within scopes to maximize batching, then batches fillRect
    commands with per-instance cornerRadius into a single draw call. -/
def executeCommandsBatched (reg : FontRegistry) (cmds : Array Afferent.Arbor.RenderCommand) : CanvasM Unit := do
  let _ ← executeCommandsBatchedWithStats reg cmds

/-- Execute an array of RenderCommands using CanvasM (unbatched, for compatibility). -/
def executeCommands (reg : FontRegistry) (cmds : Array Afferent.Arbor.RenderCommand) : CanvasM Unit := do
  for cmd in cmds do
    executeCommand reg cmd

end Afferent.Widget
