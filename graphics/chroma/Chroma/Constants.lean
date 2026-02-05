/-
  Chroma constants and shared UI sizing values.
-/
namespace Chroma

def tau : Float := 6.283185307179586

structure UISizes where
  baseWidth : Float := 900.0
  baseHeight : Float := 700.0
  titleFontSize : Float := 28.0
  bodyFontSize : Float := 16.0
  pickerSize : Float := 360.0
  ringThickness : Float := 36.0
  knobWidth : Float := 22.0
  knobHeight : Float := 10.0
  columnGap : Float := 24.0
  columnPadding : Float := 32.0
deriving Repr

def uiSizes : UISizes := {}

structure WidgetIds where
  columnRoot : Nat := 0
  titleText : Nat := 1
  picker : Nat := 2
  subtitleText : Nat := 3
deriving Repr

def widgetIds : WidgetIds := {}

def defaultFontPath : String := "/System/Library/Fonts/Monaco.ttf"

end Chroma
