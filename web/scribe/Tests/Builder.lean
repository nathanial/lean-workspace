/-
  Tests for Scribe HTML builder
-/
import Scribe
import Crucible

namespace Tests.Builder

open Crucible
open Scribe

testSuite "Scribe HTML Builder"

-- Html Rendering Tests

test "text escapes HTML characters" := do
  let html := Html.text "<script>alert('xss')</script>"
  html.render ≡ "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;"

test "raw does not escape" := do
  let html := Html.raw "<b>bold</b>"
  html.render ≡ "<b>bold</b>"

test "element renders opening and closing tags" := do
  let html := Html.element "div" [] []
  html.render ≡ "<div></div>"

test "element with text child" := do
  let html := Html.element "p" [] [.text "Hello"]
  html.render ≡ "<p>Hello</p>"

test "element with attributes" := do
  let html := Html.element "div" [⟨"class", "container"⟩, ⟨"id", "main"⟩] []
  html.render ≡ "<div class=\"container\" id=\"main\"></div>"

test "void elements have no closing tag" := do
  let html := Html.element "br" [] []
  html.render ≡ "<br>"

test "img is a void element" := do
  let html := Html.element "img" [⟨"src", "test.png"⟩] []
  html.render ≡ "<img src=\"test.png\">"

test "nested elements" := do
  let html := Html.element "div" [] [
    .element "span" [] [.text "Hello"],
    .element "span" [] [.text "World"]
  ]
  html.render ≡ "<div><span>Hello</span><span>World</span></div>"

test "attribute values are escaped" := do
  let html := Html.element "div" [⟨"data-value", "a\"b"⟩] []
  html.render ≡ "<div data-value=\"a&quot;b\"></div>"

test "fragment renders children without wrapper" := do
  let html := Html.fragment [.text "A", .text "B"]
  html.render ≡ "AB"

-- HtmlM Builder Tests

test "build creates fragment from children" := do
  let html := HtmlM.build do
    HtmlM.text "Hello"
    HtmlM.text " World"
  html.render ≡ "Hello World"

test "element builder creates proper structure" := do
  let html := HtmlM.build do
    div [] do
      text "Content"
  html.render ≡ "<div>Content</div>"

test "nested builder elements" := do
  let html := HtmlM.build do
    div [] do
      p [] do
        text "Paragraph"
  html.render ≡ "<div><p>Paragraph</p></div>"

test "multiple children in builder" := do
  let html := HtmlM.build do
    ul [] do
      li [] (text "One")
      li [] (text "Two")
      li [] (text "Three")
  html.render ≡ "<ul><li>One</li><li>Two</li><li>Three</li></ul>"

test "builder with attributes" := do
  let html := HtmlM.build do
    div [class_ "container", id_ "main"] do
      text "Hello"
  html.render ≡ "<div class=\"container\" id=\"main\">Hello</div>"

test "control flow in builder - if" := do
  let showExtra := true
  let html := HtmlM.build do
    div [] do
      text "Always"
      if showExtra then
        text " Extra"
  html.render ≡ "<div>Always Extra</div>"

test "control flow in builder - for" := do
  let items := ["A", "B", "C"]
  let html := HtmlM.build do
    ul [] do
      for item in items do
        li [] (text item)
  html.render ≡ "<ul><li>A</li><li>B</li><li>C</li></ul>"

test "HtmlM.render produces string directly" := do
  let result := HtmlM.render do
    p [] (text "Test")
  result ≡ "<p>Test</p>"

-- Attribute Helper Tests

test "class_ creates class attribute" := do
  let attr := class_ "container"
  (attr.name, attr.value) ≡ ("class", "container")

test "id_ creates id attribute" := do
  let attr := id_ "main"
  (attr.name, attr.value) ≡ ("id", "main")

test "href_ creates href attribute" := do
  let attr := href_ "https://example.com"
  (attr.name, attr.value) ≡ ("href", "https://example.com")

test "data_ creates data attribute" := do
  let attr := data_ "value" "42"
  (attr.name, attr.value) ≡ ("data-value", "42")

test "boolean attributes have empty value" := do
  let attr := required_
  (attr.name, attr.value) ≡ ("required", "")

