/-
  Scribe.Components.Card - Card component with header/body/footer slots

  Example:
  ```lean
  import Scribe

  open Scribe Scribe.Components

  def myCard : HtmlM Unit :=
    card [class_ "card-lg"] {
      header := some (h3 [] (text "Title")),
      body := p [] (text "Content"),
      footer := some (button [] (text "Action"))
    }
  ```
-/
import Scribe.Component
import Scribe.Elements

namespace Scribe.Components

open Scribe

/-- Card slot structure -/
structure CardSlots where
  /-- Card header content (optional) -/
  header : Option (HtmlM Unit) := none
  /-- Card body content (required) -/
  body : HtmlM Unit
  /-- Card footer content (optional) -/
  footer : Option (HtmlM Unit) := none

/-- Card component with header, body, and footer slots.

    Example:
    ```lean
    card [class_ "card-lg"] {
      header := some (h3 [] (text "Title")),
      body := p [] (text "Content"),
      footer := some do
        button [class_ "btn"] (text "Action")
    }
    ```
-/
def card (attrs : List Attr := []) (slots : CardSlots) : HtmlM Unit := do
  div (withClass "card" attrs) do
    whenSlot slots.header fun content =>
      div [class_ "card-header"] content
    div [class_ "card-body"] slots.body
    whenSlot slots.footer fun content =>
      div [class_ "card-footer"] content

/-- Simple card variant that takes body content directly.
    For cards without header/footer, this is more ergonomic. -/
def simpleCard (attrs : List Attr := []) (body : HtmlM Unit) : HtmlM Unit :=
  card attrs { body := body }

end Scribe.Components
