/-
  Scribe.RouteAttrs - Type-safe route-based HTMX attributes

  Provides a `HasPath` typeclass for route types and type-safe HTMX
  attribute helpers that catch invalid routes at compile time.

  Usage:
  ```lean
  import Scribe

  inductive Route where
    | home | about | users (id : Nat)

  namespace Route
  def path : Route → String
    | .home => "/"
    | .about => "/about"
    | .users id => s!"/users/{id}"
  end Route

  instance : Scribe.HasPath Route where
    path := Route.path

  open Scribe in
  def example : HtmlM Unit := do
    button [hx_get' Route.home, hx_target "#content"] (text "Go Home")
    a [href' (Route.users 42)] (text "View User")
  ```
-/
import Scribe.Html

namespace Scribe

/-- Typeclass for types that can be converted to URL paths -/
class HasPath (α : Type) where
  path : α → String

/-- Type-safe hx-get for route types -/
def hx_get' [HasPath R] (route : R) : Attr :=
  { name := "hx-get", value := HasPath.path route }

/-- Type-safe hx-post for route types -/
def hx_post' [HasPath R] (route : R) : Attr :=
  { name := "hx-post", value := HasPath.path route }

/-- Type-safe hx-put for route types -/
def hx_put' [HasPath R] (route : R) : Attr :=
  { name := "hx-put", value := HasPath.path route }

/-- Type-safe hx-patch for route types -/
def hx_patch' [HasPath R] (route : R) : Attr :=
  { name := "hx-patch", value := HasPath.path route }

/-- Type-safe hx-delete for route types -/
def hx_delete' [HasPath R] (route : R) : Attr :=
  { name := "hx-delete", value := HasPath.path route }

/-- Type-safe href for route types -/
def href' [HasPath R] (route : R) : Attr :=
  { name := "href", value := HasPath.path route }

/-- Type-safe src for route types -/
def src' [HasPath R] (route : R) : Attr :=
  { name := "src", value := HasPath.path route }

/-- Type-safe action for route types -/
def action' [HasPath R] (route : R) : Attr :=
  { name := "action", value := HasPath.path route }

end Scribe