-- HTML Element Tests

test "html element" := do
  let result := HtmlM.render do
    html [] do
      text "Content"
  result ≡ "<html>Content</html>"

test "complete document structure" := do
  let result := HtmlM.render do
    html [] do
      head [] do
        title "Test"
      body [] do
        text "Body"
  result ≡ "<html><head><title>Test</title></head><body>Body</body></html>"

test "doctype emits HTML5 declaration" := do
  let result := HtmlM.render do
    doctype
  result ≡ "<!DOCTYPE html>\n"

test "doctype with full document" := do
  let result := HtmlM.render do
    doctype
    html [] do
      head [] do
        title "Test"
      body [] do
        text "Hello"
  result ≡ "<!DOCTYPE html>\n<html><head><title>Test</title></head><body>Hello</body></html>"

test "link element with text" := do
  let result := HtmlM.render do
    a [href_ "/page"] do
      text "Click me"
  result ≡ "<a href=\"/page\">Click me</a>"

test "form elements" := do
  let result := HtmlM.render do
    form [action_ "/submit", method_ "POST"] do
      input [type_ "text", name_ "username"]
      button [type_ "submit"] (text "Submit")
  result ≡ "<form action=\"/submit\" method=\"POST\"><input type=\"text\" name=\"username\"><button type=\"submit\">Submit</button></form>"

test "table structure" := do
  let result := HtmlM.render do
    table [] do
      tr [] do
        th [] (text "Header")
      tr [] do
        td [] (text "Cell")
  result ≡ "<table><tr><th>Header</th></tr><tr><td>Cell</td></tr></table>"

test "image element" := do
  let result := HtmlM.render do
    img [src_ "photo.jpg", alt_ "A photo"]
  result ≡ "<img src=\"photo.jpg\" alt=\"A photo\">"

test "br element" := do
  let result := HtmlM.render do
    p [] do
      text "Line 1"
      br
      text "Line 2"
  result ≡ "<p>Line 1<br>Line 2</p>"

-- Conditional Attribute Tests

test "class_if includes class when condition is true" := do
  let attrs := class_if true "active"
  attrs.length ≡ 1

test "class_if returns empty when condition is false" := do
  let attrs := class_if false "active"
  attrs.length ≡ 0

test "class_if in element" := do
  let isActive := true
  let result := HtmlM.render do
    div (class_if isActive "active" ++ [id_ "main"]) (text "Content")
  result ≡ "<div class=\"active\" id=\"main\">Content</div>"

test "classes combines conditional class names" := do
  let attr := classes [(true, "card"), (false, "hidden"), (true, "large")]
  attr.value ≡ "card large"

test "classes with all false" := do
  let attr := classes [(false, "a"), (false, "b")]
  attr.value ≡ ""

test "classNames filters empty strings" := do
  let attr := classNames ["foo", "", "bar", ""]
  attr.value ≡ "foo bar"

test "attr_if includes attribute when true" := do
  let attrs := attr_if true disabled_
  attrs.length ≡ 1

test "attr_if excludes attribute when false" := do
  let attrs := attr_if false disabled_
  attrs.length ≡ 0

-- VolatileTarget Tests

test "volatileTarget creates target" := do
  let target := volatileTarget "content"
  target.id ≡ "content"

test "hx_target_vol creates correct attribute" := do
  let target := volatileTarget "main"
  let attr := hx_target_vol target
  (attr.name, attr.value) ≡ ("hx-target", "#main")

-- RouteAttrs Tests

inductive TestRoute where
  | home
  | about
  | users (id : Nat)

namespace TestRoute
def path : TestRoute → String
  | .home => "/"
  | .about => "/about"
  | .users id => s!"/users/{id}"
end TestRoute

instance : HasPath TestRoute where
  path := TestRoute.path

test "hx_get' with route type" := do
  let attr := hx_get' TestRoute.home
  (attr.name, attr.value) ≡ ("hx-get", "/")

test "hx_post' with route type" := do
  let attr := hx_post' TestRoute.about
  (attr.name, attr.value) ≡ ("hx-post", "/about")

test "href' with parameterized route" := do
  let attr := href' (TestRoute.users 42)
  (attr.name, attr.value) ≡ ("href", "/users/42")

