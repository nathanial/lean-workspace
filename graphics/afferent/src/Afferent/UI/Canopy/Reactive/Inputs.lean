/-
  Canopy Reactive - Input Infrastructure
  Creates trigger events that the demo loop fires when FFI events occur.
-/
import Reactive
import Std.Data.HashMap
import Afferent.UI.Canopy.Reactive.Types
import Afferent.UI.Canopy.Theme
import Afferent.Graphics.Text.Measurer

open Reactive Reactive.Host

namespace Afferent.Canopy.Reactive

/-- Trigger functions to fire from the application loop when FFI events occur. -/
structure ReactiveInputs where
  /-- Fire when a click event occurs (mouse down). -/
  fireClick : ClickData → IO Unit
  /-- Fire when mouse button is released. -/
  fireMouseUp : MouseButtonData → IO Unit
  /-- Fire when mouse position changes (hover). -/
  fireHover : HoverData → IO Unit
  /-- Fire when mouse delta changes (relative movement since last frame). -/
  fireMouseDelta : MouseDeltaData → IO Unit
  /-- Fire when a key is pressed. -/
  fireKey : KeyData → IO Unit
  /-- Fire each frame with delta time (for animations). -/
  fireAnimationFrame : Float → IO Unit
  /-- Fire when scroll wheel is used. -/
  fireScroll : ScrollData → IO Unit

/-- Registry for auto-generating widget names and tracking component categories. -/
structure ComponentRegistry where
  private mk ::
  /-- Counter for generating unique IDs. -/
  idCounter : IO.Ref Nat
  /-- IDs of focusable input widgets. -/
  inputIds : IO.Ref (Array Afferent.Arbor.ComponentId)
  /-- IDs of all interactive widgets. -/
  interactiveIds : IO.Ref (Array Afferent.Arbor.ComponentId)
  /-- Currently focused input component. -/
  focusedInput : Dynamic Spider (Option Afferent.Arbor.ComponentId)
  /-- Trigger to change focus. -/
  fireFocus : Option Afferent.Arbor.ComponentId → IO Unit
  /-- Per-virtual-list remembered vertical scroll offsets by stable key. -/
  virtualListScrollOffsets : IO.Ref (Std.HashMap String Float)

/-- Create a new component registry. -/
def ComponentRegistry.create : SpiderM ComponentRegistry := do
  let idCounter ← SpiderM.liftIO <| IO.mkRef 0
  let inputIds ← SpiderM.liftIO <| IO.mkRef #[]
  let interactiveIds ← SpiderM.liftIO <| IO.mkRef #[]
  let (focusEvent, fireFocus) ← newTriggerEvent (t := Spider) (a := Option Afferent.Arbor.ComponentId)
  let focusedInput ← holdDyn none focusEvent
  let virtualListScrollOffsets ← SpiderM.liftIO <| IO.mkRef {}
  pure {
    idCounter
    inputIds
    interactiveIds
    focusedInput
    fireFocus
    virtualListScrollOffsets
  }

/-- Reset the registry for a new frame.
    Clears the counter and name arrays to prevent unbounded growth. -/
def ComponentRegistry.reset (reg : ComponentRegistry) : IO Unit := do
  reg.idCounter.set 0
  reg.inputIds.set #[]
  reg.interactiveIds.set #[]

/-- Get diagnostic stats from the registry. -/
def ComponentRegistry.getStats (reg : ComponentRegistry) : IO (Nat × Nat × Nat) := do
  let counter ← reg.idCounter.get
  let inputCount ← reg.inputIds.get
  let interactiveCount ← reg.interactiveIds.get
  pure (counter, inputCount.size, interactiveCount.size)

/-- Register a component and get an auto-generated name.
    - `namePrefix`: Component type prefix (e.g., "button", "text-input")
    - `isInput`: Whether this is a focusable input widget
    - `isInteractive`: Whether this widget responds to clicks -/
def ComponentRegistry.register (reg : ComponentRegistry) (_namePrefix : String)
    (isInput : Bool := false) (isInteractive : Bool := true) : IO Afferent.Arbor.ComponentId := do
  let componentId ← reg.idCounter.modifyGet fun n => (n, n + 1)
  if isInput then
    reg.inputIds.modify (·.push componentId)
  if isInteractive then
    reg.interactiveIds.modify (·.push componentId)
  pure componentId

/-- Read remembered virtual list vertical scroll offset for a stable key. -/
def ComponentRegistry.getVirtualListScrollOffset (reg : ComponentRegistry)
    (key : String) : IO (Option Float) := do
  let offsets ← reg.virtualListScrollOffsets.get
  pure (offsets.get? key)

/-- Remember virtual list vertical scroll offset for a stable key. -/
def ComponentRegistry.setVirtualListScrollOffset (reg : ComponentRegistry)
    (key : String) (offsetY : Float) : IO Unit := do
  reg.virtualListScrollOffsets.modify (fun offsets => offsets.insert key (max 0 offsetY))

