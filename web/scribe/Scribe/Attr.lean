/-
  Scribe.Attr - Common HTML attribute helpers
-/
import Scribe.Html
import Std.Data.HashMap

namespace Scribe

-- Global attributes
def class_ (v : String) : Attr := ⟨"class", v⟩
def id_ (v : String) : Attr := ⟨"id", v⟩
def style_ (v : String) : Attr := ⟨"style", v⟩
def title_ (v : String) : Attr := ⟨"title", v⟩
def lang_ (v : String) : Attr := ⟨"lang", v⟩
def dir_ (v : String) : Attr := ⟨"dir", v⟩
def hidden_ : Attr := ⟨"hidden", ""⟩
def tabindex_ (v : Int) : Attr := ⟨"tabindex", toString v⟩

-- Data attributes
def data_ (name : String) (v : String) : Attr := ⟨s!"data-{name}", v⟩

-- Link/navigation attributes
def href_ (v : String) : Attr := ⟨"href", v⟩
def target_ (v : String) : Attr := ⟨"target", v⟩
def rel_ (v : String) : Attr := ⟨"rel", v⟩
def download_ (v : String := "") : Attr := ⟨"download", v⟩

-- Image/media attributes
def src_ (v : String) : Attr := ⟨"src", v⟩
def alt_ (v : String) : Attr := ⟨"alt", v⟩
def width_ (v : Nat) : Attr := ⟨"width", toString v⟩
def height_ (v : Nat) : Attr := ⟨"height", toString v⟩
def loading_ (v : String) : Attr := ⟨"loading", v⟩

-- Form attributes
def action_ (v : String) : Attr := ⟨"action", v⟩
def method_ (v : String) : Attr := ⟨"method", v⟩
def enctype_ (v : String) : Attr := ⟨"enctype", v⟩
def name_ (v : String) : Attr := ⟨"name", v⟩
def value_ (v : String) : Attr := ⟨"value", v⟩
def type_ (v : String) : Attr := ⟨"type", v⟩
def placeholder_ (v : String) : Attr := ⟨"placeholder", v⟩
def required_ : Attr := ⟨"required", ""⟩
def disabled_ : Attr := ⟨"disabled", ""⟩
def readonly_ : Attr := ⟨"readonly", ""⟩
def checked_ : Attr := ⟨"checked", ""⟩
def selected_ : Attr := ⟨"selected", ""⟩
def multiple_ : Attr := ⟨"multiple", ""⟩
def autofocus_ : Attr := ⟨"autofocus", ""⟩
def autocomplete_ (v : String) : Attr := ⟨"autocomplete", v⟩
def min_ (v : String) : Attr := ⟨"min", v⟩
def max_ (v : String) : Attr := ⟨"max", v⟩
def step_ (v : String) : Attr := ⟨"step", v⟩
def pattern_ (v : String) : Attr := ⟨"pattern", v⟩
def maxlength_ (v : Nat) : Attr := ⟨"maxlength", toString v⟩
def minlength_ (v : Nat) : Attr := ⟨"minlength", toString v⟩
def for_ (v : String) : Attr := ⟨"for", v⟩
def rows_ (v : Nat) : Attr := ⟨"rows", toString v⟩
def cols_ (v : Nat) : Attr := ⟨"cols", toString v⟩

-- Table attributes
def colspan_ (v : Nat) : Attr := ⟨"colspan", toString v⟩
def rowspan_ (v : Nat) : Attr := ⟨"rowspan", toString v⟩
def scope_ (v : String) : Attr := ⟨"scope", v⟩

-- Meta/head attributes
def charset_ (v : String) : Attr := ⟨"charset", v⟩
def content_ (v : String) : Attr := ⟨"content", v⟩
def httpEquiv_ (v : String) : Attr := ⟨"http-equiv", v⟩

-- Script/style attributes
def async_ : Attr := ⟨"async", ""⟩
def defer_ : Attr := ⟨"defer", ""⟩
def integrity_ (v : String) : Attr := ⟨"integrity", v⟩
def crossorigin_ (v : String) : Attr := ⟨"crossorigin", v⟩

