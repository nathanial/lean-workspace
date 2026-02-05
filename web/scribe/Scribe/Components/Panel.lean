/-
  Scribe.Components.Panel - Collapsible panel component

  Uses HTML5 details/summary elements for native collapsible behavior.

  Example:
  ```lean
  import Scribe

  open Scribe Scribe.Components

  def faqPanel : HtmlM Unit :=
    panel [] true {
      header := text "What is Scribe?",
      body := p [] (text "Scribe is a type-safe HTML builder for Lean 4.")
    }
  ```
-/
import Scribe.Component
import Scribe.Elements

namespace Scribe.Components

open Scribe

/-- Panel slot structure -/
structure PanelSlots where
  /-- Panel header content (required, shown in summary) -/
  header : HtmlM Unit
  /-- Panel body content (required, shown when expanded) -/
  body : HtmlM Unit

/-- Collapsible panel using HTML details/summary elements.

    Example:
    ```lean
    panel [class_ "faq-item"] true {
      header := text "Question here",
      body := p [] (text "Answer here")
    }
    ```
-/
def panel (attrs : List Attr := []) (open_ : Bool := false) (slots : PanelSlots) : HtmlM Unit := do
  let openAttr := if open_ then [attr_ "open" ""] else []
  details (withClass "panel" attrs ++ openAttr) do
    summary [class_ "panel-header"] slots.header
    div [class_ "panel-body"] slots.body

end Scribe.Components
