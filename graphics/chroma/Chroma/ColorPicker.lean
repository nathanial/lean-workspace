/-
  Chroma Color Picker Widget
  Custom Arbor widget that renders a hue wheel.
-/
import Arbor
import Chroma.Constants
import Trellis
import Tincture

open Arbor
open Trellis (EdgeInsets)
open Tincture

namespace Chroma

structure PickerModel where
  hue : Float := 0.08
  dragging : Bool := false
deriving Repr

inductive PickerMsg where
  | SetHue (hue : Float)
  | StartDrag
  | EndDrag
deriving Repr

def updatePicker (msg : PickerMsg) (state : PickerModel) : PickerModel :=
  match msg with
  | .SetHue hue => { state with hue }
  | .StartDrag => { state with dragging := true }
  | .EndDrag => { state with dragging := false }

structure ColorPickerConfig where
  size : Float := 320.0
  ringThickness : Float := 36.0
  segments : Nat := 120
  selectedHue : Float := 0.08
  selectedSaturation : Float := 1.0
  selectedValue : Float := 1.0
  showCenter : Bool := true
  showKnob : Bool := true
  knobWidth : Float := 22.0
  knobHeight : Float := 10.0
  knobColor : Color := Color.white
  knobStrokeColor : Option Color := some (Color.gray 0.1)
  knobStrokeWidth : Float := 1.0
  previewBorderColor : Option Color := some (Color.gray 0.2)
  background : Option Color := none
  borderColor : Option Color := some (Color.gray 0.25)
deriving Repr

def circlePoints (center : Point) (radius : Float) (steps : Nat) : Array Point :=
  Id.run do
    let steps := max 3 steps
    let step := tau / steps.toFloat
    let mut pts : Array Point := Array.mkEmpty steps
    for i in [:steps] do
      let angle := step * i.toFloat
      let p := Point.mk'
        (center.x + radius * Float.cos angle)
        (center.y + radius * Float.sin angle)
      pts := pts.push p
    return pts

def ringSegmentPoints (center : Point) (inner outer : Float) (a0 a1 : Float) : Array Point :=
  let cos0 := Float.cos a0
  let sin0 := Float.sin a0
  let cos1 := Float.cos a1
  let sin1 := Float.sin a1
  let outer0 := Point.mk' (center.x + outer * cos0) (center.y + outer * sin0)
  let outer1 := Point.mk' (center.x + outer * cos1) (center.y + outer * sin1)
  let inner1 := Point.mk' (center.x + inner * cos1) (center.y + inner * sin1)
  let inner0 := Point.mk' (center.x + inner * cos0) (center.y + inner * sin0)
  #[outer0, outer1, inner1, inner0]

def orientedRectPoints (center : Point) (angle : Float) (width height : Float) : Array Point :=
  let cosA := Float.cos angle
  let sinA := Float.sin angle
  let halfW := width / 2
  let halfH := height / 2
  let tangent := Point.mk' (-sinA) cosA
  let radial := Point.mk' cosA sinA
  let tdx := tangent.x * halfW
  let tdy := tangent.y * halfW
  let rdx := radial.x * halfH
  let rdy := radial.y * halfH
  let p1 := Point.mk' (center.x - tdx - rdx) (center.y - tdy - rdy)
  let p2 := Point.mk' (center.x + tdx - rdx) (center.y + tdy - rdy)
  let p3 := Point.mk' (center.x + tdx + rdx) (center.y + tdy + rdy)
  let p4 := Point.mk' (center.x - tdx + rdx) (center.y - tdy + rdy)
  #[p1, p2, p3, p4]

def hueFromPoint (rect : Trellis.LayoutRect) (config : ColorPickerConfig) (x y : Float) : Option Float :=
  let center := Point.mk' (rect.x + rect.width / 2) (rect.y + rect.height / 2)
  let outer := min rect.width rect.height / 2
  let inner := max 0 (outer - config.ringThickness)
  let dx := x - center.x
  let dy := y - center.y
  let dist := Float.sqrt (dx * dx + dy * dy)
  if dist < inner || dist > outer then
    none
  else
    let angle := Float.atan2 dy dx
    let a := if angle < 0.0 then angle + tau else angle
    some (a / tau)

