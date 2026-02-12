/-
  Afferent Text Measurer
  Implementation of Arbor's TextMeasurer typeclass for FreeType fonts.
-/
import Afferent.Graphics.Text.Font
import Afferent.UI.Arbor.Core.TextMeasurer
import Std.Data.HashMap

namespace Afferent

/-- Font registry that maps FontIds to loaded Font handles.
    This allows Arbor widgets (which use abstract FontIds) to work
    with Afferent's concrete Font type. -/
structure FontRegistry where
  fonts : Array Font
  defaultFont : Option Font := none

instance : Inhabited FontRegistry where
  default := ⟨#[], none⟩

namespace FontRegistry

def empty : FontRegistry := ⟨#[], none⟩

/-- Register a font and return its FontId with actual metrics. -/
def register (reg : FontRegistry) (font : Font) (name : String) : FontRegistry × Afferent.Arbor.FontId :=
  let id : Afferent.Arbor.FontId := {
    id := reg.fonts.size
    name := name
    size := font.size.toFloat
    lineHeight := font.lineHeight
    ascender := font.ascender
    descender := font.descender
  }
  let newReg := { reg with fonts := reg.fonts.push font }
  (newReg, id)

/-- Set the default font (used when FontId lookup fails). -/
def setDefault (reg : FontRegistry) (font : Font) : FontRegistry :=
  { reg with defaultFont := some font }

/-- Look up a Font by FontId. Returns default font if not found. -/
def get (reg : FontRegistry) (fontId : Afferent.Arbor.FontId) : Option Font :=
  reg.fonts[fontId.id]? <|> reg.defaultFont

end FontRegistry

/-- Reader monad with access to a FontRegistry. -/
abbrev FontReaderT (m : Type → Type) := ReaderT FontRegistry m

/-! ## Text Measurement Cache

Caches measured text metrics by `(fontId, hash(text))` so repeated widget-tree
measurement avoids redundant FreeType calls for stable strings.
-/

/-- Key for cached text metrics lookup. -/
structure TextSizeCacheKey where
  fontId : Nat
  textHash : UInt64
deriving BEq, Hashable

/-- Global cache for measured text metrics. -/
structure TextSizeCache where
  cache : Std.HashMap TextSizeCacheKey Afferent.Arbor.TextMetrics := {}
  /-- FIFO insertion order used for bounded eviction. -/
  order : Array TextSizeCacheKey := #[]
  /-- Next index in `order` to evict when cache is full. -/
  nextEvict : Nat := 0
  capacity : Nat := 20000

instance : Inhabited TextSizeCache where
  default := { cache := {}, order := #[], nextEvict := 0, capacity := 20000 }

namespace TextSizeCache

def empty : TextSizeCache :=
  { cache := {}, order := #[], nextEvict := 0, capacity := 20000 }

def find? (c : TextSizeCache) (key : TextSizeCacheKey) : Option Afferent.Arbor.TextMetrics :=
  c.cache[key]?

def insert (c : TextSizeCache) (key : TextSizeCacheKey)
    (metrics : Afferent.Arbor.TextMetrics) : TextSizeCache :=
  if c.cache.contains key then
    c
  else if c.capacity == 0 then
    c
  else if c.cache.size < c.capacity then
    { c with
      cache := c.cache.insert key metrics
      order := c.order.push key
    }
  else
    let idx := c.nextEvict % c.capacity
    match c.order[idx]? with
    | some oldKey =>
        let cache' := (c.cache.erase oldKey).insert key metrics
        let order' := c.order.set! idx key
        { c with
          cache := cache'
          order := order'
          nextEvict := (idx + 1) % c.capacity
        }
    | none =>
        -- Recover from unexpected order/cache mismatch.
        let repaired : Std.HashMap TextSizeCacheKey Afferent.Arbor.TextMetrics := {}
        { cache := repaired.insert key metrics, order := #[key], nextEvict := 0, capacity := c.capacity }

def size (c : TextSizeCache) : Nat := c.cache.size

end TextSizeCache

initialize textSizeCacheRef : IO.Ref TextSizeCache <- IO.mkRef TextSizeCache.empty

private def textCacheKey (fontId : Afferent.Arbor.FontId) (text : String) : TextSizeCacheKey :=
  { fontId := fontId.id, textHash := hash text }

private def measureTextCached (reg : FontRegistry) (fontId : Afferent.Arbor.FontId)
    (text : String) : IO Afferent.Arbor.TextMetrics := do
  let key := textCacheKey fontId text
  let cacheState ← textSizeCacheRef.get
  match cacheState.find? key with
  | some metrics =>
      pure metrics
  | none =>
      match reg.get fontId with
      | some font =>
          let (w, h) ← font.measureText text
          let metrics : Afferent.Arbor.TextMetrics :=
            ⟨w, h, font.ascender, font.descender, font.lineHeight⟩
          textSizeCacheRef.modify fun c => c.insert key metrics
          pure metrics
      | none =>
          panic! s!"FontId {fontId.id} ('{fontId.name}') not found in FontRegistry"

/-- TextMeasurer instance for FontReaderT IO.
    This allows Arbor's text measurement functions to work with Afferent's fonts. -/
instance : Afferent.Arbor.TextMeasurer (FontReaderT IO) where
  measureText text fontId := do
    let reg ← read
    measureTextCached reg fontId text

  measureChar c fontId := do
    let reg ← read
    let m ← measureTextCached reg fontId (String.singleton c)
    pure m.width

  fontMetrics fontId := do
    let reg ← read
    match reg.get fontId with
    | some font =>
      pure ⟨0, font.glyphHeight, font.ascender, font.descender, font.lineHeight⟩
    | none =>
      panic! s!"FontId {fontId.id} ('{fontId.name}') not found in FontRegistry"

/-- Run a FontReaderT computation with a registry. -/
def runWithFonts {α : Type} (reg : FontRegistry) (m : FontReaderT IO α) : IO α :=
  m.run reg

/-- Clear global text-size cache. Useful for deterministic profiling runs. -/
def clearTextSizeCache : IO Unit :=
  textSizeCacheRef.set TextSizeCache.empty

/-- Current number of cached text-size entries. -/
def textSizeCacheSize : IO Nat := do
  pure (TextSizeCache.size (← textSizeCacheRef.get))

/-- Convenience: create a registry with a single font as both registered and default. -/
def withFont (font : Font) (name : String := "default") : IO (FontRegistry × Afferent.Arbor.FontId) := do
  let (reg, fontId) := FontRegistry.empty.register font name
  let reg := reg.setDefault font
  pure (reg, fontId)

end Afferent
