/-
  Scribe.Builder - Monadic HTML builder
-/
import Scribe.Html

namespace Scribe

/-- Builder state accumulating HTML children -/
structure BuilderState where
  children : Array Html
  deriving Inhabited

/-- HTML builder monad -/
def HtmlM := StateM BuilderState

namespace HtmlM

instance : Monad HtmlM where
  pure a := (pure a : StateM BuilderState _)
  bind ma f := (ma >>= f : StateM BuilderState _)

instance : MonadState BuilderState HtmlM where
  get := (get : StateM BuilderState _)
  set s := (set s : StateM BuilderState _)
  modifyGet f := (modifyGet f : StateM BuilderState _)

/-- Emit an HTML node to the builder -/
def emit (h : Html) : HtmlM Unit :=
  modify fun s => { s with children := s.children.push h }

/-- Emit a text node (escaped) -/
def text (s : String) : HtmlM Unit :=
  emit (.text s)

/-- Emit raw HTML (unescaped) -/
def raw (s : String) : HtmlM Unit :=
  emit (.raw s)

/-- Run a builder and collect its children -/
def collect (m : HtmlM Unit) : Array Html :=
  let (_, state) := (m : StateM BuilderState Unit).run { children := #[] }
  state.children

/-- Run a builder and return a fragment -/
def build (m : HtmlM Unit) : Html :=
  let children := collect m
  match children.toList with
  | [single] => single
  | list => .fragment list

/-- Render content to string -/
def render (m : HtmlM Unit) : String :=
  (build m).render

/-- Render content with pretty printing -/
def renderPretty (m : HtmlM Unit) : String :=
  (build m).renderPretty

end HtmlM

/-- Build an HTML element with children from a builder -/
def element (tag : String) (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit := do
  let inner := HtmlM.collect children
  HtmlM.emit (.element tag attrs inner.toList)

/-- Build an HTML element with no children -/
def emptyElement (tag : String) (attrs : List Attr := []) : HtmlM Unit :=
  HtmlM.emit (.element tag attrs [])

/-- Convenience for building a complete document -/
def document (m : HtmlM Unit) : Html :=
  HtmlM.build m

end Scribe
