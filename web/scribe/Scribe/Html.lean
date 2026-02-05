/-
  Scribe.Html - HTML representation and rendering
-/

namespace Scribe

/-- HTML attribute -/
structure Attr where
  name : String
  value : String
  deriving Repr, BEq, Inhabited

/-- HTML node -/
inductive Html where
  | text : String → Html
  | raw : String → Html
  | element : String → List Attr → List Html → Html
  | fragment : List Html → Html
  deriving Repr

namespace Html

/-- Escape HTML special characters in text -/
def escapeText (s : String) : String :=
  s.foldl (init := "") fun acc c =>
    acc ++ match c with
      | '<' => "&lt;"
      | '>' => "&gt;"
      | '&' => "&amp;"
      | '"' => "&quot;"
      | '\'' => "&#39;"
      | c => c.toString

/-- Escape attribute value -/
def escapeAttr (s : String) : String :=
  s.foldl (init := "") fun acc c =>
    acc ++ match c with
      | '<' => "&lt;"
      | '>' => "&gt;"
      | '&' => "&amp;"
      | '"' => "&quot;"
      | c => c.toString

/-- Void elements that don't have closing tags -/
def voidElements : List String :=
  ["area", "base", "br", "col", "embed", "hr", "img", "input",
   "link", "meta", "param", "source", "track", "wbr"]

/-- Check if an element is a void element -/
def isVoidElement (tag : String) : Bool :=
  voidElements.contains tag

/-- Render attributes to string -/
def renderAttrs (attrs : List Attr) : String :=
  if attrs.isEmpty then ""
  else " " ++ String.intercalate " " (attrs.map fun a =>
    s!"{a.name}=\"{escapeAttr a.value}\"")

/-- Render HTML to string -/
partial def render : Html → String
  | .text s => escapeText s
  | .raw s => s
  | .element tag attrs children =>
    if isVoidElement tag then
      s!"<{tag}{renderAttrs attrs}>"
    else
      let inner := String.join (children.map render)
      s!"<{tag}{renderAttrs attrs}>{inner}</{tag}>"
  | .fragment children =>
    String.join (children.map render)

/-- Render HTML with indentation for readability -/
partial def renderPretty (indent : Nat := 0) : Html → String
  | .text s => escapeText s
  | .raw s => s
  | .element tag attrs children =>
    let pad := String.ofList (List.replicate indent ' ')
    if isVoidElement tag then
      s!"{pad}<{tag}{renderAttrs attrs}>\n"
    else if children.isEmpty then
      s!"{pad}<{tag}{renderAttrs attrs}></{tag}>\n"
    else
      match children with
      | [.text s] => s!"{pad}<{tag}{renderAttrs attrs}>{escapeText s}</{tag}>\n"
      | [.raw s] => s!"{pad}<{tag}{renderAttrs attrs}>{s}</{tag}>\n"
      | [child] => s!"{pad}<{tag}{renderAttrs attrs}>\n{renderPretty (indent + 2) child}{pad}</{tag}>\n"
      | _ =>
        let inner := String.join (children.map (renderPretty (indent + 2)))
        s!"{pad}<{tag}{renderAttrs attrs}>\n{inner}{pad}</{tag}>\n"
  | .fragment children =>
    String.join (children.map (renderPretty indent))

instance : ToString Html where
  toString := render

end Html

end Scribe