-- ARIA attributes
-- Labels and descriptions
def ariaLabel_ (v : String) : Attr := ⟨"aria-label", v⟩
def ariaDescribedby_ (v : String) : Attr := ⟨"aria-describedby", v⟩
def ariaLabelledby_ (v : String) : Attr := ⟨"aria-labelledby", v⟩
def ariaDetails_ (v : String) : Attr := ⟨"aria-details", v⟩
def role_ (v : String) : Attr := ⟨"role", v⟩

-- State attributes
def ariaHidden_ (v : Bool) : Attr := ⟨"aria-hidden", if v then "true" else "false"⟩
def ariaExpanded_ (v : Bool) : Attr := ⟨"aria-expanded", if v then "true" else "false"⟩
def ariaPressed_ (v : Bool) : Attr := ⟨"aria-pressed", if v then "true" else "false"⟩
def ariaSelected_ (v : Bool) : Attr := ⟨"aria-selected", if v then "true" else "false"⟩
def ariaChecked_ (v : Bool) : Attr := ⟨"aria-checked", if v then "true" else "false"⟩
def ariaCurrent_ (v : String) : Attr := ⟨"aria-current", v⟩

-- Widget attributes
def ariaDisabled_ (v : Bool) : Attr := ⟨"aria-disabled", if v then "true" else "false"⟩
def ariaInvalid_ (v : Bool) : Attr := ⟨"aria-invalid", if v then "true" else "false"⟩
def ariaRequired_ (v : Bool) : Attr := ⟨"aria-required", if v then "true" else "false"⟩
def ariaReadonly_ (v : Bool) : Attr := ⟨"aria-readonly", if v then "true" else "false"⟩
def ariaHaspopup_ (v : String) : Attr := ⟨"aria-haspopup", v⟩
def ariaAutocomplete_ (v : String) : Attr := ⟨"aria-autocomplete", v⟩
def ariaMultiselectable_ (v : Bool) : Attr := ⟨"aria-multiselectable", if v then "true" else "false"⟩
def ariaOrientation_ (v : String) : Attr := ⟨"aria-orientation", v⟩
def ariaPlaceholder_ (v : String) : Attr := ⟨"aria-placeholder", v⟩
def ariaSort_ (v : String) : Attr := ⟨"aria-sort", v⟩

-- Range attributes
def ariaValuenow_ (v : Float) : Attr := ⟨"aria-valuenow", toString v⟩
def ariaValuemin_ (v : Float) : Attr := ⟨"aria-valuemin", toString v⟩
def ariaValuemax_ (v : Float) : Attr := ⟨"aria-valuemax", toString v⟩
def ariaValuetext_ (v : String) : Attr := ⟨"aria-valuetext", v⟩

-- Relationship attributes
def ariaControls_ (v : String) : Attr := ⟨"aria-controls", v⟩
def ariaOwns_ (v : String) : Attr := ⟨"aria-owns", v⟩
def ariaFlowto_ (v : String) : Attr := ⟨"aria-flowto", v⟩
def ariaActivedescendant_ (v : String) : Attr := ⟨"aria-activedescendant", v⟩
def ariaColcount_ (v : Int) : Attr := ⟨"aria-colcount", toString v⟩
def ariaColindex_ (v : Int) : Attr := ⟨"aria-colindex", toString v⟩
def ariaColspan_ (v : Int) : Attr := ⟨"aria-colspan", toString v⟩
def ariaRowcount_ (v : Int) : Attr := ⟨"aria-rowcount", toString v⟩
def ariaRowindex_ (v : Int) : Attr := ⟨"aria-rowindex", toString v⟩
def ariaRowspan_ (v : Int) : Attr := ⟨"aria-rowspan", toString v⟩
def ariaPosinset_ (v : Int) : Attr := ⟨"aria-posinset", toString v⟩
def ariaSetsize_ (v : Int) : Attr := ⟨"aria-setsize", toString v⟩
def ariaLevel_ (v : Int) : Attr := ⟨"aria-level", toString v⟩

-- Live region attributes
def ariaLive_ (v : String) : Attr := ⟨"aria-live", v⟩
def ariaAtomic_ (v : Bool) : Attr := ⟨"aria-atomic", if v then "true" else "false"⟩
def ariaBusy_ (v : Bool) : Attr := ⟨"aria-busy", if v then "true" else "false"⟩
def ariaRelevant_ (v : String) : Attr := ⟨"aria-relevant", v⟩

