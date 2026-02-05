/-
  Scribe.Components.Alert - Alert/notification components

  Provides alert components for displaying messages, notifications, and feedback.

  Example:
  ```lean
  import Scribe

  open Scribe Scribe.Components

  def notifications : HtmlM Unit := do
    simpleAlert [] .success (text "Operation completed successfully!")

    alert [] .warning {
      icon := some (text "⚠️"),
      message := text "Your session will expire in 5 minutes.",
      dismiss := some (button [class_ "close"] (text "×"))
    }
  ```
-/
import Scribe.Component
import Scribe.Elements

namespace Scribe.Components

open Scribe

/-- Alert variants -/
inductive AlertVariant where
  | info
  | success
  | warning
  | error
  deriving Repr, BEq

namespace AlertVariant

def toClass : AlertVariant → String
  | .info => "alert-info"
  | .success => "alert-success"
  | .warning => "alert-warning"
  | .error => "alert-error"

end AlertVariant

/-- Alert slot structure -/
structure AlertSlots where
  /-- Icon content (optional) -/
  icon : Option (HtmlM Unit) := none
  /-- Alert message (required) -/
  message : HtmlM Unit
  /-- Dismiss action (optional) -/
  dismiss : Option (HtmlM Unit) := none

/-- Alert component for notifications and messages.

    Example:
    ```lean
    alert [] .success {
      icon := some (text "✓"),
      message := text "Operation completed successfully!",
      dismiss := some (button [class_ "close"] (text "×"))
    }
    ```
-/
def alert (attrs : List Attr := []) (variant : AlertVariant := .info) (slots : AlertSlots) : HtmlM Unit := do
  div (withClass s!"alert {variant.toClass}" attrs) do
    whenSlot slots.icon fun content =>
      span [class_ "alert-icon"] content
    div [class_ "alert-message"] slots.message
    whenSlot slots.dismiss fun content =>
      div [class_ "alert-dismiss"] content

/-- Simple alert without slots - just a message and variant. -/
def simpleAlert (attrs : List Attr := []) (variant : AlertVariant := .info) (message : HtmlM Unit) : HtmlM Unit :=
  alert attrs variant { message := message }

end Scribe.Components
