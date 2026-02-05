/-
  Tests for Scribe component system
-/
import Scribe
import Crucible

namespace ScribeTests.Components

open Crucible
open Scribe
open Scribe.Components

testSuite "Scribe Components"

-- Helper for string containment checks
def strContains (haystack needle : String) : Bool :=
  (haystack.splitOn needle).length > 1

-- ============================================================================
-- HtmlM.hasContent Tests
-- ============================================================================

test "HtmlM.hasContent returns true for text content" := do
  let m := text "Hello"
  HtmlM.hasContent m ≡ true

test "HtmlM.hasContent returns false for pure ()" := do
  let m : HtmlM Unit := pure ()
  HtmlM.hasContent m ≡ false

test "HtmlM.hasContent returns false for emptySlot" := do
  HtmlM.hasContent emptySlot ≡ false

test "HtmlM.hasContent returns true for element" := do
  let m := div [] (text "Content")
  HtmlM.hasContent m ≡ true

test "HtmlM.hasContent returns true for nested elements" := do
  let m := div [] do
    p [] (text "Nested")
  HtmlM.hasContent m ≡ true

test "HtmlM.isEmpty returns true for pure ()" := do
  let m : HtmlM Unit := pure ()
  HtmlM.isEmpty m ≡ true

test "HtmlM.isEmpty returns false for text content" := do
  let m := text "Hello"
  HtmlM.isEmpty m ≡ false

-- ============================================================================
-- Optional Slot Helper Tests
-- ============================================================================

test "hasSlot returns true for some" := do
  hasSlot (some (text "Content")) ≡ true

test "hasSlot returns false for none" := do
  hasSlot (none : Option (HtmlM Unit)) ≡ false

test "hasSlotContent returns true for some with content" := do
  hasSlotContent (some (text "Content")) ≡ true

test "hasSlotContent returns false for some with empty" := do
  hasSlotContent (some (pure ())) ≡ false

test "hasSlotContent returns false for none" := do
  hasSlotContent (none : Option (HtmlM Unit)) ≡ false

test "renderSlot renders some content" := do
  let result := HtmlM.render do
    renderSlot (some (text "Hello"))
  result ≡ "Hello"

test "renderSlot renders nothing for none" := do
  let result := HtmlM.render do
    renderSlot (none : Option (HtmlM Unit))
  result ≡ ""

test "whenSlot applies wrapper for some" := do
  let result := HtmlM.render do
    whenSlot (some (text "Inner")) fun content =>
      div [class_ "wrapper"] content
  result ≡ "<div class=\"wrapper\">Inner</div>"

test "whenSlot skips wrapper for none" := do
  let result := HtmlM.render do
    whenSlot (none : Option (HtmlM Unit)) fun content =>
      div [class_ "wrapper"] content
  result ≡ ""

-- ============================================================================
-- Attribute Helper Tests
-- ============================================================================

test "withClass merges base class with user attrs" := do
  let attrs := withClass "card" [class_ "large", id_ "main"]
  attrs.length ≡ 2
  (attrs.head!.name, attrs.head!.value) ≡ ("class", "card large")

test "withClass works with empty user attrs" := do
  let attrs := withClass "card" []
  attrs.length ≡ 1
  attrs.head!.value ≡ "card"

test "componentAttrs merges attributes" := do
  let attrs := componentAttrs [class_ "btn", type_ "button"] [type_ "submit"]
  let typeAttr := attrs.find? (·.name == "type")
  typeAttr.map (·.value) ≡ some "submit"

test "componentAttrs concatenates class attributes" := do
  let attrs := componentAttrs [class_ "btn"] [class_ "btn-primary"]
  let classAttr := attrs.find? (·.name == "class")
  classAttr.map (·.value) ≡ some "btn btn-primary"

-- ============================================================================
-- Card Component Tests
-- ============================================================================

test "simpleCard renders with body only" := do
  let result := HtmlM.render do
    simpleCard [] (text "Body content")
  result ≡ "<div class=\"card\"><div class=\"card-body\">Body content</div></div>"

test "card renders with all slots" := do
  let result := HtmlM.render do
    card [] {
      header := some (text "Header"),
      body := text "Body",
      footer := some (text "Footer")
    }
  result ≡ "<div class=\"card\"><div class=\"card-header\">Header</div><div class=\"card-body\">Body</div><div class=\"card-footer\">Footer</div></div>"

test "card skips none slots" := do
  let result := HtmlM.render do
    card [] {
      header := none,
      body := text "Body",
      footer := none
    }
  result ≡ "<div class=\"card\"><div class=\"card-body\">Body</div></div>"