-- Drag and drop (deprecated but still used)
def ariaDropeffect_ (v : String) : Attr := ⟨"aria-dropeffect", v⟩
def ariaGrabbed_ (v : Bool) : Attr := ⟨"aria-grabbed", if v then "true" else "false"⟩

-- Keyboard attributes
def ariaKeyshortcuts_ (v : String) : Attr := ⟨"aria-keyshortcuts", v⟩
def ariaRoledescription_ (v : String) : Attr := ⟨"aria-roledescription", v⟩

-- Error attributes
def ariaErrormessage_ (v : String) : Attr := ⟨"aria-errormessage", v⟩

-- Modal attribute
def ariaModal_ (v : Bool) : Attr := ⟨"aria-modal", if v then "true" else "false"⟩

-- Event handler placeholders (values would be JS code)
def onclick_ (v : String) : Attr := ⟨"onclick", v⟩
def onsubmit_ (v : String) : Attr := ⟨"onsubmit", v⟩
def onchange_ (v : String) : Attr := ⟨"onchange", v⟩
def oninput_ (v : String) : Attr := ⟨"oninput", v⟩

-- HTMX attributes
-- Core request attributes
def hx_get (v : String) : Attr := ⟨"hx-get", v⟩
def hx_post (v : String) : Attr := ⟨"hx-post", v⟩
def hx_put (v : String) : Attr := ⟨"hx-put", v⟩
def hx_patch (v : String) : Attr := ⟨"hx-patch", v⟩
def hx_delete (v : String) : Attr := ⟨"hx-delete", v⟩

-- Targeting and swapping
def hx_target (v : String) : Attr := ⟨"hx-target", v⟩
def hx_swap (v : String) : Attr := ⟨"hx-swap", v⟩
def hx_select (v : String) : Attr := ⟨"hx-select", v⟩
def hx_select_oob (v : String) : Attr := ⟨"hx-select-oob", v⟩
def hx_swap_oob (v : String) : Attr := ⟨"hx-swap-oob", v⟩

-- Triggering
def hx_trigger (v : String) : Attr := ⟨"hx-trigger", v⟩
def hx_confirm (v : String) : Attr := ⟨"hx-confirm", v⟩

-- Request modifiers
def hx_vals (v : String) : Attr := ⟨"hx-vals", v⟩
def hx_headers (v : String) : Attr := ⟨"hx-headers", v⟩
def hx_include (v : String) : Attr := ⟨"hx-include", v⟩
def hx_params (v : String) : Attr := ⟨"hx-params", v⟩
def hx_encoding (v : String) : Attr := ⟨"hx-encoding", v⟩

-- UI feedback
def hx_indicator (v : String) : Attr := ⟨"hx-indicator", v⟩
def hx_disabled_elt (v : String) : Attr := ⟨"hx-disabled-elt", v⟩

-- History and URL
def hx_push_url (v : String) : Attr := ⟨"hx-push-url", v⟩
def hx_replace_url (v : String) : Attr := ⟨"hx-replace-url", v⟩
def hx_history_elt : Attr := ⟨"hx-history-elt", ""⟩

-- Other
def hx_boost (v : String := "true") : Attr := ⟨"hx-boost", v⟩
def hx_ext (v : String) : Attr := ⟨"hx-ext", v⟩
def hx_preserve : Attr := ⟨"hx-preserve", ""⟩
def hx_sync (v : String) : Attr := ⟨"hx-sync", v⟩
def hx_disinherit (v : String) : Attr := ⟨"hx-disinherit", v⟩
def hx_validate (v : String := "true") : Attr := ⟨"hx-validate", v⟩
def hx_request (v : String) : Attr := ⟨"hx-request", v⟩
def hx_inherit (v : String) : Attr := ⟨"hx-inherit", v⟩

-- Generic event handler (hx-on:event="handler")
def hx_on (event : String) (handler : String) : Attr := ⟨s!"hx-on:{event}", handler⟩

