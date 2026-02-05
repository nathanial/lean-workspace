# Scribe Roadmap

This document outlines planned features, enhancements, and cleanup tasks for the Scribe HTML builder library.

---

## New Features

### [Priority: High] Component System with Slots

**Description:** Add a component abstraction that supports named slots for composable UI patterns.

**Rationale:** Real-world usage in homebase-app and todo-app shows repeated patterns like layouts, cards, and modals that would benefit from a formal component system. Currently, users must pass `HtmlM Unit` arguments manually.

**Proposed API:**
```lean
-- Define a component with slots
component "Card" do
  slot "header"
  slot "body"
  slot "footer" (optional := true)

-- Use the component
card do
  header do h3 [] (text "Title")
  body do p [] (text "Content")
```

**Affected Files:** New file `Scribe/Component.lean`, updates to `Scribe.lean`
**Estimated Effort:** Large
**Dependencies:** None

---

### [Priority: High] DOCTYPE Declaration Helper

**Description:** Add a `doctype` helper to emit `<!DOCTYPE html>` properly.

**Rationale:** Current usage requires `raw "<!DOCTYPE html>"` which is error-prone and inconsistent. Every layout in homebase-app and todo-app uses this pattern.

**Proposed API:**
```lean
def doctype : HtmlM Unit := raw "<!DOCTYPE html>\n"
```

**Affected Files:** `Scribe/Elements.lean`
**Estimated Effort:** Small
**Dependencies:** None

---

### [Priority: High] Conditional Attribute Helpers

**Description:** Add helpers for conditionally including attributes.

**Rationale:** Common pattern in real applications: `if isActive then class_ "active" else class_ ""`. Need cleaner approach.

**Proposed API:**
```lean
def class_if (condition : Bool) (className : String) : List Attr :=
  if condition then [class_ className] else []

def classes (classNames : List (Bool × String)) : Attr :=
  class_ (classNames.filter (·.1) |>.map (·.2) |> String.intercalate " ")

-- Usage:
div (class_if isActive "active" ++ [id_ "main"]) do ...
div [classes [(true, "card"), (isLarge, "card-lg"), (isDark, "dark")]] do ...
```

**Affected Files:** `Scribe/Attr.lean`
**Estimated Effort:** Small
**Dependencies:** None

---

### [Priority: High] Attribute Merging/Concatenation

**Description:** Allow combining attribute lists and merging class attributes intelligently.

**Rationale:** When composing components, class attributes from different sources need to be merged rather than overwritten.

**Proposed API:**
```lean
def mergeAttrs (attrs1 attrs2 : List Attr) : List Attr
-- Classes are concatenated, other attrs use attrs2 if duplicate

-- Instance for convenient syntax
instance : Append (List Attr) where
  append := mergeAttrs
```

**Affected Files:** `Scribe/Attr.lean` or new `Scribe/AttrMerge.lean`
**Estimated Effort:** Medium
**Dependencies:** None

---

### [Priority: Medium] PageGraph Implementation

**Description:** Implement the PageGraph design document for reified HTMX interaction models.

**Rationale:** Design doc exists at `docs/PageGraph-Design.md` with a complete specification for verifiable HTMX page structure. This would enable:
- Compile-time verification that all HTMX targets exist
- Detection of orphaned regions and circular references
- Auto-generation of interaction documentation

**Affected Files:** New `Scribe/PageGraph.lean`, `Scribe/PageGraph/Types.lean`, `Scribe/PageGraph/Verify.lean`
**Estimated Effort:** Large
**Dependencies:** None (design doc exists)

---

### [Priority: Medium] SVG Element Support

**Description:** Add SVG element builders for inline SVG graphics.

**Rationale:** SVG is commonly needed for icons, charts, and graphics. Currently requires raw HTML.

