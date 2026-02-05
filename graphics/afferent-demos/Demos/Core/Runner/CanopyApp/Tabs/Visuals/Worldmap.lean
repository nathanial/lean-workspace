/- 
  Demo Runner - Canopy app visuals Worldmap tab content.

  Placeholder implementation while the worldmap demo is being migrated.
-/
import Afferent
import Afferent.Canopy
import Afferent.Canopy.Reactive
import Demos.Core.Demo
import Tileset

open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive

namespace Demos

def worldmapTabContent (_env : DemoEnv) (_manager : Tileset.TileManager) : WidgetM Unit := do
  column' (gap := 12) (style := { width := .percent 1.0 }) do
    heading2' "Map demo disabled"
    caption' "The worldmap demo is temporarily disabled during the monorepo migration."
    caption' "This placeholder keeps afferent_demos building while other demos remain available."
  pure ()

end Demos
