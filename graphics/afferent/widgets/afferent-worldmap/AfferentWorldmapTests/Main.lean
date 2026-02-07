import Crucible
import Worldmap
import Tileset

open Crucible
open Worldmap

testSuite "afferent-worldmap"

def testViewport : MapViewport := {
  centerLat := 37.7749
  centerLon := -122.4194
  zoom := 6
  screenWidth := 1024
  screenHeight := 768
  tileSize := 512
}

test "Zoom.geoToScreen and Zoom.screenToGeo roundtrip for a point" := do
  let lat := 37.8
  let lon := -122.41
  let (sx, sy) := Zoom.geoToScreen testViewport lat lon
  let (lat', lon') := Zoom.screenToGeo testViewport sx sy
  shouldBeNear lat' lat
  shouldBeNear lon' lon

test "Zoom.zoomToPoint keeps cursor anchor location stable" := do
  let cursorX := 310.0
  let cursorY := 220.0
  let (anchorLat, anchorLon) := Zoom.screenToGeo testViewport cursorX cursorY
  let zoomed := Zoom.zoomToPoint testViewport cursorX cursorY (testViewport.zoom + 2)
  let (anchorLat', anchorLon') := Zoom.screenToGeo zoomed cursorX cursorY
  shouldBeNear anchorLat' anchorLat
  shouldBeNear anchorLon' anchorLon
  ensure (zoomed.zoom == testViewport.zoom + 2) "Expected zoomed viewport to use requested zoom"

test "MapBounds helpers clamp and validate values" := do
  let bounds := MapBounds.usa
  ensure (bounds.contains 37.7749 (-122.4194)) "San Francisco should be inside USA bounds"
  ensure (!(bounds.contains 0.0 0.0)) "(0,0) should be outside USA bounds"
  ensure (bounds.clampZoom 1 == 3) "USA min zoom should clamp to 3"
  ensure (bounds.clampZoom 25 == 19) "USA max zoom should clamp to 19"

test "MarkerLayer add/get/remove and hit-test flow works" := do
  let (layer1, markerId) :=
    MarkerLayer.addMarker MarkerLayer.empty
      testViewport.centerLat testViewport.centerLon
      (label := some "Center")
      (color := MarkerColor.blue)
      (size := 14.0)

  ensure (layer1.count == 1) "Layer should contain one marker after add"
  let marker? := layer1.getMarker markerId
  ensure marker?.isSome "Added marker should be retrievable by id"
  let marker := marker?.get!
  let (sx, sy) := MarkerLayer.markerScreenPos marker testViewport
  ensure (layer1.hitTest testViewport sx sy == some markerId)
    "Hit-testing at marker position should find marker id"

  let layer2 := layer1.removeMarker markerId
  ensure (layer2.count == 0) "Layer should be empty after removing marker"

test "MapState.init and setBounds apply expected clamping" := do
  let stateA ← Worldmap.MapState.init 100.0 200.0 99 800 600
  shouldBeNear stateA.viewport.centerLat maxMercatorLatitude
  shouldBeNear stateA.viewport.centerLon (-160.0)
  ensure (stateA.viewport.zoom == 19) s!"Expected zoom 19, got {stateA.viewport.zoom}"

  let stateB ← Worldmap.MapState.init 0.0 0.0 8 800 600
  let bounded := stateB.setBounds MapBounds.usa
  shouldBeNear bounded.viewport.centerLat 24.0
  shouldBeNear bounded.viewport.centerLon (-66.0)
  ensure (bounded.viewport.zoom == 8) "Zoom should remain unchanged when within bounds"

test "KeyCode number mapping returns expected zoom levels" := do
  ensure (KeyCode.toZoomLevel KeyCode.key1 == some 1) "Key 1 should map to zoom 1"
  ensure (KeyCode.toZoomLevel KeyCode.key0 == some 10) "Key 0 should map to zoom 10"
  ensure (KeyCode.toZoomLevel KeyCode.arrowUp == none) "Non-numeric keys should not map to zoom"

def main : IO UInt32 := runAllSuites