test "action' with route type" := do
  let attr := action' TestRoute.home
  (attr.name, attr.value) ≡ ("action", "/")

test "src' with route type" := do
  let attr := src' TestRoute.about
  (attr.name, attr.value) ≡ ("src", "/about")

test "hx_put' with route type" := do
  let attr := hx_put' (TestRoute.users 1)
  (attr.name, attr.value) ≡ ("hx-put", "/users/1")

test "hx_patch' with route type" := do
  let attr := hx_patch' TestRoute.home
  (attr.name, attr.value) ≡ ("hx-patch", "/")

test "hx_delete' with route type" := do
  let attr := hx_delete' (TestRoute.users 99)
  (attr.name, attr.value) ≡ ("hx-delete", "/users/99")

-- New HTML5 Elements Tests

test "wbr is a void element" := do
  let result := HtmlM.render do
    p [] do
      text "longword"
      wbr
      text "continued"
  result ≡ "<p>longword<wbr>continued</p>"

test "canvas element" := do
  let result := HtmlM.render do
    canvas [id_ "game", width_ 800, height_ 600] (pure ())
  result ≡ "<canvas id=\"game\" width=\"800\" height=\"600\"></canvas>"

test "template element" := do
  let result := HtmlM.render do
    template_ [id_ "row-template"] do
      tr [] do
        td [] (text "Cell")
  result ≡ "<template id=\"row-template\"><tr><td>Cell</td></tr></template>"

test "address element" := do
  let result := HtmlM.render do
    address [] do
      text "123 Main St"
  result ≡ "<address>123 Main St</address>"

test "ruby annotation elements" := do
  let result := HtmlM.render do
    ruby [] do
      text "漢"
      rp [] (text "(")
      rt [] (text "kan")
      rp [] (text ")")
  result ≡ "<ruby>漢<rp>(</rp><rt>kan</rt><rp>)</rp></ruby>"

test "colgroup and col elements" := do
  let result := HtmlM.render do
    table [] do
      colgroup [] do
        col [style_ "width: 50%"]
        col [style_ "width: 50%"]
      tr [] do
        td [] (text "A")
        td [] (text "B")
  result ≡ "<table><colgroup><col style=\"width: 50%\"><col style=\"width: 50%\"></colgroup><tr><td>A</td><td>B</td></tr></table>"

-- New HTMX Attribute Tests

test "hx_on creates event handler attribute" := do
  let attr := hx_on "click" "alert('hi')"
  (attr.name, attr.value) ≡ ("hx-on:click", "alert('hi')")

test "hx_ws_connect creates websocket attribute" := do
  let attr := hx_ws_connect "/ws"
  (attr.name, attr.value) ≡ ("hx-ws", "connect:/ws")

test "hx_sse_connect creates SSE attribute" := do
  let attr := hx_sse_connect "/events"
  (attr.name, attr.value) ≡ ("hx-sse", "connect:/events")

-- New ARIA Attribute Tests

test "ariaExpanded_ creates correct attribute" := do
  let attr := ariaExpanded_ true
  (attr.name, attr.value) ≡ ("aria-expanded", "true")

test "ariaControls_ creates correct attribute" := do
  let attr := ariaControls_ "menu-content"
  (attr.name, attr.value) ≡ ("aria-controls", "menu-content")

test "ariaLive_ creates correct attribute" := do
  let attr := ariaLive_ "polite"
  (attr.name, attr.value) ≡ ("aria-live", "polite")

-- Attribute Merging Tests

test "mergeAttrs combines class attributes" := do
  let result := mergeAttrs [class_ "card"] [class_ "large"]
  result.length ≡ 1
  (result.head!.name, result.head!.value) ≡ ("class", "card large")

test "mergeAttrs overrides non-mergeable attributes" := do
  let result := mergeAttrs [id_ "old"] [id_ "new"]
  result.length ≡ 1
  (result.head!.name, result.head!.value) ≡ ("id", "new")

test "mergeAttrs preserves order from first list" := do
  let result := mergeAttrs [class_ "a", id_ "x"] [class_ "b", id_ "y"]
  result.length ≡ 2
  result.map (·.name) ≡ ["class", "id"]

