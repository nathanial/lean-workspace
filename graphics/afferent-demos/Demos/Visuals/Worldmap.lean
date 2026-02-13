/-
  Worldmap Demo
  Handles input, updates tiles, and renders overlay labels.

  Note: This demo requires a TileManager for tile loading. The TileManager
  must be created and maintained in a SpiderM context by the demo runner.
-/
import Afferent
import Demos.Core.Demo
import Worldmap
import Tileset
import Reactive

open Afferent CanvasM
open Tileset (TileManager TileManagerConfig TileProvider)
open Reactive.Host (SpiderM)

namespace Demos

/-- Update worldmap state for one frame (IO portion only).
    This handles input, zoom animation, and frame ticking.
    Tile loading must be done separately in SpiderM via requestVisibleTiles. -/
def updateWorldmapDemo (env : DemoEnv) (state : Worldmap.MapState)
    (mgr : TileManager) : IO Worldmap.MapState := do
  let mut mapState := state
  let width := (max 1.0 env.physWidthF).toUInt32
  let height := (max 1.0 env.physHeightF).toUInt32
  mapState := mapState.updateScreenSize width.toNat height.toNat
  mapState ← Worldmap.handleInputAt env.window mapState env.contentOffsetX env.contentOffsetY
  mapState ← Worldmap.updateFrame mapState mgr
  pure mapState

/-- Request tiles for visible area (must be called from SpiderM context) -/
def requestWorldmapTiles (state : Worldmap.MapState) (mgr : TileManager) : SpiderM Worldmap.MapState := do
  if Worldmap.shouldFetchNewTiles state then
    Worldmap.requestVisibleTiles state mgr
  else
    pure state

def worldmapWidgetNamed (screenScale : Float) (_fontMedium _fontSmall : Font)
    (_windowW _windowH : Float) (state : Worldmap.MapState)
    (mapName sidebarName : String) : Afferent.Arbor.WidgetBuilder := do
  let s := screenScale
  let sidebarWidth := 320 * s
  let line := 18 * s
  let fmt1 := fun (v : Float) => s!"{(v * 10).toUInt32.toFloat / 10}"
  let minZoom := Tileset.intClamp (state.viewport.zoom - Tileset.natToInt state.fallbackParentDepth)
    state.tileProvider.minZoom state.tileProvider.maxZoom
  let maxZoom := Tileset.intClamp (state.viewport.zoom + Tileset.natToInt state.fallbackChildDepth)
    state.tileProvider.minZoom state.tileProvider.maxZoom
  let (reqMinZoom, reqMaxZoom) := Worldmap.requestedZoomRange state
  let countTilesInRange := fun (minZ maxZ : Int) (buffer : Int) => Id.run do
    let minZ := minZ.toNat
    let maxZ := maxZ.toNat
    let mut count := 0
    for z in [minZ:maxZ+1] do
      let zInt := Tileset.natToInt z
      let vp := { state.viewport with zoom := zInt }
      count := count + (vp.visibleTilesWithBuffer buffer).length
    return count
  let visibleCount := state.viewport.visibleTiles.length
  let requestedCount := countTilesInRange reqMinZoom reqMaxZoom 1
  let keepCount := countTilesInRange reqMinZoom reqMaxZoom 3
  let candidateCount := countTilesInRange minZoom maxZoom 1
  let sidebarLines : Array String := #[
    s!"Zoom: {fmt1 state.displayZoom} (tile {state.viewport.zoom})",
    s!"Visible tiles: {visibleCount}",
    s!"Requested tiles: {requestedCount}",
    s!"Keep tiles (buffer 3): {keepCount}",
    s!"Candidate tiles: {candidateCount}",
    s!"Fallback z: {minZoom}..{maxZoom}",
    s!"Fade frames: {state.fadeFrames}"
  ]
  let sidebarStyle : Afferent.Arbor.BoxStyle := {
    width := .length sidebarWidth
    height := .percent 1.0
    flexItem := some (Trellis.FlexItem.fixed sidebarWidth)
  }
  let mapStyle : Afferent.Arbor.BoxStyle := {
    width := .percent 1.0
    height := .percent 1.0
    flexItem := some (Trellis.FlexItem.growing 1)
  }
  let sidebarSpec := {
    measure := fun _ _ => (0, 0)
    collect := fun layout =>
      let rect := layout.contentRect
      let left := rect.x + (12 * s)
      let mut y := rect.y + (22 * s)
      let mut cmds : RenderCommands := #[
        .fillRect (Rect.mk' rect.x rect.y rect.width rect.height) (Color.gray 0.1)
      ]
      cmds := cmds.push (.fillText "Worldmap Debug" left y FontId.default (Color.gray 0.9))
      y := y + line
      for lineText in sidebarLines do
        cmds := cmds.push (.fillText lineText left y FontId.default (Color.gray 0.9))
        y := y + line
      cmds
  }
  let mapSpec := {
    measure := fun _ _ => (0, 0)
    collect := fun layout =>
      let rect := layout.contentRect
      let x := rect.x + (20 * s)
      let y0 := rect.y + (30 * s)
      let y1 := rect.y + (55 * s)
      #[
        .fillRect (Rect.mk' rect.x rect.y rect.width rect.height) (Color.gray 0.03),
        .fillText "Worldmap Demo (stream-only placeholder)" x y0 FontId.default Color.white,
        .fillText s!"lat={fmt1 state.viewport.centerLat} lon={fmt1 state.viewport.centerLon} zoom={fmt1 state.displayZoom}"
          x y1 FontId.default (Color.gray 0.8)
      ]
  }
  let sidebarWidget :=
    if sidebarName == "" then
      Afferent.Arbor.custom (spec := sidebarSpec) (style := sidebarStyle)
    else
      Afferent.Arbor.namedCustom sidebarName (spec := sidebarSpec) (style := sidebarStyle)
  let mapWidget :=
    if mapName == "" then
      Afferent.Arbor.custom (spec := mapSpec) (style := mapStyle)
    else
      Afferent.Arbor.namedCustom mapName (spec := mapSpec) (style := mapStyle)
  Afferent.Arbor.flexRow (Trellis.FlexContainer.row 0) { width := .percent 1.0, height := .percent 1.0 } #[
    sidebarWidget,
    mapWidget
  ]

def worldmapWidget (screenScale : Float) (fontMedium fontSmall : Font)
    (windowW windowH : Float) (state : Worldmap.MapState) : Afferent.Arbor.WidgetBuilder := do
  worldmapWidgetNamed screenScale fontMedium fontSmall windowW windowH state "" ""

/-- Create TileManager configuration for the demo -/
def worldmapTileConfig : TileManagerConfig := {
  provider := TileProvider.cartoDarkRetina
  diskCacheDir := ".tile-cache"
  diskCacheMaxSize := 500 * 1024 * 1024  -- 500 MB
}

end Demos