def hueFromPosition (rect : Trellis.LayoutRect) (x y : Float) : Float :=
  let center := Point.mk' (rect.x + rect.width / 2) (rect.y + rect.height / 2)
  let dx := x - center.x
  let dy := y - center.y
  let angle := Float.atan2 dy dx
  let a := if angle < 0.0 then angle + tau else angle
  a / tau

def colorPickerSpec (config : ColorPickerConfig) : CustomSpec :=
  { measure := fun availWidth availHeight =>
      let size := min config.size (min availWidth availHeight)
      (size, size)
    collect := fun layout =>
      Id.run do
        let content := layout.contentRect
        let center := Point.mk' (content.x + content.width / 2) (content.y + content.height / 2)
        let radius := min content.width content.height / 2
        let innerRadius := max 0 (radius - config.ringThickness)
        let segments := max 1 config.segments
        let step := tau / segments.toFloat
        let mut cmds : Array RenderCommand := #[]

        -- Hue ring
        for i in [:segments] do
          let a0 := step * i.toFloat
          let a1 := step * (i + 1).toFloat
          let hue := (i.toFloat + 0.5) / segments.toFloat
          let color := Color.hsv hue 1.0 1.0
          let points := ringSegmentPoints center innerRadius radius a0 a1
          cmds := cmds.push (.fillPolygon points color)

        -- Center preview
        if config.showCenter && innerRadius > 2 then
          let previewRadius := innerRadius * 0.6
          if previewRadius > 1 then
            let previewColor := Color.hsv config.selectedHue config.selectedSaturation config.selectedValue
            let preview := circlePoints center previewRadius 64
            cmds := cmds.push (.fillPolygon preview previewColor)
            if let some border := config.previewBorderColor then
              cmds := cmds.push (.strokePolygon preview border 1.0)

        -- Outer border
        if let some border := config.borderColor then
          let outer := circlePoints center radius 96
          cmds := cmds.push (.strokePolygon outer border 1.0)

        -- Selection knob
        if config.showKnob then
          let knobAngle := config.selectedHue * tau
          let knobDist := (innerRadius + radius) / 2
          let knobCenter := Point.mk'
            (center.x + knobDist * Float.cos knobAngle)
            (center.y + knobDist * Float.sin knobAngle)
          let rectAngle := knobAngle + (tau / 4.0)
          let knob := orientedRectPoints knobCenter rectAngle config.knobWidth config.knobHeight
          cmds := cmds.push (.fillPolygon knob config.knobColor)
          if let some stroke := config.knobStrokeColor then
            cmds := cmds.push (.strokePolygon knob stroke config.knobStrokeWidth)
        return cmds
    hitTest := some (fun layout p =>
      (hueFromPoint layout.contentRect config p.x p.y).isSome) }

def colorPicker (config : ColorPickerConfig) : WidgetBuilder := do
  let style : BoxStyle := {
    backgroundColor := config.background
    borderColor := none
    borderWidth := 0
    minWidth := some config.size
    minHeight := some config.size
  }
  custom (colorPickerSpec config) style

def pickerHandler (config : ColorPickerConfig) : Handler PickerMsg :=
  fun ctx ev =>
    match ev, ctx.globalPos with
    | .mouseDown _e, some p =>
      match hueFromPoint ctx.layout.contentRect config p.x p.y with
      | some hue =>
        { msgs := #[.SetHue hue, .StartDrag], capture := some ctx.widgetId }
      | none => {}
    | .mouseMove _e, some p =>
      if ctx.isCaptured then
        let hue := hueFromPosition ctx.layout.contentRect p.x p.y
        { msgs := #[.SetHue hue] }
      else
        {}
    | .mouseUp _e, _ =>
      { msgs := #[.EndDrag], releaseCapture := true }
    | _, _ => {}

def pickerUI (titleId bodyId : FontId) (config : ColorPickerConfig) (screenScale : Float) : UI PickerMsg :=
  let sizes := uiSizes
  let ids := widgetIds
  UIBuilder.buildFrom ids.columnRoot do
    let widget ← UIBuilder.lift do
      column (gap := sizes.columnGap * screenScale)
        (style := { padding := EdgeInsets.uniform (sizes.columnPadding * screenScale) }) #[
          text' "Chroma" titleId Color.white .center,
          colorPicker config,
          text' "Drag on the ring to set hue" bodyId (Color.gray 0.7) .center
        ]
    UIBuilder.register ids.picker (pickerHandler config)
    pure widget

end Chroma