test "mergeAttrs adds new attributes from second list" := do
  let result := mergeAttrs [class_ "card"] [id_ "main", data_ "x" "1"]
  result.length ≡ 3
  result.map (·.name) ≡ ["class", "id", "data-x"]

test "mergeAttrs handles empty first list" := do
  let result := mergeAttrs [] [class_ "foo", id_ "bar"]
  result.length ≡ 2

test "mergeAttrs handles empty second list" := do
  let result := mergeAttrs [class_ "foo", id_ "bar"] []
  result.length ≡ 2

test "mergeAttrs merges style attributes" := do
  let result := mergeAttrs [style_ "color: red"] [style_ "font-size: 12px"]
  result.length ≡ 1
  (result.head!.name, result.head!.value) ≡ ("style", "color: red font-size: 12px")

test "mergeAttrs skips empty class values" := do
  let result := mergeAttrs [class_ "card"] [class_ ""]
  (result.head!.name, result.head!.value) ≡ ("class", "card")

test "+++ operator works like mergeAttrs" := do
  let result := [class_ "a", id_ "x"] +++ [class_ "b", id_ "y"]
  result.length ≡ 2
  (result.head!.name, result.head!.value) ≡ ("class", "a b")

test "mergeAttrs in element context" := do
  let baseAttrs := [class_ "btn", type_ "button"]
  let variantAttrs := [class_ "btn-primary", disabled_]
  let result := HtmlM.render do
    button (baseAttrs +++ variantAttrs) (text "Click")
  result ≡ "<button class=\"btn btn-primary\" type=\"button\" disabled=\"\">Click</button>"

-- SVG Element Tests

test "svg element with viewBox" := do
  let result := HtmlM.render do
    Svg.svg [Svg.viewBox_ "0 0 24 24", Svg.width_ 24, Svg.height_ 24] do
      pure ()
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" width=\"24\" height=\"24\"></svg>"

test "svg path element" := do
  let result := HtmlM.render do
    Svg.svg [Svg.viewBox_ "0 0 24 24"] do
      Svg.path [Svg.d_ "M12 2L2 7l10 5", Svg.fill_ "currentColor"]
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M12 2L2 7l10 5\" fill=\"currentColor\"></path></svg>"

test "svg circle element" := do
  let result := HtmlM.render do
    Svg.svg [] do
      Svg.circle [Svg.cx_ 50, Svg.cy_ 50, Svg.r_ 40, Svg.fill_ "red"]
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\"><circle cx=\"50.000000\" cy=\"50.000000\" r=\"40.000000\" fill=\"red\"></circle></svg>"

test "svg rect element" := do
  let result := HtmlM.render do
    Svg.svg [] do
      Svg.rect [Svg.x_ 10, Svg.y_ 10, Svg.width_ 100, Svg.height_ 50, Svg.fill_ "blue"]
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"10.000000\" y=\"10.000000\" width=\"100\" height=\"50\" fill=\"blue\"></rect></svg>"

test "svg group element" := do
  let result := HtmlM.render do
    Svg.svg [] do
      Svg.g [Svg.transform_ "translate(10,10)"] do
        Svg.circle [Svg.r_ 5]
        Svg.circle [Svg.cx_ 20, Svg.r_ 5]
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\"><g transform=\"translate(10,10)\"><circle r=\"5.000000\"></circle><circle cx=\"20.000000\" r=\"5.000000\"></circle></g></svg>"

test "svg line element" := do
  let result := HtmlM.render do
    Svg.svg [] do
      Svg.line [Svg.x1_ 0, Svg.y1_ 0, Svg.x2_ 100, Svg.y2_ 100, Svg.stroke_ "black"]
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\"><line x1=\"0.000000\" y1=\"0.000000\" x2=\"100.000000\" y2=\"100.000000\" stroke=\"black\"></line></svg>"

test "svg text element" := do
  let result := HtmlM.render do
    Svg.svg [] do
      Svg.text [Svg.x_ 50, Svg.y_ 50, Svg.textAnchor_ "middle"] do
        HtmlM.text "Hello"
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\"><text x=\"50.000000\" y=\"50.000000\" text-anchor=\"middle\">Hello</text></svg>"

