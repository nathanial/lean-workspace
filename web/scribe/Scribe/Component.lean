/-
  Scribe.Component - Component infrastructure for slot-based UI composition

  Provides helpers for building reusable UI components with named slots,
  attribute forwarding, and optional slot detection.

  Example:
  ```lean
  import Scribe

  structure CardSlots where
    header : Option (HtmlM Unit) := none
    body : HtmlM Unit
    footer : Option (HtmlM Unit) := none

  def card (attrs : List Attr := []) (slots : CardSlots) : HtmlM Unit := do
    div (withClass "card" attrs) do
      whenSlot slots.header fun content =>
        div [class_ "card-header"] content
      div [class_ "card-body"] slots.body
      whenSlot slots.footer fun content =>
        div [class_ "card-footer"] content
  ```
-/
import Scribe.Builder
import Scribe.Attr

namespace Scribe

-- ============================================================================
-- Slot Content Detection
-- ============================================================================

/-- Check if an HtmlM action produces any HTML content.
    Useful for conditionally rendering wrapper elements around optional slots. -/
def HtmlM.hasContent (m : HtmlM Unit) : Bool :=
  !(HtmlM.collect m).isEmpty

/-- Check if an HtmlM action produces no HTML content. -/
def HtmlM.isEmpty (m : HtmlM Unit) : Bool :=
  (HtmlM.collect m).isEmpty

/-- Render content only if the HtmlM action produces output.
    Returns the rendered content or an empty builder. -/
def HtmlM.whenNonEmpty (m : HtmlM Unit) (render : HtmlM Unit → HtmlM Unit) : HtmlM Unit :=
  if HtmlM.hasContent m then render m else pure ()

-- ============================================================================
-- Optional Slot Helpers
-- ============================================================================

/-- Render an optional slot, doing nothing if None. -/
def renderSlot (slot : Option (HtmlM Unit)) : HtmlM Unit :=
  match slot with
  | some content => content
  | none => pure ()

/-- Render an optional slot with a wrapper, skipping wrapper if slot is None. -/
def renderSlotWith (slot : Option (HtmlM Unit)) (wrapper : HtmlM Unit → HtmlM Unit) : HtmlM Unit :=
  match slot with
  | some content => wrapper content
  | none => pure ()

/-- Conditionally render based on whether an optional slot was provided.
    Alias for renderSlotWith for more readable component code. -/
def whenSlot (slot : Option (HtmlM Unit)) (render : HtmlM Unit → HtmlM Unit) : HtmlM Unit :=
  renderSlotWith slot render

/-- Check if an optional slot was provided (regardless of content). -/
def hasSlot (slot : Option (HtmlM Unit)) : Bool :=
  slot.isSome

/-- Check if an optional slot was provided AND has content. -/
def hasSlotContent (slot : Option (HtmlM Unit)) : Bool :=
  match slot with
  | some m => HtmlM.hasContent m
  | none => false

-- ============================================================================
-- Component Attribute Merging
-- ============================================================================

/-- Standard component attribute pattern: merge base attrs with user attrs.
    User attributes override defaults, except class/style which concatenate. -/
def componentAttrs (baseAttrs userAttrs : List Attr) : List Attr :=
  mergeAttrs baseAttrs userAttrs

/-- Shorthand for component with just a class as base. -/
def withClass (baseClass : String) (userAttrs : List Attr) : List Attr :=
  mergeAttrs [class_ baseClass] userAttrs

-- ============================================================================
-- Empty Slot Constant
-- ============================================================================

/-- An empty slot that renders nothing. Use as default for optional slots. -/
def emptySlot : HtmlM Unit := pure ()

end Scribe