test "card merges user attributes" := do
  let result := HtmlM.render do
    card [class_ "card-lg", id_ "my-card"] { body := text "Body" }
  shouldSatisfy (strContains result "class=\"card card-lg\"") "has merged class"
  shouldSatisfy (strContains result "id=\"my-card\"") "has id"

test "card with complex body" := do
  let result := HtmlM.render do
    card [] {
      body := do
        h3 [] (text "Title")
        p [] (text "Description")
    }
  shouldSatisfy (strContains result "<h3>Title</h3>") "has h3"
  shouldSatisfy (strContains result "<p>Description</p>") "has p"

-- ============================================================================
-- Modal Component Tests
-- ============================================================================

test "modal renders with all slots" := do
  let result := HtmlM.render do
    modal [] .md {
      title := some (text "Title"),
      body := text "Body",
      actions := some (button [] (text "OK"))
    }
  shouldSatisfy (strContains result "modal-overlay") "has overlay"
  shouldSatisfy (strContains result "modal-container modal-md") "has container with size"
  shouldSatisfy (strContains result "modal-header") "has header"
  shouldSatisfy (strContains result "modal-title") "has title"
  shouldSatisfy (strContains result "modal-body") "has body"
  shouldSatisfy (strContains result "modal-actions") "has actions"

test "modal sizes apply correct class" := do
  let smResult := HtmlM.render do modal [] .sm { body := text "x" }
  let lgResult := HtmlM.render do modal [] .lg { body := text "x" }
  let xlResult := HtmlM.render do modal [] .xl { body := text "x" }
  shouldSatisfy (strContains smResult "modal-sm") "sm has modal-sm"
  shouldSatisfy (strContains lgResult "modal-lg") "lg has modal-lg"
  shouldSatisfy (strContains xlResult "modal-xl") "xl has modal-xl"

test "modal skips none slots" := do
  let result := HtmlM.render do
    modal [] .md { body := text "Body only" }
  shouldSatisfy (!strContains result "modal-header") "no header"
  shouldSatisfy (!strContains result "modal-actions") "no actions"
  shouldSatisfy (strContains result "modal-body") "has body"

test "modal merges user attributes" := do
  let result := HtmlM.render do
    modal [id_ "confirm-modal"] .md { body := text "x" }
  shouldSatisfy (strContains result "id=\"confirm-modal\"") "has id"

-- ============================================================================
-- Panel Component Tests
-- ============================================================================

test "panel renders as details/summary" := do
  let result := HtmlM.render do
    panel [] false {
      header := text "Header",
      body := text "Body"
    }
  shouldSatisfy (strContains result "<details") "has details"
  shouldSatisfy (strContains result "<summary") "has summary"
  shouldSatisfy (strContains result "panel-header") "has panel-header"
  shouldSatisfy (strContains result "panel-body") "has panel-body"

test "panel open attribute when open_=true" := do
  let result := HtmlM.render do
    panel [] true { header := text "H", body := text "B" }
  shouldSatisfy (strContains result "open=\"\"") "has open attr"

test "panel no open attribute when open_=false" := do
  let result := HtmlM.render do
    panel [] false { header := text "H", body := text "B" }
  shouldSatisfy (!strContains result "open=") "no open attr"

test "panel merges user attributes" := do
  let result := HtmlM.render do
    panel [class_ "faq-item"] false { header := text "H", body := text "B" }
  shouldSatisfy (strContains result "class=\"panel faq-item\"") "has merged class"

-- ============================================================================
-- Form Component Tests
-- ============================================================================

test "formGroup renders label and input" := do
  let result := HtmlM.render do
    formGroup [] {
      label := text "Email",
      input := input [type_ "email"]
    }
  shouldSatisfy (strContains result "form-group") "has form-group"
  shouldSatisfy (strContains result "form-label") "has form-label"
  shouldSatisfy (strContains result "type=\"email\"") "has input type"

test "formGroup shows help text" := do
  let result := HtmlM.render do
    formGroup [] {
      label := text "Email",
      input := input [type_ "email"],
      help := some (text "Enter your email address")
    }
  shouldSatisfy (strContains result "form-help") "has form-help"
  shouldSatisfy (strContains result "Enter your email address") "has help text"

test "formGroup shows error with has-error class" := do
  let result := HtmlM.render do
    formGroup [] {
      label := text "Email",
      input := input [type_ "email"],
      error := some (text "Invalid email")
    }
  shouldSatisfy (strContains result "has-error") "has has-error class"
  shouldSatisfy (strContains result "form-error") "has form-error"
  shouldSatisfy (strContains result "Invalid email") "has error message"

test "formGroup no error class when no error" := do
  let result := HtmlM.render do
    formGroup [] {
      label := text "Email",
      input := input [type_ "email"]
    }
  shouldSatisfy (!strContains result "has-error") "no has-error"
  shouldSatisfy (!strContains result "form-error") "no form-error"

