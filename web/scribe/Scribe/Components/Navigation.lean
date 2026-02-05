/-
  Scribe.Components.Navigation - Navigation components

  Provides navigation item and breadcrumb components.

  Example:
  ```lean
  import Scribe

  open Scribe Scribe.Components

  def sidebar : HtmlM Unit := do
    nav [class_ "sidebar"] do
      navItem [href_ "/"] (some true) { label := text "Home" }
      navItem [href_ "/messages"] none {
        icon := some (text "📧"),
        label := text "Messages",
        badge := some (span [class_ "badge"] (text "5"))
      }
      navItem [href_ "/settings"] none { label := text "Settings" }
  ```
-/
import Scribe.Component
import Scribe.Elements

namespace Scribe.Components

open Scribe

/-- Nav item slot structure -/
structure NavItemSlots where
  /-- Icon content (optional) -/
  icon : Option (HtmlM Unit) := none
  /-- Label content (required) -/
  label : HtmlM Unit
  /-- Badge content (optional, e.g., notification count) -/
  badge : Option (HtmlM Unit) := none

/-- Navigation item component.

    Example:
    ```lean
    navItem [href_ "/messages"] (some isActive) {
      icon := some (text "📧"),
      label := text "Messages",
      badge := some (span [class_ "badge"] (text "5"))
    }
    ```
-/
def navItem (attrs : List Attr := []) (active : Option Bool := none) (slots : NavItemSlots) : HtmlM Unit := do
  let activeClass := match active with
    | some true => " active"
    | _ => ""
  a (withClass s!"nav-item{activeClass}" attrs) do
    whenSlot slots.icon fun content =>
      span [class_ "nav-icon"] content
    span [class_ "nav-label"] slots.label
    whenSlot slots.badge fun content =>
      span [class_ "nav-badge"] content

/-- Breadcrumb item structure -/
structure BreadcrumbItem where
  /-- Link href (optional, current page has no link) -/
  href : Option String := none
  /-- Item label content -/
  label : HtmlM Unit

/-- Breadcrumbs navigation.

    Example:
    ```lean
    breadcrumbs [] [
      { href := some "/", label := text "Home" },
      { href := some "/products", label := text "Products" },
      { label := text "Widget" }  -- Current page, no link
    ]
    ```
-/
def breadcrumbs (attrs : List Attr := []) (items : List BreadcrumbItem) : HtmlM Unit := do
  nav (withClass "breadcrumbs" attrs) do
    ul [class_ "breadcrumb-list"] do
      for item in items do
        li [class_ "breadcrumb-item"] do
          match item.href with
          | some href => a [href_ href] item.label
          | none => span [] item.label

end Scribe.Components
