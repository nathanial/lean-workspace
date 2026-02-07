/-
  Afferent Backend Execute Tests
  Regression tests for clip stack command semantics.
-/
import Afferent.Tests.Framework
import Afferent.Widget.Backend.Execute

namespace Afferent.Tests.BackendExecuteTests

open Crucible
open Afferent
open Afferent.Arbor
open Afferent.Widget

testSuite "Backend Execute Tests"

test "clipStackAction maps popClip to pop" := do
  match clipStackAction? .popClip with
  | some .pop => pure ()
  | _ => ensure false "Expected popClip to map to ClipStackAction.pop"

test "clipStackAction maps pushClip to push with same rect" := do
  let rect := Rect.mk' 4 8 120 80
  match clipStackAction? (.pushClip rect) with
  | some (.push pushedRect) =>
    ensure (pushedRect == rect) "Expected pushClip rect to be preserved"
  | _ =>
    ensure false "Expected pushClip to map to ClipStackAction.push"

test "nested clip pop removes only inner clip" := do
  let outer := Rect.mk' 0 0 200 140
  let inner := Rect.mk' 20 12 80 60
  let cmds : Array RenderCommand := #[
    .pushClip outer,
    .pushClip inner,
    .popClip
  ]
  let state :=
    cmds.foldl (init := CanvasState.default) fun s cmd =>
      match clipStackAction? cmd with
      | some action => action.applyToState s
      | none => s

  ensure (state.clipStack.size == 1) s!"Expected one clip remaining, got {state.clipStack.size}"
  match state.effectiveClipRect with
  | some clip =>
    shouldBeNear clip.x outer.x
    shouldBeNear clip.y outer.y
    shouldBeNear clip.width outer.width
    shouldBeNear clip.height outer.height
  | none =>
    ensure false "Expected outer clip to remain after popping inner clip"

end Afferent.Tests.BackendExecuteTests