test "formFieldset renders legend and body" := do
  let result := HtmlM.render do
    formFieldset [] {
      legend := text "Personal Info",
      body := input [name_ "name"]
    }
  shouldSatisfy (strContains result "<fieldset") "has fieldset"
  shouldSatisfy (strContains result "<legend") "has legend"
  shouldSatisfy (strContains result "form-legend") "has form-legend"
  shouldSatisfy (strContains result "Personal Info") "has legend text"

-- ============================================================================
-- Alert Component Tests
-- ============================================================================

test "simpleAlert renders with variant class" := do
  let infoResult := HtmlM.render do simpleAlert [] .info (text "Info")
  let successResult := HtmlM.render do simpleAlert [] .success (text "Success")
  let warningResult := HtmlM.render do simpleAlert [] .warning (text "Warning")
  let errorResult := HtmlM.render do simpleAlert [] .error (text "Error")
  shouldSatisfy (strContains infoResult "alert-info") "info has alert-info"
  shouldSatisfy (strContains successResult "alert-success") "success has alert-success"
  shouldSatisfy (strContains warningResult "alert-warning") "warning has alert-warning"
  shouldSatisfy (strContains errorResult "alert-error") "error has alert-error"

test "alert renders optional icon" := do
  let result := HtmlM.render do
    alert [] .info {
      icon := some (text "i"),
      message := text "Info message"
    }
  shouldSatisfy (strContains result "alert-icon") "has alert-icon"
  shouldSatisfy (strContains result ">i<") "has icon content"

test "alert renders optional dismiss" := do
  let result := HtmlM.render do
    alert [] .info {
      message := text "Info",
      dismiss := some (button [] (text "x"))
    }
  shouldSatisfy (strContains result "alert-dismiss") "has alert-dismiss"
  shouldSatisfy (strContains result "<button") "has button"

test "alert skips none slots" := do
  let result := HtmlM.render do
    simpleAlert [] .info (text "Just message")
  shouldSatisfy (!strContains result "alert-icon") "no alert-icon"
  shouldSatisfy (!strContains result "alert-dismiss") "no alert-dismiss"
  shouldSatisfy (strContains result "alert-message") "has alert-message"

-- ============================================================================
-- Navigation Component Tests
-- ============================================================================

test "navItem renders with label" := do
  let result := HtmlM.render do
    navItem [href_ "/home"] none { label := text "Home" }
  shouldSatisfy (strContains result "nav-item") "has nav-item"
  shouldSatisfy (strContains result "nav-label") "has nav-label"
  shouldSatisfy (strContains result "Home") "has label text"

test "navItem active state adds class" := do
  let activeResult := HtmlM.render do
    navItem [href_ "/home"] (some true) { label := text "Home" }
  let inactiveResult := HtmlM.render do
    navItem [href_ "/about"] (some false) { label := text "About" }
  shouldSatisfy (strContains activeResult "nav-item active") "active has active class"
  shouldSatisfy (!strContains inactiveResult "active") "inactive has no active"

test "navItem renders optional icon" := do
  let result := HtmlM.render do
    navItem [] none {
      icon := some (text "H"),
      label := text "Home"
    }
  shouldSatisfy (strContains result "nav-icon") "has nav-icon"

test "navItem renders optional badge" := do
  let result := HtmlM.render do
    navItem [] none {
      label := text "Messages",
      badge := some (span [class_ "count"] (text "5"))
    }
  shouldSatisfy (strContains result "nav-badge") "has nav-badge"
  shouldSatisfy (strContains result "count") "has badge class"

test "breadcrumbs renders list of items" := do
  let result := HtmlM.render do
    breadcrumbs [] [
      { href := some "/", label := text "Home" },
      { href := some "/products", label := text "Products" },
      { label := text "Widget" }
    ]
  shouldSatisfy (strContains result "breadcrumbs") "has breadcrumbs"
  shouldSatisfy (strContains result "breadcrumb-list") "has breadcrumb-list"
  shouldSatisfy (strContains result "breadcrumb-item") "has breadcrumb-item"
  shouldSatisfy (strContains result "href=\"/\"") "has home link"
  shouldSatisfy (strContains result "href=\"/products\"") "has products link"
  shouldSatisfy (strContains result "Widget") "has Widget"

test "breadcrumbs current item has no link" := do
  let result := HtmlM.render do
    breadcrumbs [] [
      { href := some "/", label := text "Home" },
      { label := text "Current" }
    ]
  -- Current item should be in a span, not an anchor
  shouldSatisfy (strContains result "<span>Current</span>") "current in span"



end ScribeTests.Components
