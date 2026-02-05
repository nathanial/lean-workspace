/-
  Scribe.Elements - HTML element builder functions
-/
import Scribe.Builder
import Scribe.Attr

namespace Scribe

-- Document structure

/-- Emits the HTML5 DOCTYPE declaration. Should be the first thing in an HTML document. -/
def doctype : HtmlM Unit := HtmlM.raw "<!DOCTYPE html>\n"

def html (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "html" attrs children

def head (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "head" attrs children

def body (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "body" attrs children

def title (content : String) : HtmlM Unit :=
  element "title" [] (HtmlM.text content)

def meta_ (attrs : List Attr) : HtmlM Unit :=
  emptyElement "meta" attrs

def link (attrs : List Attr) : HtmlM Unit :=
  emptyElement "link" attrs

def script (attrs : List Attr := []) (content : String := "") : HtmlM Unit :=
  if content.isEmpty then
    emptyElement "script" attrs
  else
    element "script" attrs (HtmlM.raw content)

def style (attrs : List Attr := []) (content : String) : HtmlM Unit :=
  element "style" attrs (HtmlM.raw content)

-- Semantic structure

def header (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "header" attrs children

def footer (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "footer" attrs children

def main (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "main" attrs children

def nav (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "nav" attrs children

def aside (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "aside" attrs children

def section_ (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "section" attrs children

def article (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "article" attrs children

def address (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "address" attrs children

def hgroup (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "hgroup" attrs children

def search (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "search" attrs children

-- Block elements

def div (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "div" attrs children

def p (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "p" attrs children

def h1 (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "h1" attrs children

def h2 (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "h2" attrs children

def h3 (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "h3" attrs children

def h4 (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "h4" attrs children

def h5 (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "h5" attrs children

def h6 (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "h6" attrs children

def blockquote (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "blockquote" attrs children

def pre (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "pre" attrs children

def hr (attrs : List Attr := []) : HtmlM Unit :=
  emptyElement "hr" attrs

-- Lists

def ul (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "ul" attrs children

def ol (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "ol" attrs children

def li (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "li" attrs children

def dl (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "dl" attrs children

def dt (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "dt" attrs children

def dd (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "dd" attrs children

-- Tables

def table (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "table" attrs children

def thead (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "thead" attrs children

def tbody (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "tbody" attrs children

def tfoot (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "tfoot" attrs children

def tr (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "tr" attrs children

def th (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "th" attrs children

def td (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "td" attrs children

def caption (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "caption" attrs children

def colgroup (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "colgroup" attrs children

def col (attrs : List Attr := []) : HtmlM Unit :=
  emptyElement "col" attrs

-- Inline elements

def span (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "span" attrs children

def a (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "a" attrs children

def strong (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "strong" attrs children

def em (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "em" attrs children

def b (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "b" attrs children

def i (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "i" attrs children

def u (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "u" attrs children

def s (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "s" attrs children

def code (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "code" attrs children

def kbd (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "kbd" attrs children

def samp (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "samp" attrs children

def var (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "var" attrs children

def small (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "small" attrs children

def sub (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "sub" attrs children

def sup (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "sup" attrs children

def mark (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "mark" attrs children

def abbr (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "abbr" attrs children

def time (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "time" attrs children

def cite (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "cite" attrs children

def dfn (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "dfn" attrs children

def q (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "q" attrs children

def dataEl (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "data" attrs children

def bdi (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "bdi" attrs children

def bdo (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "bdo" attrs children

def ins (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "ins" attrs children

def del (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "del" attrs children

-- Ruby annotations
def ruby (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "ruby" attrs children

def rt (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "rt" attrs children

def rp (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "rp" attrs children

-- Line breaks
def br : HtmlM Unit :=
  emptyElement "br" []

def wbr : HtmlM Unit :=
  emptyElement "wbr" []

-- Media

def img (attrs : List Attr) : HtmlM Unit :=
  emptyElement "img" attrs

def audio (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "audio" attrs children

def video (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "video" attrs children

def source (attrs : List Attr) : HtmlM Unit :=
  emptyElement "source" attrs

def picture (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "picture" attrs children

def figure (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "figure" attrs children

def figcaption (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "figcaption" attrs children

def iframe (attrs : List Attr := []) (children : HtmlM Unit := pure ()) : HtmlM Unit :=
  element "iframe" attrs children

def track (attrs : List Attr) : HtmlM Unit :=
  emptyElement "track" attrs

def embed (attrs : List Attr) : HtmlM Unit :=
  emptyElement "embed" attrs

def object (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "object" attrs children

def param (attrs : List Attr) : HtmlM Unit :=
  emptyElement "param" attrs

-- Image maps
def map_ (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "map" attrs children

def area (attrs : List Attr) : HtmlM Unit :=
  emptyElement "area" attrs

-- Canvas and scripting
def canvas (attrs : List Attr := []) (children : HtmlM Unit := pure ()) : HtmlM Unit :=
  element "canvas" attrs children

def noscript (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "noscript" attrs children

-- Web components
def template_ (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "template" attrs children

def slot (attrs : List Attr := []) (children : HtmlM Unit := pure ()) : HtmlM Unit :=
  element "slot" attrs children

-- Forms

def form (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "form" attrs children

def input (attrs : List Attr) : HtmlM Unit :=
  emptyElement "input" attrs

def textarea (attrs : List Attr := []) (content : String := "") : HtmlM Unit :=
  element "textarea" attrs (HtmlM.text content)

def button (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "button" attrs children

def select (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "select" attrs children

def option (attrs : List Attr := []) (content : String) : HtmlM Unit :=
  element "option" attrs (HtmlM.text content)

def optgroup (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "optgroup" attrs children

def label (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "label" attrs children

def fieldset (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "fieldset" attrs children

def legend (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "legend" attrs children

def datalist (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "datalist" attrs children

def output (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "output" attrs children

def progress (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "progress" attrs children

def meter (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "meter" attrs children

-- Interactive elements

def details (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "details" attrs children

def summary (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "summary" attrs children

def dialog (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "dialog" attrs children

-- Text shorthand

def text (s : String) : HtmlM Unit := HtmlM.text s
def raw (s : String) : HtmlM Unit := HtmlM.raw s

end Scribe
