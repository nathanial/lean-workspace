/-
  Scribe.Svg - SVG element builders and attributes

  Provides builders for SVG elements and SVG-specific attributes
  for creating inline SVG graphics.

  Usage:
  ```lean
  import Scribe

  def icon : HtmlM Unit := do
    svg [viewBox_ "0 0 24 24", Svg.width_ 24, Svg.height_ 24] do
      Svg.path [d_ "M12 2L2 7l10 5 10-5-10-5z", Svg.fill_ "currentColor"]
  ```
-/
import Scribe.Builder
import Scribe.Attr

namespace Scribe.Svg

-- ============================================================================
-- SVG Container Elements
-- ============================================================================

/-- SVG root element -/
def svg (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "svg" ([attr_ "xmlns" "http://www.w3.org/2000/svg"] ++ attrs) children

/-- Group element for applying transforms/styles to multiple elements -/
def g (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "g" attrs children

/-- Definitions container for reusable elements -/
def defs (children : HtmlM Unit) : HtmlM Unit :=
  element "defs" [] children

/-- Symbol element for reusable graphics -/
def symbol (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "symbol" attrs children

/-- Use element to reference symbols or other elements -/
def use (attrs : List Attr) : HtmlM Unit :=
  emptyElement "use" attrs

/-- Anchor element for SVG links -/
def a (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "a" attrs children

/-- Switch element for conditional rendering -/
def switch (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "switch" attrs children

-- ============================================================================
-- SVG Shape Elements
-- ============================================================================

/-- Path element - the most versatile SVG shape -/
def path (attrs : List Attr) : HtmlM Unit :=
  emptyElement "path" attrs

/-- Rectangle element -/
def rect (attrs : List Attr) : HtmlM Unit :=
  emptyElement "rect" attrs

/-- Circle element -/
def circle (attrs : List Attr) : HtmlM Unit :=
  emptyElement "circle" attrs

/-- Ellipse element -/
def ellipse (attrs : List Attr) : HtmlM Unit :=
  emptyElement "ellipse" attrs

/-- Line element -/
def line (attrs : List Attr) : HtmlM Unit :=
  emptyElement "line" attrs

/-- Polyline element (open shape) -/
def polyline (attrs : List Attr) : HtmlM Unit :=
  emptyElement "polyline" attrs

/-- Polygon element (closed shape) -/
def polygon (attrs : List Attr) : HtmlM Unit :=
  emptyElement "polygon" attrs

-- ============================================================================
-- SVG Text Elements
-- ============================================================================

/-- Text element -/
def text (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "text" attrs children

/-- Text span for styling portions of text -/
def tspan (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "tspan" attrs children

/-- Text on a path -/
def textPath (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "textPath" attrs children

-- ============================================================================
-- SVG Gradient and Pattern Elements
-- ============================================================================

/-- Linear gradient definition -/
def linearGradient (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "linearGradient" attrs children

/-- Radial gradient definition -/
def radialGradient (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "radialGradient" attrs children

/-- Gradient stop -/
def stop (attrs : List Attr) : HtmlM Unit :=
  emptyElement "stop" attrs

/-- Pattern definition -/
def pattern (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "pattern" attrs children

-- ============================================================================
-- SVG Filter Elements
-- ============================================================================

/-- Filter container -/
def filter (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "filter" attrs children

/-- Gaussian blur filter -/
def feGaussianBlur (attrs : List Attr) : HtmlM Unit :=
  emptyElement "feGaussianBlur" attrs

/-- Color matrix filter -/
def feColorMatrix (attrs : List Attr) : HtmlM Unit :=
  emptyElement "feColorMatrix" attrs

/-- Offset filter -/
def feOffset (attrs : List Attr) : HtmlM Unit :=
  emptyElement "feOffset" attrs

/-- Blend filter -/
def feBlend (attrs : List Attr) : HtmlM Unit :=
  emptyElement "feBlend" attrs

/-- Merge filter -/
def feMerge (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "feMerge" attrs children

/-- Merge node -/
def feMergeNode (attrs : List Attr) : HtmlM Unit :=
  emptyElement "feMergeNode" attrs

/-- Drop shadow filter -/
def feDropShadow (attrs : List Attr) : HtmlM Unit :=
  emptyElement "feDropShadow" attrs

-- ============================================================================
-- SVG Clipping and Masking
-- ============================================================================

/-- Clipping path -/
def clipPath (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "clipPath" attrs children

/-- Mask element -/
def mask (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "mask" attrs children

-- ============================================================================
-- SVG Image and Foreign Object
-- ============================================================================

/-- Image element -/
def image (attrs : List Attr) : HtmlM Unit :=
  emptyElement "image" attrs

/-- Foreign object for embedding HTML in SVG -/
def foreignObject (attrs : List Attr := []) (children : HtmlM Unit) : HtmlM Unit :=
  element "foreignObject" attrs children

-- ============================================================================
-- SVG Animation Elements
-- ============================================================================

/-- Animate element -/
def animate (attrs : List Attr) : HtmlM Unit :=
  emptyElement "animate" attrs

/-- Animate transform element -/
def animateTransform (attrs : List Attr) : HtmlM Unit :=
  emptyElement "animateTransform" attrs

/-- Animate motion element -/
def animateMotion (attrs : List Attr := []) (children : HtmlM Unit := pure ()) : HtmlM Unit :=
  element "animateMotion" attrs children

/-- Set element for discrete animation -/
def set (attrs : List Attr) : HtmlM Unit :=
  emptyElement "set" attrs

-- ============================================================================
-- SVG Descriptive Elements
-- ============================================================================

/-- Title element (accessibility) -/
def title (content : String) : HtmlM Unit :=
  element "title" [] (HtmlM.text content)

/-- Description element (accessibility) -/
def desc (content : String) : HtmlM Unit :=
  element "desc" [] (HtmlM.text content)

/-- Metadata element -/
def metadata (children : HtmlM Unit) : HtmlM Unit :=
  element "metadata" [] children

-- ============================================================================
-- SVG-Specific Attributes
-- ============================================================================

-- Viewport and viewBox
def viewBox_ (v : String) : Attr := ⟨"viewBox", v⟩
def preserveAspectRatio_ (v : String) : Attr := ⟨"preserveAspectRatio", v⟩

-- Dimensions (SVG uses these differently than HTML)
def width_ (v : Nat) : Attr := ⟨"width", toString v⟩
def height_ (v : Nat) : Attr := ⟨"height", toString v⟩
def widthPx_ (v : Nat) : Attr := ⟨"width", s!"{v}px"⟩
def heightPx_ (v : Nat) : Attr := ⟨"height", s!"{v}px"⟩
def widthPct_ (v : Nat) : Attr := ⟨"width", s!"{v}%"⟩
def heightPct_ (v : Nat) : Attr := ⟨"height", s!"{v}%"⟩

-- Path data
def d_ (v : String) : Attr := ⟨"d", v⟩

-- Positioning
def x_ (v : Float) : Attr := ⟨"x", toString v⟩
def y_ (v : Float) : Attr := ⟨"y", toString v⟩
def x1_ (v : Float) : Attr := ⟨"x1", toString v⟩
def y1_ (v : Float) : Attr := ⟨"y1", toString v⟩
def x2_ (v : Float) : Attr := ⟨"x2", toString v⟩
def y2_ (v : Float) : Attr := ⟨"y2", toString v⟩
def cx_ (v : Float) : Attr := ⟨"cx", toString v⟩
def cy_ (v : Float) : Attr := ⟨"cy", toString v⟩
def dx_ (v : Float) : Attr := ⟨"dx", toString v⟩
def dy_ (v : Float) : Attr := ⟨"dy", toString v⟩

-- Circle/ellipse radii
def r_ (v : Float) : Attr := ⟨"r", toString v⟩
def rx_ (v : Float) : Attr := ⟨"rx", toString v⟩
def ry_ (v : Float) : Attr := ⟨"ry", toString v⟩

-- Rectangle corner radii
def cornerRadius_ (v : Float) : Attr := ⟨"rx", toString v⟩

-- Polyline/polygon points
def points_ (v : String) : Attr := ⟨"points", v⟩

-- Fill and stroke
def fill_ (v : String) : Attr := ⟨"fill", v⟩
def fillOpacity_ (v : Float) : Attr := ⟨"fill-opacity", toString v⟩
def fillRule_ (v : String) : Attr := ⟨"fill-rule", v⟩
def stroke_ (v : String) : Attr := ⟨"stroke", v⟩
def strokeWidth_ (v : Float) : Attr := ⟨"stroke-width", toString v⟩
def strokeOpacity_ (v : Float) : Attr := ⟨"stroke-opacity", toString v⟩
def strokeLinecap_ (v : String) : Attr := ⟨"stroke-linecap", v⟩
def strokeLinejoin_ (v : String) : Attr := ⟨"stroke-linejoin", v⟩
def strokeDasharray_ (v : String) : Attr := ⟨"stroke-dasharray", v⟩
def strokeDashoffset_ (v : Float) : Attr := ⟨"stroke-dashoffset", toString v⟩
def strokeMiterlimit_ (v : Float) : Attr := ⟨"stroke-miterlimit", toString v⟩

-- Opacity
def opacity_ (v : Float) : Attr := ⟨"opacity", toString v⟩

-- Transform
def transform_ (v : String) : Attr := ⟨"transform", v⟩
def transformOrigin_ (v : String) : Attr := ⟨"transform-origin", v⟩

-- References
def href_ (v : String) : Attr := ⟨"href", v⟩
def xlinkHref_ (v : String) : Attr := ⟨"xlink:href", v⟩

-- Clipping and masking
def clipPath_ (v : String) : Attr := ⟨"clip-path", v⟩
def clipRule_ (v : String) : Attr := ⟨"clip-rule", v⟩
def mask_ (v : String) : Attr := ⟨"mask", v⟩

-- Filter
def filter_ (v : String) : Attr := ⟨"filter", v⟩

-- Gradient attributes
def gradientUnits_ (v : String) : Attr := ⟨"gradientUnits", v⟩
def gradientTransform_ (v : String) : Attr := ⟨"gradientTransform", v⟩
def spreadMethod_ (v : String) : Attr := ⟨"spreadMethod", v⟩
def offset_ (v : String) : Attr := ⟨"offset", v⟩
def stopColor_ (v : String) : Attr := ⟨"stop-color", v⟩
def stopOpacity_ (v : Float) : Attr := ⟨"stop-opacity", toString v⟩

-- Pattern attributes
def patternUnits_ (v : String) : Attr := ⟨"patternUnits", v⟩
def patternContentUnits_ (v : String) : Attr := ⟨"patternContentUnits", v⟩
def patternTransform_ (v : String) : Attr := ⟨"patternTransform", v⟩

-- Text attributes
def textAnchor_ (v : String) : Attr := ⟨"text-anchor", v⟩
def dominantBaseline_ (v : String) : Attr := ⟨"dominant-baseline", v⟩
def fontFamily_ (v : String) : Attr := ⟨"font-family", v⟩
def fontSize_ (v : Float) : Attr := ⟨"font-size", toString v⟩
def fontWeight_ (v : String) : Attr := ⟨"font-weight", v⟩
def fontStyle_ (v : String) : Attr := ⟨"font-style", v⟩
def letterSpacing_ (v : Float) : Attr := ⟨"letter-spacing", toString v⟩
def textDecoration_ (v : String) : Attr := ⟨"text-decoration", v⟩

-- Marker attributes
def markerStart_ (v : String) : Attr := ⟨"marker-start", v⟩
def markerMid_ (v : String) : Attr := ⟨"marker-mid", v⟩
def markerEnd_ (v : String) : Attr := ⟨"marker-end", v⟩

-- Animation attributes
def attributeName_ (v : String) : Attr := ⟨"attributeName", v⟩
def from_ (v : String) : Attr := ⟨"from", v⟩
def to_ (v : String) : Attr := ⟨"to", v⟩
def dur_ (v : String) : Attr := ⟨"dur", v⟩
def begin_ (v : String) : Attr := ⟨"begin", v⟩
def end_ (v : String) : Attr := ⟨"end", v⟩
def repeatCount_ (v : String) : Attr := ⟨"repeatCount", v⟩
def values_ (v : String) : Attr := ⟨"values", v⟩
def keyTimes_ (v : String) : Attr := ⟨"keyTimes", v⟩
def calcMode_ (v : String) : Attr := ⟨"calcMode", v⟩

-- Filter primitive attributes
def in_ (v : String) : Attr := ⟨"in", v⟩
def in2_ (v : String) : Attr := ⟨"in2", v⟩
def result_ (v : String) : Attr := ⟨"result", v⟩
def stdDeviation_ (v : Float) : Attr := ⟨"stdDeviation", toString v⟩
def mode_ (v : String) : Attr := ⟨"mode", v⟩

-- Visibility
def visibility_ (v : String) : Attr := ⟨"visibility", v⟩
def display_ (v : String) : Attr := ⟨"display", v⟩

-- Cursor
def cursor_ (v : String) : Attr := ⟨"cursor", v⟩

-- Vector effect
def vectorEffect_ (v : String) : Attr := ⟨"vector-effect", v⟩

-- Paint order
def paintOrder_ (v : String) : Attr := ⟨"paint-order", v⟩

end Scribe.Svg
