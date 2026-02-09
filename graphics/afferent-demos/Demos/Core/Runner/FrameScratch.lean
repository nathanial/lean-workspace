/- Native frame scratch arena for reusable mutable buffers. -/
import Afferent
import Afferent.UI.Arbor.Event.HitTest
import Afferent.UI.Arbor.Render.Collect

set_option maxRecDepth 1024

namespace Demos

opaque FrameScratchPointed : NonemptyType
def FrameScratch : Type := FrameScratchPointed.type
instance : Nonempty FrameScratch := FrameScratchPointed.property

@[extern "lean_demos_frame_scratch_create"]
opaque FrameScratch.create
  (collectCommandsCap collectDeferredCap hitBoundsCap : Nat)
  (hitNameMapCap hitParentMapCap : Nat) : IO FrameScratch

@[extern "lean_demos_frame_scratch_checkout_collect_commands"]
opaque FrameScratch.checkoutCollectCommands
  (scratch : @& FrameScratch) : IO (Array Afferent.Arbor.RenderCommand)

@[extern "lean_demos_frame_scratch_checkin_collect_commands"]
opaque FrameScratch.checkinCollectCommands
  (scratch : @& FrameScratch)
  (commands : @& Array Afferent.Arbor.RenderCommand) : IO Unit

@[extern "lean_demos_frame_scratch_checkout_collect_deferred"]
opaque FrameScratch.checkoutCollectDeferred
  (scratch : @& FrameScratch)
  : IO (Array (Afferent.Arbor.Widget × Trellis.LayoutResult × Afferent.Arbor.CacheKey))

@[extern "lean_demos_frame_scratch_checkin_collect_deferred"]
opaque FrameScratch.checkinCollectDeferred
  (scratch : @& FrameScratch)
  (deferred : @& Array (Afferent.Arbor.Widget × Trellis.LayoutResult × Afferent.Arbor.CacheKey))
  : IO Unit

@[extern "lean_demos_frame_scratch_checkout_hit_bounds"]
opaque FrameScratch.checkoutHitBounds
  (scratch : @& FrameScratch) : IO (Array Linalg.AABB2D)

@[extern "lean_demos_frame_scratch_checkin_hit_bounds"]
opaque FrameScratch.checkinHitBounds
  (scratch : @& FrameScratch)
  (bounds : @& Array Linalg.AABB2D) : IO Unit

@[extern "lean_demos_frame_scratch_get_hit_name_map_capacity"]
opaque FrameScratch.getHitNameMapCapacity
  (scratch : @& FrameScratch) : IO Nat

@[extern "lean_demos_frame_scratch_set_hit_name_map_capacity"]
opaque FrameScratch.setHitNameMapCapacity
  (scratch : @& FrameScratch) (capacity : Nat) : IO Unit

@[extern "lean_demos_frame_scratch_get_hit_parent_map_capacity"]
opaque FrameScratch.getHitParentMapCapacity
  (scratch : @& FrameScratch) : IO Nat

@[extern "lean_demos_frame_scratch_set_hit_parent_map_capacity"]
opaque FrameScratch.setHitParentMapCapacity
  (scratch : @& FrameScratch) (capacity : Nat) : IO Unit

@[extern "lean_demos_frame_scratch_checkout_interactive_names"]
opaque FrameScratch.checkoutInteractiveNames
  (scratch : @& FrameScratch) : IO (Array String)

@[extern "lean_demos_frame_scratch_checkin_interactive_names"]
opaque FrameScratch.checkinInteractiveNames
  (scratch : @& FrameScratch) (names : @& Array String) : IO Unit

def FrameScratch.checkoutCollect
  (scratch : @& FrameScratch) : IO Afferent.Arbor.CachedCollectScratch := do
  let commands ← scratch.checkoutCollectCommands
  let deferredOverlay ← scratch.checkoutCollectDeferred
  pure { commands, deferredOverlay }

def FrameScratch.checkinCollect
  (scratch : @& FrameScratch)
  (collectScratch : Afferent.Arbor.CachedCollectScratch) : IO Unit := do
  scratch.checkinCollectCommands collectScratch.commands
  scratch.checkinCollectDeferred collectScratch.deferredOverlay

def FrameScratch.checkoutHit
  (scratch : @& FrameScratch) : IO Afferent.Arbor.HitTestBuildScratch := do
  let bounds ← scratch.checkoutHitBounds
  let nameMapCapacity ← scratch.getHitNameMapCapacity
  let parentMapCapacity ← scratch.getHitParentMapCapacity
  pure { bounds, nameMapCapacity, parentMapCapacity }

def FrameScratch.checkinHit
  (scratch : @& FrameScratch)
  (hitScratch : Afferent.Arbor.HitTestBuildScratch) : IO Unit := do
  scratch.checkinHitBounds hitScratch.bounds
  scratch.setHitNameMapCapacity hitScratch.nameMapCapacity
  scratch.setHitParentMapCapacity hitScratch.parentMapCapacity

end Demos