**Proposed API:**
```lean
def svg (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit
def path (attrs : List Attr) : HtmlM Unit
def circle (attrs : List Attr) : HtmlM Unit
def rect (attrs : List Attr) : HtmlM Unit
def line (attrs : List Attr) : HtmlM Unit
def polyline (attrs : List Attr) : HtmlM Unit
def polygon (attrs : List Attr) : HtmlM Unit
def g (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit
def defs (children : HtmlM Unit) : HtmlM Unit
def use (attrs : List Attr) : HtmlM Unit
-- SVG-specific attributes
def viewBox_ (v : String) : Attr
def d_ (v : String) : Attr
def fill_ (v : String) : Attr
def stroke_ (v : String) : Attr
def strokeWidth_ (v : String) : Attr
```

**Affected Files:** New `Scribe/Svg.lean`, updates to `Scribe.lean`
**Estimated Effort:** Medium
**Dependencies:** None

---

### [Priority: Medium] Template Fragments / Partials

**Description:** Support named template fragments that can be reused across views.

**Rationale:** Applications often have repeated partial templates (e.g., flash messages, CSRF fields). These are currently defined as functions, but a more formal partial system would improve organization.

**Proposed API:**
```lean
partial "flash_messages" (ctx : Context) do
  if let some msg := ctx.flash.get "success" then
    div [class_ "flash flash-success"] (text msg)

-- Include partial
include_partial "flash_messages" ctx
```

**Affected Files:** New `Scribe/Partial.lean`, potentially macro support
**Estimated Effort:** Medium
**Dependencies:** None

---

### [Priority: Medium] Form Builder DSL

**Description:** Higher-level form building with automatic CSRF, validation display, and field generation.

**Rationale:** Forms are repetitive (label + input + error). A DSL would reduce boilerplate.

**Proposed API:**
```lean
formFor (ctx : Context) (action : String) (method : String := "POST") do
  field "email" "Email" [type_ "email", required_]
  field "password" "Password" [type_ "password", required_, minlength_ 8]
  submitButton "Log In"
```

**Affected Files:** New `Scribe/Form.lean`
**Estimated Effort:** Medium
**Dependencies:** None

---

### [Priority: Medium] Custom Element Support (Web Components)

**Description:** Support for custom HTML elements with hyphenated names.

**Rationale:** Web Components use custom element names like `<my-component>`. Current API doesn't easily support this.

**Proposed API:**
```lean
def customElement (tag : String) (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit
-- Or shorter:
def el (tag : String) (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit
```

**Affected Files:** `Scribe/Elements.lean`
**Estimated Effort:** Small
**Dependencies:** None

---

### [Priority: Low] Streaming HTML Rendering

**Description:** Support incremental HTML rendering for large pages.

**Rationale:** For very large pages, building the entire Html tree before rendering may be inefficient. Streaming could emit HTML as it's built.

**Affected Files:** New `Scribe/Stream.lean`, updates to `Scribe/Builder.lean`
**Estimated Effort:** Large
**Dependencies:** IO integration

---

### [Priority: Low] HTML Minification

**Description:** Option to minify HTML output by removing unnecessary whitespace.

**Rationale:** Production deployments benefit from smaller HTML payloads.

**Proposed API:**
```lean
def HtmlM.renderMinified : HtmlM Unit -> String
```

**Affected Files:** `Scribe/Html.lean`
**Estimated Effort:** Small
**Dependencies:** None

---

### [Priority: Low] Template Literal Interpolation

**Description:** Macro for embedding Scribe templates in string-like syntax with interpolation.

**Rationale:** Some developers prefer template literal syntax over do-notation for simple HTML.

**Proposed API:**
```lean
html! "<div class=\"{className}\">{content}</div>"
```

**Affected Files:** New `Scribe/TemplateMacro.lean`
**Estimated Effort:** Large
**Dependencies:** Lean macro expertise

---

## Enhancements

### [Priority: High] Missing HTML5 Elements

**Current State:** 60+ elements exist but some HTML5 elements are missing.

**Proposed Change:** Add missing elements:
- `<address>` - Contact information
- `<bdi>`, `<bdo>` - Bidirectional text
- `<cite>` - Citation
- `<data>` - Machine-readable value
- `<dfn>` - Definition
- `<ins>`, `<del>` - Inserted/deleted text
- `<q>` - Inline quotation
- `<ruby>`, `<rt>`, `<rp>` - Ruby annotations
- `<template>` - Template element
- `<slot>` - Web component slot
- `<wbr>` - Word break opportunity (void element)
- `<canvas>` - Graphics canvas
- `<noscript>` - Fallback for no JavaScript
- `<object>`, `<param>` - Embedded object
- `<map>`, `<area>` - Image maps
- `<track>` - Media track (void element)
- `<colgroup>`, `<col>` - Table column groups