-- WebSocket support
def hx_ws (v : String) : Attr := ⟨"hx-ws", v⟩
def hx_ws_connect (url : String) : Attr := ⟨"hx-ws", s!"connect:{url}"⟩
def hx_ws_send : Attr := ⟨"hx-ws", "send"⟩

-- Server-Sent Events support
def hx_sse (v : String) : Attr := ⟨"hx-sse", v⟩
def hx_sse_connect (url : String) : Attr := ⟨"hx-sse", s!"connect:{url}"⟩
def hx_sse_swap (event : String) : Attr := ⟨"hx-sse", s!"swap:{event}"⟩

-- Generic attribute constructor
def attr_ (name : String) (value : String) : Attr := ⟨name, value⟩

-- ============================================================================
-- Conditional attribute helpers
-- ============================================================================

/-- Include an attribute only if the condition is true. Returns empty list if false. -/
def attr_if (condition : Bool) (a : Attr) : List Attr :=
  if condition then [a] else []

/-- Include a class only if the condition is true. Returns empty list if false. -/
def class_if (condition : Bool) (className : String) : List Attr :=
  if condition then [class_ className] else []

/-- Build a class attribute from a list of (condition, className) pairs.
    Only class names where the condition is true are included. -/
def classes (classNames : List (Bool × String)) : Attr :=
  class_ (classNames.filter (·.1) |>.map (·.2) |> String.intercalate " ")

/-- Build a class attribute from class names, filtering out empty strings. -/
def classNames (names : List String) : Attr :=
  class_ (names.filter (· != "") |> String.intercalate " ")

-- ============================================================================
-- Attribute merging
-- ============================================================================

/-- Attributes that should be merged (values concatenated) rather than replaced. -/
def mergeableAttrs : List String := ["class", "style"]

/-- Check if an attribute name should be merged rather than replaced. -/
def isMergeableAttr (name : String) : Bool :=
  mergeableAttrs.contains name

/-- Merge two attribute lists intelligently.
    - For `class` and `style` attributes: values are concatenated with a space
    - For other attributes: later values override earlier ones
    - Preserves order, with attrs2 values appearing after attrs1 values

    Example:
    ```
    mergeAttrs [class_ "card", id_ "x"] [class_ "large", id_ "y"]
    -- Result: [class_ "card large", id_ "y"]
    ```
-/
def mergeAttrs (attrs1 attrs2 : List Attr) : List Attr :=
  let merged : Std.HashMap String String := attrs1.foldl (init := {}) fun acc attr =>
    acc.insert attr.name attr.value
  let merged := attrs2.foldl (init := merged) fun acc attr =>
    if isMergeableAttr attr.name then
      match acc[attr.name]? with
      | some existing =>
        let newValue := if existing.isEmpty then attr.value
                        else if attr.value.isEmpty then existing
                        else s!"{existing} {attr.value}"
        acc.insert attr.name newValue
      | none => acc.insert attr.name attr.value
    else
      acc.insert attr.name attr.value
  -- Preserve order: attrs1 names first (in order), then new names from attrs2
  let names1 := attrs1.map (·.name)
  let names2 := attrs2.map (·.name) |>.filter (· ∉ names1)
  let allNames := names1 ++ names2
  allNames.filterMap fun name =>
    merged[name]? |>.map fun value => ⟨name, value⟩

/-- Operator for merging attribute lists. Alias for `mergeAttrs`. -/
def Attr.merge (attrs1 attrs2 : List Attr) : List Attr :=
  mergeAttrs attrs1 attrs2

/-- Infix operator for attribute merging. -/
infixl:65 " +++ " => Attr.merge

-- ============================================================================
-- Type-safe HTMX targeting
-- ============================================================================

/-- Wrapper type documenting intent to target a volatile region.
    Use this with hx_target_vol to indicate the target is safe to refresh. -/
structure VolatileTarget where
  id : String
  deriving Repr

/-- Create a volatile target reference.
    Documents that the referenced ID should be a volatile region. -/
def volatileTarget (id : String) : VolatileTarget := ⟨id⟩

/-- HTMX target that explicitly documents it references a volatile region.
    Prefer this over hx_target for type-safe HTMX development. -/
def hx_target_vol (target : VolatileTarget) : Attr :=
  ⟨"hx-target", "#" ++ target.id⟩

end Scribe
