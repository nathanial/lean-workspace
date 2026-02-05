/-
  Scribe.Components.Modal - Modal dialog component

  Example:
  ```lean
  import Scribe

  open Scribe Scribe.Components

  def confirmModal : HtmlM Unit :=
    modal [id_ "confirm-modal"] .md {
      title := some (text "Confirm Action"),
      body := p [] (text "Are you sure you want to proceed?"),
      actions := some do
        button [class_ "btn btn-secondary"] (text "Cancel")
        button [class_ "btn btn-primary"] (text "Confirm")
    }
  ```
-/
import Scribe.Component
import Scribe.Elements

namespace Scribe.Components

open Scribe

/-- Modal slot structure -/
structure ModalSlots where
  /-- Modal title (optional, shown in header) -/
  title : Option (HtmlM Unit) := none
  /-- Modal body content (required) -/
  body : HtmlM Unit
  /-- Modal actions/footer (optional) -/
  actions : Option (HtmlM Unit) := none

/-- Modal size variants -/
inductive ModalSize where
  | sm
  | md
  | lg
  | xl
  deriving Repr, BEq

namespace ModalSize

def toClass : ModalSize → String
  | .sm => "modal-sm"
  | .md => "modal-md"
  | .lg => "modal-lg"
  | .xl => "modal-xl"

end ModalSize

/-- Modal component with overlay and container.

    Example:
    ```lean
    modal [id_ "my-modal"] .md {
      title := some (text "Confirm Action"),
      body := p [] (text "Are you sure?"),
      actions := some do
        button [class_ "btn btn-secondary"] (text "Cancel")
        button [class_ "btn btn-primary"] (text "Confirm")
    }
    ```
-/
def modal (attrs : List Attr := []) (size : ModalSize := .md) (slots : ModalSlots) : HtmlM Unit := do
  div (withClass "modal-overlay" attrs) do
    div [class_ s!"modal-container {size.toClass}"] do
      whenSlot slots.title fun content =>
        div [class_ "modal-header"] do
          h3 [class_ "modal-title"] content
      div [class_ "modal-body"] slots.body
      whenSlot slots.actions fun content =>
        div [class_ "modal-actions"] content

end Scribe.Components