**Benefits:** Complete HTML5 coverage
**Affected Files:** `Scribe/Elements.lean`, `Scribe/Html.lean` (voidElements list)
**Estimated Effort:** Small

---

### [Priority: High] Missing ARIA Attributes

**Current State:** Only 5 ARIA attributes are defined.

**Proposed Change:** Add comprehensive ARIA support:
- `ariaExpanded_`, `ariaPressed_`, `ariaSelected_` - State attributes
- `ariaControls_`, `ariaOwns_`, `ariaFlowto_` - Relationship attributes
- `ariaLive_`, `ariaAtomic_`, `ariaBusy_` - Live region attributes
- `ariaDisabled_`, `ariaInvalid_`, `ariaRequired_` - Widget attributes
- `ariaValuenow_`, `ariaValuemin_`, `ariaValuemax_` - Range attributes
- `ariaHaspopup_`, `ariaAutocomplete_` - Popup attributes
- `ariaLevel_`, `ariaSetsize_`, `ariaPosinset_` - Structure attributes

**Benefits:** Better accessibility support
**Affected Files:** `Scribe/Attr.lean`
**Estimated Effort:** Small

---

### [Priority: High] Missing HTMX Attributes

**Current State:** Many HTMX attributes defined but some recent additions missing.

**Proposed Change:** Add:
- `hx_on (event : String) (handler : String)` - Generic event handler
- `hx_disinherit` - Disable inheritance
- `hx_validate` - Client-side validation
- `hx_request` - Request configuration
- `hx_ws` - WebSocket support
- `hx_sse` - SSE support

**Benefits:** Complete HTMX coverage
**Affected Files:** `Scribe/Attr.lean`
**Estimated Effort:** Small

---

### [Priority: Medium] Type-Safe Attribute Values

**Current State:** Attributes like `type_`, `method_`, `target_` accept any String.

**Proposed Change:** Add type-safe variants with constrained values:
```lean
inductive InputType where
  | text | password | email | number | checkbox | radio | hidden | submit | ...

def inputType (t : InputType) : Attr := type_ (toString t)

-- Usage: input [inputType .email, name_ "email"]
```

**Benefits:** Compile-time validation of common attribute values
**Affected Files:** `Scribe/Attr.lean` or new `Scribe/AttrTypes.lean`
**Estimated Effort:** Medium

---

### [Priority: Medium] Better Pretty Printing

**Current State:** `renderPretty` exists but has limited formatting options.

**Proposed Change:**
- Configurable indentation (spaces vs tabs, indent size)
- Option to keep inline elements on same line
- Option to preserve significant whitespace in `<pre>`
- Maximum line length with wrapping

**Benefits:** More readable HTML output for debugging
**Affected Files:** `Scribe/Html.lean`
**Estimated Effort:** Medium

---

### [Priority: Medium] Builder Performance Optimization

**Current State:** `BuilderState` uses `Array Html` with `push` operations.

**Proposed Change:**
- Consider using a difference list for O(1) append
- Add benchmarks to measure current performance
- Consider lazy evaluation for unused branches

**Benefits:** Better performance for large pages
**Affected Files:** `Scribe/Builder.lean`
**Estimated Effort:** Medium

---

### [Priority: Low] Html Equality Instance

**Current State:** `Html` only has `Repr`, no `BEq` or `DecidableEq`.

**Proposed Change:** Add instances for testing and comparison:
```lean
deriving instance BEq for Html
-- Or manual implementation handling fragment normalization
```

**Benefits:** Enables testing with `shouldBe`
**Affected Files:** `Scribe/Html.lean`
**Estimated Effort:** Small

---

### [Priority: Low] Monadic Attribute Building

**Current State:** Attributes are built as lists, no monadic interface.