test "svg with gradient" := do
  let result := HtmlM.render do
    Svg.svg [] do
      Svg.defs do
        Svg.linearGradient [id_ "grad1"] do
          Svg.stop [Svg.offset_ "0%", Svg.stopColor_ "red"]
          Svg.stop [Svg.offset_ "100%", Svg.stopColor_ "blue"]
      Svg.rect [Svg.fill_ "url(#grad1)", Svg.width_ 100, Svg.height_ 100]
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\"><defs><linearGradient id=\"grad1\"><stop offset=\"0%\" stop-color=\"red\"></stop><stop offset=\"100%\" stop-color=\"blue\"></stop></linearGradient></defs><rect fill=\"url(#grad1)\" width=\"100\" height=\"100\"></rect></svg>"

test "svg polyline and polygon" := do
  let result := HtmlM.render do
    Svg.svg [] do
      Svg.polyline [Svg.points_ "0,0 50,25 100,0", Svg.fill_ "none", Svg.stroke_ "black"]
      Svg.polygon [Svg.points_ "50,0 100,50 50,100 0,50", Svg.fill_ "lime"]
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\"><polyline points=\"0,0 50,25 100,0\" fill=\"none\" stroke=\"black\"></polyline><polygon points=\"50,0 100,50 50,100 0,50\" fill=\"lime\"></polygon></svg>"

test "svg stroke attributes" := do
  let result := HtmlM.render do
    Svg.svg [] do
      Svg.path [Svg.d_ "M0 0 L100 100",
                Svg.stroke_ "black",
                Svg.strokeWidth_ 2,
                Svg.strokeLinecap_ "round",
                Svg.strokeDasharray_ "5,5"]
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M0 0 L100 100\" stroke=\"black\" stroke-width=\"2.000000\" stroke-linecap=\"round\" stroke-dasharray=\"5,5\"></path></svg>"

test "svg use element with symbol" := do
  let result := HtmlM.render do
    Svg.svg [] do
      Svg.defs do
        Svg.symbol [id_ "icon"] do
          Svg.circle [Svg.r_ 10]
      Svg.use [Svg.href_ "#icon", Svg.x_ 50, Svg.y_ 50]
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\"><defs><symbol id=\"icon\"><circle r=\"10.000000\"></circle></symbol></defs><use href=\"#icon\" x=\"50.000000\" y=\"50.000000\"></use></svg>"

test "svg title for accessibility" := do
  let result := HtmlM.render do
    Svg.svg [role_ "img", ariaLabel_ "A red circle"] do
      Svg.title "Red Circle"
      Svg.circle [Svg.cx_ 50, Svg.cy_ 50, Svg.r_ 40, Svg.fill_ "red"]
  result ≡ "<svg xmlns=\"http://www.w3.org/2000/svg\" role=\"img\" aria-label=\"A red circle\"><title>Red Circle</title><circle cx=\"50.000000\" cy=\"50.000000\" r=\"40.000000\" fill=\"red\"></circle></svg>"

-- Type-Safe Attribute Value Tests

test "inputType creates correct type attribute" := do
  let attr := inputType .email
  (attr.name, attr.value) ≡ ("type", "email")

test "inputType password" := do
  let attr := inputType .password
  (attr.name, attr.value) ≡ ("type", "password")

test "inputType checkbox" := do
  let attr := inputType .checkbox
  (attr.name, attr.value) ≡ ("type", "checkbox")

test "inputType datetimeLocal uses hyphenated value" := do
  let attr := inputType .datetimeLocal
  (attr.name, attr.value) ≡ ("type", "datetime-local")

test "buttonType submit" := do
  let attr := buttonType .submit
  (attr.name, attr.value) ≡ ("type", "submit")

test "buttonType button" := do
  let attr := buttonType .button
  (attr.name, attr.value) ≡ ("type", "button")

test "formMethod post" := do
  let attr := formMethod .post
  (attr.name, attr.value) ≡ ("method", "POST")

test "formMethod get" := do
  let attr := formMethod .get
  (attr.name, attr.value) ≡ ("method", "GET")

