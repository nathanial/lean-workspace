/-
  Afferent Render Stream Events
  First-class stream IR for command execution.
-/
import Afferent.UI.Arbor

namespace Afferent.Render

open Afferent
open Afferent.Arbor

/-- Ordering barrier in the render stream.
    Barriers are explicit, first-class events so stream transforms can preserve
    semantic boundaries while still reordering within safe regions. -/
inductive BarrierKind where
  | pushClip (rect : Rect)
  | popClip
  | pushTranslate (dx dy : Float)
  | pushRotate (angle : Float)
  | pushScale (sx sy : Float)
  | popTransform
  | save
  | restore
  | flush
  deriving Repr, BEq, Inhabited

/-- Event in the render stream. -/
inductive RenderEvent where
  | frameStart (frameId : Nat)
  | frameEnd (frameId : Nat)
  | barrier (kind : BarrierKind)
  | cmd (command : RenderCommand)
  deriving Repr

/-- First-class render stream representation. -/
abbrev RenderStream := Array RenderEvent

/-- Extract barrier kind from a render command when the command is state/order sensitive. -/
def barrierKind? : RenderCommand → Option BarrierKind
  | .pushClip rect => some (.pushClip rect)
  | .popClip => some .popClip
  | .pushTranslate dx dy => some (.pushTranslate dx dy)
  | .pushRotate angle => some (.pushRotate angle)
  | .pushScale sx sy => some (.pushScale sx sy)
  | .popTransform => some .popTransform
  | .save => some .save
  | .restore => some .restore
  | _ => none

/-- Convert barrier kind back to its canonical RenderCommand when executable. -/
def barrierToCommand? : BarrierKind → Option RenderCommand
  | .pushClip rect => some (.pushClip rect)
  | .popClip => some .popClip
  | .pushTranslate dx dy => some (.pushTranslate dx dy)
  | .pushRotate angle => some (.pushRotate angle)
  | .pushScale sx sy => some (.pushScale sx sy)
  | .popTransform => some .popTransform
  | .save => some .save
  | .restore => some .restore
  | .flush => none

/-- Convert one command into one stream event. -/
def eventOfCommand (cmd : RenderCommand) : RenderEvent :=
  match barrierKind? cmd with
  | some kind => .barrier kind
  | none => .cmd cmd

/-- Build a frame-scoped stream from a command array. -/
def streamFromCommands (cmds : Array RenderCommand) (frameId : Nat := 0) : RenderStream := Id.run do
  let mut stream : RenderStream := #[.frameStart frameId]
  for cmd in cmds do
    stream := stream.push (eventOfCommand cmd)
  stream := stream.push (.frameEnd frameId)
  stream

/-- Convert stream events back to executable render commands.
    Frame markers are intentionally dropped. -/
def commandsFromStream (stream : RenderStream) : Array RenderCommand :=
  stream.foldl (init := #[]) fun acc ev =>
    match ev with
    | .cmd cmd => acc.push cmd
    | .barrier kind =>
      match barrierToCommand? kind with
      | some cmd => acc.push cmd
      | none => acc
    | .frameStart _ | .frameEnd _ => acc

/-- Explicit flush event helper. -/
def flushEvent : RenderEvent := .barrier .flush

end Afferent.Render
