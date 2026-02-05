/-
  Scribe.Components.Form - Form-related components

  Provides form group and fieldset components for building accessible forms.

  Example:
  ```lean
  import Scribe

  open Scribe Scribe.Components

  def loginForm : HtmlM Unit := do
    form [action_ "/login", method_ "post"] do
      formGroup [] {
        label := text "Email",
        input := input [inputType .email, name_ "email", required_],
        help := some (text "We'll never share your email")
      }
      formGroup [] {
        label := text "Password",
        input := input [inputType .password, name_ "password", required_]
      }
      button [buttonType .submit] (text "Log In")
  ```
-/
import Scribe.Component
import Scribe.Elements

namespace Scribe.Components

open Scribe

/-- Form group slot structure -/
structure FormGroupSlots where
  /-- Label content -/
  label : HtmlM Unit
  /-- Input element -/
  input : HtmlM Unit
  /-- Help text (optional) -/
  help : Option (HtmlM Unit) := none
  /-- Error message (optional) -/
  error : Option (HtmlM Unit) := none

/-- Form group component for label + input + help/error.

    Example:
    ```lean
    formGroup [class_ "required"] {
      label := text "Email",
      input := input [type_ "email", name_ "email", required_],
      help := some (text "We'll never share your email"),
      error := if hasError then some (text "Invalid email") else none
    }
    ```
-/
def formGroup (attrs : List Attr := []) (slots : FormGroupSlots) : HtmlM Unit := do
  let hasError := hasSlotContent slots.error
  let errorClass := if hasError then " has-error" else ""
  div (withClass s!"form-group{errorClass}" attrs) do
    label [class_ "form-label"] slots.label
    slots.input
    whenSlot slots.help fun content =>
      span [class_ "form-help"] content
    whenSlot slots.error fun content =>
      span [class_ "form-error"] content

/-- Fieldset slot structure -/
structure FieldsetSlots where
  /-- Legend content -/
  legend : HtmlM Unit
  /-- Fieldset body containing form fields -/
  body : HtmlM Unit

/-- Form fieldset with legend.

    Example:
    ```lean
    formFieldset [] {
      legend := text "Personal Information",
      body := do
        formGroup [] { label := text "Name", input := input [name_ "name"] }
        formGroup [] { label := text "Email", input := input [name_ "email"] }
    }
    ```
-/
def formFieldset (attrs : List Attr := []) (slots : FieldsetSlots) : HtmlM Unit := do
  fieldset (withClass "form-fieldset" attrs) do
    legend [class_ "form-legend"] slots.legend
    slots.body

end Scribe.Components