test "formEnctype multipart" := do
  let attr := formEnctype .multipart
  (attr.name, attr.value) ≡ ("enctype", "multipart/form-data")

test "target blank" := do
  let attr := target .blank
  (attr.name, attr.value) ≡ ("target", "_blank")

test "target self" := do
  let attr := target .self
  (attr.name, attr.value) ≡ ("target", "_self")

test "autocomplete email" := do
  let attr := autocomplete .email
  (attr.name, attr.value) ≡ ("autocomplete", "email")

test "autocomplete newPassword" := do
  let attr := autocomplete .newPassword
  (attr.name, attr.value) ≡ ("autocomplete", "new-password")

test "loading lazy" := do
  let attr := loading .lazy
  (attr.name, attr.value) ≡ ("loading", "lazy")

test "crossorigin anonymous" := do
  let attr := crossorigin .anonymous
  (attr.name, attr.value) ≡ ("crossorigin", "anonymous")

test "referrerPolicy strictOrigin" := do
  let attr := referrerPolicy .strictOrigin
  (attr.name, attr.value) ≡ ("referrerpolicy", "strict-origin")

test "rel stylesheet" := do
  let attr := rel .stylesheet
  (attr.name, attr.value) ≡ ("rel", "stylesheet")

test "rels combines multiple values" := do
  let attr := rels [.noopener, .noreferrer]
  (attr.name, attr.value) ≡ ("rel", "noopener noreferrer")

test "dir rtl" := do
  let attr := dir .rtl
  (attr.name, attr.value) ≡ ("dir", "rtl")

test "inputmode numeric" := do
  let attr := inputmode .numeric
  (attr.name, attr.value) ≡ ("inputmode", "numeric")

test "scope col" := do
  let attr := scope .col
  (attr.name, attr.value) ≡ ("scope", "col")

test "preload metadata" := do
  let attr := preload .metadata
  (attr.name, attr.value) ≡ ("preload", "metadata")

test "sandbox empty" := do
  let attr := sandbox
  (attr.name, attr.value) ≡ ("sandbox", "")

test "sandboxAllow with permissions" := do
  let attr := sandboxAllow [.allowScripts, .allowSameOrigin]
  (attr.name, attr.value) ≡ ("sandbox", "allow-scripts allow-same-origin")

test "hxSwap innerHTML" := do
  let attr := hxSwap .innerHTML
  (attr.name, attr.value) ≡ ("hx-swap", "innerHTML")

test "hxSwap outerHTML" := do
  let attr := hxSwap .outerHTML
  (attr.name, attr.value) ≡ ("hx-swap", "outerHTML")

test "hxSwapWith modifiers" := do
  let attr := hxSwapWith .innerHTML "swap:1s"
  (attr.name, attr.value) ≡ ("hx-swap", "innerHTML swap:1s")

test "hxTrigger click" := do
  let attr := hxTrigger .click
  (attr.name, attr.value) ≡ ("hx-trigger", "click")

test "hxTrigger every interval" := do
  let attr := hxTrigger (.every "5s")
  (attr.name, attr.value) ≡ ("hx-trigger", "every 5s")

test "hxTriggerWith modifiers" := do
  let attr := hxTriggerWith .click "once delay:500ms"
  (attr.name, attr.value) ≡ ("hx-trigger", "click once delay:500ms")

test "type-safe form in element context" := do
  let result := HtmlM.render do
    form [formMethod .post, formEnctype .multipart] do
      input [inputType .email, name_ "email", autocomplete .email, required_]
      input [inputType .password, name_ "password", autocomplete .currentPassword]
      button [buttonType .submit] (text "Login")
  result ≡ "<form method=\"POST\" enctype=\"multipart/form-data\"><input type=\"email\" name=\"email\" autocomplete=\"email\" required=\"\"><input type=\"password\" name=\"password\" autocomplete=\"current-password\"><button type=\"submit\">Login</button></form>"

test "type-safe link element" := do
  let result := HtmlM.render do
    a [href_ "https://example.com", target .blank, rels [.noopener, .noreferrer]] do
      text "External Link"
  result ≡ "<a href=\"https://example.com\" target=\"_blank\" rel=\"noopener noreferrer\">External Link</a>"



end Tests.Builder