**Proposed Change:** Add an `AttrM` monad for fluent attribute construction:
```lean
def AttrM := StateM (List Attr)

def myAttrs : AttrM Unit := do
  addClass "container"
  when isActive (addClass "active")
  addId "main"
```

**Benefits:** More flexible attribute construction with control flow
**Affected Files:** New `Scribe/AttrM.lean`
**Estimated Effort:** Small

---

## Bug Fixes

### [Priority: Medium] Boolean Attributes Rendering

**Issue:** Boolean attributes like `required_`, `disabled_` render as `required=""` but HTML5 spec prefers just `required`.

**Location:** `/Users/Shared/Projects/lean-workspace/scribe/Scribe/Html.lean`, lines 54-57

**Action Required:**
- Add a `boolean` field to `Attr` structure, or
- Check for empty value in `renderAttrs` and omit `=""`

**Estimated Effort:** Small

---

### [Priority: Low] Attribute Order Sensitivity

**Issue:** Multiple attributes with same name are all rendered. Class attributes should be merged.

**Location:** `/Users/Shared/Projects/lean-workspace/scribe/Scribe/Html.lean`, `renderAttrs` function

**Action Required:** Consider deduplication or merging logic for `class` attributes.

**Estimated Effort:** Small

---

## Code Cleanup

### [Priority: Medium] Consolidate Text Emission Functions

**Issue:** Both `HtmlM.text`/`HtmlM.raw` and `text`/`raw` exist as separate definitions.

**Location:**
- `/Users/Shared/Projects/lean-workspace/scribe/Scribe/Builder.lean`, lines 31-37
- `/Users/Shared/Projects/lean-workspace/scribe/Scribe/Elements.lean`, lines 284-285

**Action Required:** Remove duplication by having `text`/`raw` in Elements.lean just re-export the HtmlM versions, or consolidate into one location.

**Estimated Effort:** Small

---

### [Priority: Medium] Inconsistent Element Naming

**Issue:** Some elements have underscore suffixes (`meta_`, `section_`) while most don't.

**Location:** `/Users/Shared/Projects/lean-workspace/scribe/Scribe/Elements.lean`

**Action Required:** Document the naming convention clearly. Elements conflicting with Lean keywords use underscore suffix. Consider adding aliases without underscore using namespacing.

**Estimated Effort:** Small

---

### [Priority: Low] Add Module Documentation

**Issue:** Source files have minimal doc comments.

**Location:** All files in `/Users/Shared/Projects/lean-workspace/scribe/Scribe/`

**Action Required:** Add module-level documentation strings explaining purpose, key types, and usage patterns.

**Estimated Effort:** Small

---

### [Priority: Low] Organize Attributes by Category

**Issue:** Attributes in `Attr.lean` are grouped by comment but could be organized into sub-namespaces.

**Location:** `/Users/Shared/Projects/lean-workspace/scribe/Scribe/Attr.lean`

**Action Required:** Consider organizing into `Scribe.Attr.Global`, `Scribe.Attr.Form`, `Scribe.Attr.HTMX`, etc. with re-exports from main namespace.

**Estimated Effort:** Medium

---

## Documentation

### [Priority: High] API Reference Documentation

**Issue:** README provides overview but lacks comprehensive API reference.

**Action Required:**
- Document all public functions with doc comments
- Generate API documentation
- Add examples for less obvious functions

**Location:** All source files
**Estimated Effort:** Medium

---

### [Priority: Medium] Usage Guide with Patterns

**Issue:** No guide for common patterns like layouts, components, HTMX integration.

**Action Required:** Create `docs/Guide.md` covering:
- Basic HTML building
- Layouts and composition
- Control flow (if/for/match)
- HTMX integration patterns
- Form handling
- Type-safe routes

**Estimated Effort:** Medium

---

### [Priority: Medium] Complete PageGraph Design Doc

**Issue:** Design document at `docs/PageGraph-Design.md` has `sorry` placeholders and open questions.

**Action Required:**
- Implement or remove `sorry` sections
- Answer open questions or document decisions
- Add implementation status

**Estimated Effort:** Small

---

### [Priority: Low] Add CHANGELOG

**Issue:** No changelog tracking version history.

