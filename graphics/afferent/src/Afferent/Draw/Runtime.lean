/-
  Draw Runtime State
  Runtime storage for draw-layer caches.
-/
import Afferent.Draw.Cache

namespace Afferent.Draw

/-- Runtime state owned by a rendering context for draw-layer caching. -/
structure Runtime where
  renderCache : IO.Ref Afferent.Arbor.RenderCache

namespace Runtime

/-- Create draw runtime state with empty cache. -/
def create : IO Runtime := do
  let renderCache ← IO.mkRef Afferent.Arbor.RenderCache.empty
  pure { renderCache }

/-- Number of entries in the draw cache. -/
def getRenderCacheSize (rt : Runtime) : IO Nat := do
  let cache ← rt.renderCache.get
  pure cache.size

/-- Clear all entries in the draw cache. -/
def clearRenderCache (rt : Runtime) : IO Unit := do
  rt.renderCache.modify fun rc => Afferent.Arbor.RenderCache.clear rc

end Runtime

end Afferent.Draw
