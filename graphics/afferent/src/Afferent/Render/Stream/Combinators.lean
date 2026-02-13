/-
  Afferent Render Stream Combinators
  Pure manipulation helpers for first-class command streams.
-/
import Afferent.Render.Stream.Event

namespace Afferent.Render

namespace RenderStream

/-- Map events in a stream. -/
def map (f : RenderEvent → RenderEvent) (stream : RenderStream) : RenderStream :=
  Array.map f stream

/-- Keep only events matching a predicate. -/
def filter (p : RenderEvent → Bool) (stream : RenderStream) : RenderStream :=
  Array.filter p stream

/-- Fold stream events. -/
def foldl (f : σ → RenderEvent → σ) (init : σ) (stream : RenderStream) : σ :=
  Array.foldl f init stream

/-- Split stream into windows separated by barrier events.
    The barrier event is included as its own singleton window. -/
def windowByBarrier (stream : RenderStream) : Array RenderStream := Id.run do
  let mut windows : Array RenderStream := #[]
  let mut current : RenderStream := #[]
  for ev in stream do
    match ev with
    | .barrier _ =>
      if !current.isEmpty then
        windows := windows.push current
        current := #[]
      windows := windows.push #[ev]
    | _ =>
      current := current.push ev
  if !current.isEmpty then
    windows := windows.push current
  windows

/-- Convert stream back to command array. -/
def toCommands (stream : RenderStream) : Array Afferent.Arbor.RenderCommand :=
  commandsFromStream stream

/-- Convert command array to frame-scoped stream. -/
def fromCommands (cmds : Array Afferent.Arbor.RenderCommand) (frameId : Nat := 0) : RenderStream :=
  streamFromCommands cmds frameId

end RenderStream

end Afferent.Render