**Action Required:** Create `CHANGELOG.md` following Keep a Changelog format.

**Estimated Effort:** Small

---

## Testing

### [Priority: High] Test RouteAttrs Module

**Issue:** `Scribe/RouteAttrs.lean` has no test coverage.

**Location:** `/Users/Shared/Projects/lean-workspace/scribe/Tests/Builder.lean`

**Action Required:** Add tests for:
- `HasPath` typeclass
- Type-safe HTMX attribute helpers (`hx_get'`, `hx_post'`, etc.)
- `href'`, `src'`, `action'`

**Estimated Effort:** Small

---

### [Priority: High] Test VolatileTarget

**Issue:** `VolatileTarget` and `hx_target_vol` in `Attr.lean` have no test coverage.

**Location:** `/Users/Shared/Projects/lean-workspace/scribe/Tests/Builder.lean`

**Action Required:** Add tests verifying correct targeting behavior.

**Estimated Effort:** Small

---

### [Priority: Medium] Test Pretty Printing

**Issue:** `Html.renderPretty` has no test coverage.

**Location:** `/Users/Shared/Projects/lean-workspace/scribe/Tests/Builder.lean`

**Action Required:** Add tests for:
- Correct indentation
- Void element handling
- Nested element formatting
- Single child optimization

**Estimated Effort:** Small

---

### [Priority: Medium] Edge Case Tests

**Issue:** Missing edge case coverage for escaping.

**Action Required:** Add tests for:
- Unicode characters in text and attributes
- Empty strings
- Very long content
- Newlines in attributes
- Null/control characters

**Estimated Effort:** Small

---

### [Priority: Medium] Property-Based Testing

**Issue:** Tests are example-based only.

**Action Required:**
- Add plausible (property-based testing) dependency
- Add properties like:
  - `render(parse(html)) == html` (round-trip for subset)
  - Text content is always properly escaped
  - Void elements never have closing tags

**Estimated Effort:** Medium
**Dependencies:** plausible library

---

### [Priority: Low] Benchmark Suite

**Issue:** No performance benchmarks.

**Action Required:** Create benchmarks measuring:
- Build time for large documents
- Render time
- Memory usage

**Estimated Effort:** Medium

---

## Comparisons to Other Libraries

### Inspiration from Elm's Html

- Elm uses `Html msg` with message types for events
- Consider: Event abstraction for HTMX-like patterns

### Inspiration from Lucid (Haskell)

- Lucid uses `HtmlT m a` transformer
- Consider: `HtmlT m Unit` for effects during rendering

### Inspiration from ScalaTags

- ScalaTags uses `TypedTag[Output]` with phantom types
- Consider: Phantom types for element categories (block, inline, void)

### Inspiration from Hiccup (Clojure)

- Hiccup uses data literals: `[:div {:class "foo"} "content"]`
- Consider: Compile-time macro for similar terseness

---

## Implementation Priority Summary

### Phase 1 (Quick Wins) ✅ COMPLETED
1. ~~DOCTYPE helper (High, Small)~~ ✅
2. ~~Conditional attribute helpers (High, Small)~~ ✅
3. ~~Missing HTML5 elements (High, Small)~~ ✅
4. ~~Missing ARIA attributes (High, Small)~~ ✅
5. ~~Missing HTMX attributes (High, Small)~~ ✅
6. ~~Test RouteAttrs (High, Small)~~ ✅
7. ~~Test VolatileTarget (High, Small)~~ ✅

### Phase 2 (Core Improvements)
1. ~~Attribute merging (High, Medium)~~ ✅
2. ~~Component system (High, Large)~~ ✅
3. ~~SVG support (Medium, Medium)~~ ✅
4. Form builder DSL (Medium, Medium)
5. ~~Type-safe attribute values (Medium, Medium)~~ ✅
6. API documentation (High, Medium)

### Phase 3 (Advanced Features)
1. PageGraph implementation (Medium, Large)
2. Template fragments (Medium, Medium)
3. Property-based testing (Medium, Medium)
4. Streaming rendering (Low, Large)
5. Template literals (Low, Large)

---

*Last updated: 2025-12-27*