/-- Global reactive event streams that widgets subscribe to. -/
structure ReactiveEvents where
  /-- Click events with layout context (mouse down). -/
  clickEvent : Event Spider ClickData
  /-- Mouse up events with layout context. -/
  mouseUpEvent : Event Spider MouseButtonData
  /-- Hover events with position and layout context. -/
  hoverEvent : Event Spider HoverData
  /-- Mouse delta events (relative movement since last frame). -/
  mouseDeltaEvent : Event Spider MouseDeltaData
  /-- Hover state changes by component id (only changed keys fire). -/
  hoverFan : Event.Fan Spider Afferent.Arbor.ComponentId Bool
  /-- Keyboard events. -/
  keyEvent : Event Spider KeyData
  /-- Animation frame events (fires each frame with dt).
      Use for widgets that need delta time (e.g., physics, hover delay tracking). -/
  animationFrame : Event Spider Float
  /-- Shared elapsed time (seconds since app start, accumulated from animation frames).
      Use for continuous animations - all widgets share this single Dynamic. -/
  elapsedTime : Dynamic Spider Float
  /-- Scroll events with layout context. -/
  scrollEvent : Event Spider ScrollData
  /-- Component registry for auto-generating names. -/
  registry : ComponentRegistry
  /-- Font registry for text measurement. -/
  fontRegistry : Afferent.FontRegistry
  /-- Theme for widget styling. -/
  theme : Canopy.Theme
  /-- Default font for text input widgets (optional for testing). -/
  font : Option Afferent.Font := none

private def hoverChangedByComponent (data : HoverData) (componentId : Afferent.Arbor.ComponentId) : Bool :=
  match data.componentMap.get? componentId with
  | some wid => data.hitPath.any (· == wid)
  | none => false

private def buildHoverChangeEvent (hoverEvent : Event Spider HoverData) (registry : ComponentRegistry)
    : SpiderM (Event Spider (Std.HashMap Afferent.Arbor.ComponentId Bool)) := do
  let nodeId ← SpiderM.freshNodeId
  let derived ← SpiderM.liftIO <|
    Reactive.Event.newNodeWithId (t := Spider) nodeId (hoverEvent.height.inc)
  let stateRef ← SpiderM.liftIO <| IO.mkRef (∅ : Std.HashMap Afferent.Arbor.ComponentId Bool)
  let _ ← Reactive.Host.Event.subscribeM hoverEvent fun data => do
    let componentIds ← registry.interactiveIds.get
    if componentIds.isEmpty then
      pure ()
    else
      let prev ← stateRef.get
      let mut next := prev
      let mut delta : Std.HashMap Afferent.Arbor.ComponentId Bool := {}
      for componentId in componentIds do
        let hovered := hoverChangedByComponent data componentId
        let prevVal := prev.getD componentId false
        if hovered != prevVal then
          next := next.insert componentId hovered
          delta := delta.insert componentId hovered
      if !delta.isEmpty then
        stateRef.set next
        Reactive.Event.fire derived delta
  pure derived

/-- Reset the component registry for a new frame.
    Call this at the start of each frame to prevent memory leaks from
    unbounded growth of component names and IDs. -/
def ReactiveEvents.resetRegistry (events : ReactiveEvents) : IO Unit :=
  events.registry.reset

/-- Get diagnostic stats: (idCounter, inputNames.size, interactiveNames.size). -/
def ReactiveEvents.getRegistryStats (events : ReactiveEvents) : IO (Nat × Nat × Nat) :=
  events.registry.getStats

/-- Create the reactive input infrastructure.
    Returns both the event streams (for subscriptions) and triggers (for firing).
    - `fontRegistry`: Registry for text measurement
    - `theme`: Theme for widget styling (default: dark)
    - `font`: Default font for text input widgets (optional for testing) -/
def createInputs (fontRegistry : Afferent.FontRegistry) (theme : Canopy.Theme := Canopy.Theme.dark)
    (font : Option Afferent.Font := none) : SpiderM (ReactiveEvents × ReactiveInputs) := do
  let (clickEvent, fireClick) ← newTriggerEvent (t := Spider) (a := ClickData)
  let (mouseUpEvent, fireMouseUp) ← newTriggerEvent (t := Spider) (a := MouseButtonData)
  let (hoverEvent, fireHover) ← newTriggerEvent (t := Spider) (a := HoverData)
  let (mouseDeltaEvent, fireMouseDelta) ← newTriggerEvent (t := Spider) (a := MouseDeltaData)
  let (keyEvent, fireKey) ← newTriggerEvent (t := Spider) (a := KeyData)
  let (animFrameEvent, fireAnimFrame) ← newTriggerEvent (t := Spider) (a := Float)
  let (scrollEvent, fireScroll) ← newTriggerEvent (t := Spider) (a := ScrollData)
  let registry ← ComponentRegistry.create

  -- Create a SINGLE shared Dynamic for elapsed time that all widgets use
  let elapsedTime ← foldDyn (fun dt acc => acc + dt) 0.0 animFrameEvent
  let hoverChanges ← buildHoverChangeEvent hoverEvent registry
  let hoverFan ← Event.fanM hoverChanges

  let events : ReactiveEvents := {
    clickEvent := clickEvent
    mouseUpEvent := mouseUpEvent
    hoverEvent := hoverEvent
    mouseDeltaEvent := mouseDeltaEvent
    hoverFan := hoverFan
    keyEvent := keyEvent
    animationFrame := animFrameEvent
    elapsedTime := elapsedTime
    scrollEvent := scrollEvent
    registry := registry
    fontRegistry := fontRegistry
    theme := theme
    font := font
  }
  let inputs : ReactiveInputs := {
    fireClick := fireClick
    fireMouseUp := fireMouseUp
    fireHover := fireHover
    fireMouseDelta := fireMouseDelta
    fireKey := fireKey
    fireAnimationFrame := fireAnimFrame
    fireScroll := fireScroll
  }
  pure (events, inputs)

end Afferent.Canopy.Reactive
