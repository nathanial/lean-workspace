/-
  Province Map Widget
  An EU4-style province map widget showing provinces as filled polygons.
-/
import Afferent
import Afferent.UI.Arbor
import Linalg
import Tincture
import Eschaton.Widget.ProvinceMap.State
import Eschaton.Widget.ProvinceMap.HitTest

open Afferent.Arbor
open Tincture (Color)

namespace Eschaton.Widget

/-- Clamp a float to be at most the given maximum. -/
private def clampMax (x max : Float) : Float := if x > max then max else x

/-- Brighten a color by a percentage (0.0 - 1.0). -/
private def brighten (color : Color) (amount : Float) : Color :=
  Color.rgba
    (clampMax (color.r + (1.0 - color.r) * amount) 1.0)
    (clampMax (color.g + (1.0 - color.g) * amount) 1.0)
    (clampMax (color.b + (1.0 - color.b) * amount) 1.0)
    color.a

/-- A province in the map. -/
structure Province where
  /-- Unique identifier for the province -/
  id : Nat
  /-- Display name for the province -/
  name : String
  /-- Polygon vertices in normalized 0-1 coordinates (for hit testing) -/
  polygon : Linalg.Polygon2D
  /-- Fill color for the province -/
  fillColor : Color
  /-- Border color (defaults to dark gray) -/
  borderColor : Color := Color.rgba 0.2 0.2 0.2 1.0
  deriving Inhabited

namespace Province

/-- Create a province. -/
def create (id : Nat) (name : String) (polygon : Linalg.Polygon2D) (fillColor : Color)
    (borderColor : Color := Color.rgba 0.2 0.2 0.2 1.0) : Province :=
  { id, name, polygon, fillColor, borderColor }

end Province

/-- Static configuration for the province map (excludes view state). -/
structure ProvinceMapStaticConfig where
  /-- Array of provinces to display -/
  provinces : Array Province
  /-- Background color (ocean/empty space) -/
  backgroundColor : Color := Color.rgb 0.1 0.15 0.2
  /-- Border width in pixels -/
  borderWidth : Float := 1.5
  /-- Optional font for province labels -/
  labelFont : Option FontId := none
  /-- Label text color -/
  labelColor : Color := Color.rgba 0.9 0.9 0.9 0.9
  deriving Inhabited

/-- Province map widget spec using direct polygon drawing with reactive view state. -/
def provinceMapSpecWithState (staticConfig : ProvinceMapStaticConfig)
    (viewState : ProvinceMap.ProvinceMapViewState) : Afferent.Arbor.CustomSpec := {
  skipCache := false  -- No animation, can cache when state unchanged
  measure := fun _ _ => (0, 0)  -- Use layout-provided size
  collect := fun layout => do
    let rect := layout.contentRect
    -- Screen center for zoom origin (relative to content rect)
    let centerX := rect.width / 2.0
    let centerY := rect.height / 2.0

    -- Fill background (ocean color, not affected by pan/zoom)
    -- Use pushTranslate for the background rect since it uses local coordinates
    Afferent.CanvasM.pushTranslate rect.x rect.y
    Afferent.CanvasM.fillRectColor' 0 0 rect.width rect.height
      (Afferent.Color.rgba
        staticConfig.backgroundColor.r
        staticConfig.backgroundColor.g
        staticConfig.backgroundColor.b
        staticConfig.backgroundColor.a)
    Afferent.CanvasM.popTransform

    let transformToScreen (normX normY : Float) : Afferent.Point :=
      let baseX := normX * rect.width
      let baseY := normY * rect.height
      let localX := centerX + (baseX - centerX) * viewState.zoom + viewState.panX
      let localY := centerY + (baseY - centerY) * viewState.zoom + viewState.panY
      Point.mk' (rect.x + localX) (rect.y + localY)

    for i in [:staticConfig.provinces.size] do
      if h : i < staticConfig.provinces.size then
        let province := staticConfig.provinces[i]
        let isHovered := viewState.hoveredProvince == some i
        let isSelected := viewState.selectedProvince == some i

        let fillColor :=
          if isSelected then brighten province.fillColor 0.3
          else if isHovered then brighten province.fillColor 0.15
          else province.fillColor

        let mut path := Afferent.Path.empty
        if province.polygon.vertices.size > 0 then
          let first := province.polygon.vertices[0]!
          path := path.moveTo (transformToScreen first.x first.y)
          for vi in [1:province.polygon.vertices.size] do
            let v := province.polygon.vertices[vi]!
            path := path.lineTo (transformToScreen v.x v.y)
          path := path.closePath

          Afferent.CanvasM.fillPathColor path
            (Afferent.Color.rgba fillColor.r fillColor.g fillColor.b fillColor.a)
          Afferent.CanvasM.strokePathColor path
            (Afferent.Color.rgba province.borderColor.r province.borderColor.g province.borderColor.b province.borderColor.a)
            staticConfig.borderWidth

      -- Draw labels if font provided (centered on province centroids)
      -- Labels use pushTranslate since fillText expects local coordinates
      if let some font := staticConfig.labelFont then
        Afferent.CanvasM.pushTranslate rect.x rect.y

        -- Transform a normalized position (0-1) to local coords with zoom and pan
        let transformToLocal (normX normY : Float) : Float × Float :=
          let baseX := normX * rect.width
          let baseY := normY * rect.height
          let localX := centerX + (baseX - centerX) * viewState.zoom + viewState.panX
          let localY := centerY + (baseY - centerY) * viewState.zoom + viewState.panY
          (localX, localY)

        for i in [:staticConfig.provinces.size] do
          if h : i < staticConfig.provinces.size then
            let province := staticConfig.provinces[i]
            let centroid := province.polygon.centroid
            let (cx, cy) := transformToLocal centroid.x centroid.y

            -- Highlight label for selected province
            let labelColor :=
              if viewState.selectedProvince == some i then
                Color.rgba 1.0 1.0 0.8 1.0
              else
                staticConfig.labelColor

            -- Create a bounding rect centered on the centroid
            let labelRect := Rect.mk' (cx - 100) (cy - 20) 200 40
            Afferent.CanvasM.fillTextBlockId province.name labelRect font
              (Afferent.Color.rgba labelColor.r labelColor.g labelColor.b labelColor.a) .center .middle

        Afferent.CanvasM.popTransform
}

/-- Convert a Province to ProvinceHitInfo for hit testing. -/
def Province.toHitInfo (province : Province) : ProvinceMap.ProvinceHitInfo :=
  { polygon := province.polygon }

/-- Convert an array of Provinces to ProvinceHitInfo array. -/
def toProvinceHitInfoArray (provinces : Array Province) : Array ProvinceMap.ProvinceHitInfo :=
  provinces.map Province.toHitInfo

end Eschaton.Widget
