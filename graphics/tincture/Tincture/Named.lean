/-
  Tincture - Named Colors
  All 147 CSS named colors.
-/

import Tincture.Color

namespace Tincture

namespace Named

/-- Create color from RGB bytes. -/
private def c (r g b : UInt8) : Color := Color.fromRgb8 r g b

-- Reds
def indianRed : Color := c 205 92 92
def lightCoral : Color := c 240 128 128
def salmon : Color := c 250 128 114
def darkSalmon : Color := c 233 150 122
def lightSalmon : Color := c 255 160 122
def crimson : Color := c 220 20 60
def red : Color := c 255 0 0
def fireBrick : Color := c 178 34 34
def darkRed : Color := c 139 0 0

-- Pinks
def pink : Color := c 255 192 203
def lightPink : Color := c 255 182 193
def hotPink : Color := c 255 105 180
def deepPink : Color := c 255 20 147
def mediumVioletRed : Color := c 199 21 133
def paleVioletRed : Color := c 219 112 147

-- Oranges
def coral : Color := c 255 127 80
def tomato : Color := c 255 99 71
def orangeRed : Color := c 255 69 0
def darkOrange : Color := c 255 140 0
def orange : Color := c 255 165 0

-- Yellows
def gold : Color := c 255 215 0
def yellow : Color := c 255 255 0
def lightYellow : Color := c 255 255 224
def lemonChiffon : Color := c 255 250 205
def lightGoldenrodYellow : Color := c 250 250 210
def papayaWhip : Color := c 255 239 213
def moccasin : Color := c 255 228 181
def peachPuff : Color := c 255 218 185
def paleGoldenrod : Color := c 238 232 170
def khaki : Color := c 240 230 140
def darkKhaki : Color := c 189 183 107

-- Purples
def lavender : Color := c 230 230 250
def thistle : Color := c 216 191 216
def plum : Color := c 221 160 221
def violet : Color := c 238 130 238
def orchid : Color := c 218 112 214
def fuchsia : Color := c 255 0 255
def magenta : Color := c 255 0 255
def mediumOrchid : Color := c 186 85 211
def mediumPurple : Color := c 147 112 219
def rebeccaPurple : Color := c 102 51 153
def blueViolet : Color := c 138 43 226
def darkViolet : Color := c 148 0 211
def darkOrchid : Color := c 153 50 204
def darkMagenta : Color := c 139 0 139
def purple : Color := c 128 0 128
def indigo : Color := c 75 0 130
def slateBlue : Color := c 106 90 205
def darkSlateBlue : Color := c 72 61 139
def mediumSlateBlue : Color := c 123 104 238

-- Greens
def greenYellow : Color := c 173 255 47
def chartreuse : Color := c 127 255 0
def lawnGreen : Color := c 124 252 0
def lime : Color := c 0 255 0
def limeGreen : Color := c 50 205 50
def paleGreen : Color := c 152 251 152
def lightGreen : Color := c 144 238 144
def mediumSpringGreen : Color := c 0 250 154
def springGreen : Color := c 0 255 127
def mediumSeaGreen : Color := c 60 179 113
def seaGreen : Color := c 46 139 87
def forestGreen : Color := c 34 139 34
def green : Color := c 0 128 0
def darkGreen : Color := c 0 100 0
def yellowGreen : Color := c 154 205 50
def oliveDrab : Color := c 107 142 35
def olive : Color := c 128 128 0
def darkOliveGreen : Color := c 85 107 47
def mediumAquamarine : Color := c 102 205 170
def darkSeaGreen : Color := c 143 188 143
def lightSeaGreen : Color := c 32 178 170
def darkCyan : Color := c 0 139 139
def teal : Color := c 0 128 128

-- Blues
def aqua : Color := c 0 255 255
def cyan : Color := c 0 255 255
def lightCyan : Color := c 224 255 255
def paleTurquoise : Color := c 175 238 238
def aquamarine : Color := c 127 255 212
def turquoise : Color := c 64 224 208
def mediumTurquoise : Color := c 72 209 204
def darkTurquoise : Color := c 0 206 209
def cadetBlue : Color := c 95 158 160
def steelBlue : Color := c 70 130 180
def lightSteelBlue : Color := c 176 196 222
def powderBlue : Color := c 176 224 230
def lightBlue : Color := c 173 216 230
def skyBlue : Color := c 135 206 235
def lightSkyBlue : Color := c 135 206 250
def deepSkyBlue : Color := c 0 191 255
def dodgerBlue : Color := c 30 144 255
def cornflowerBlue : Color := c 100 149 237
def royalBlue : Color := c 65 105 225
def blue : Color := c 0 0 255
def mediumBlue : Color := c 0 0 205
def darkBlue : Color := c 0 0 139
def navy : Color := c 0 0 128
def midnightBlue : Color := c 25 25 112

-- Browns
def cornsilk : Color := c 255 248 220
def blanchedAlmond : Color := c 255 235 205
def bisque : Color := c 255 228 196
def navajoWhite : Color := c 255 222 173
def wheat : Color := c 245 222 179
def burlyWood : Color := c 222 184 135
def tan : Color := c 210 180 140
def rosyBrown : Color := c 188 143 143
def sandyBrown : Color := c 244 164 96
def goldenrod : Color := c 218 165 32
def darkGoldenrod : Color := c 184 134 11
def peru : Color := c 205 133 63
def chocolate : Color := c 210 105 30
def saddleBrown : Color := c 139 69 19
def sienna : Color := c 160 82 45
def brown : Color := c 165 42 42
def maroon : Color := c 128 0 0

-- Whites
def white : Color := c 255 255 255
def snow : Color := c 255 250 250
def honeydew : Color := c 240 255 240
def mintCream : Color := c 245 255 250
def azure : Color := c 240 255 255
def aliceBlue : Color := c 240 248 255
def ghostWhite : Color := c 248 248 255
def whiteSmoke : Color := c 245 245 245
def seashell : Color := c 255 245 238
def beige : Color := c 245 245 220
def oldLace : Color := c 253 245 230
def floralWhite : Color := c 255 250 240
def ivory : Color := c 255 255 240
def antiqueWhite : Color := c 250 235 215
def linen : Color := c 250 240 230
def lavenderBlush : Color := c 255 240 245
def mistyRose : Color := c 255 228 225

-- Grays
def gainsboro : Color := c 220 220 220
def lightGray : Color := c 211 211 211
def silver : Color := c 192 192 192
def darkGray : Color := c 169 169 169
def gray : Color := c 128 128 128
def dimGray : Color := c 105 105 105
def lightSlateGray : Color := c 119 136 153
def slateGray : Color := c 112 128 144
def darkSlateGray : Color := c 47 79 79
def black : Color := c 0 0 0

end Named

/-- Map of CSS color names to colors. -/
def namedColors : List (String × Color) := [
  -- Reds
  ("indianred", Named.indianRed),
  ("lightcoral", Named.lightCoral),
  ("salmon", Named.salmon),
  ("darksalmon", Named.darkSalmon),
  ("lightsalmon", Named.lightSalmon),
  ("crimson", Named.crimson),
  ("red", Named.red),
  ("firebrick", Named.fireBrick),
  ("darkred", Named.darkRed),
  -- Pinks
  ("pink", Named.pink),
  ("lightpink", Named.lightPink),
  ("hotpink", Named.hotPink),
  ("deeppink", Named.deepPink),
  ("mediumvioletred", Named.mediumVioletRed),
  ("palevioletred", Named.paleVioletRed),
  -- Oranges
  ("coral", Named.coral),
  ("tomato", Named.tomato),
  ("orangered", Named.orangeRed),
  ("darkorange", Named.darkOrange),
  ("orange", Named.orange),
  -- Yellows
  ("gold", Named.gold),
  ("yellow", Named.yellow),
  ("lightyellow", Named.lightYellow),
  ("lemonchiffon", Named.lemonChiffon),
  ("lightgoldenrodyellow", Named.lightGoldenrodYellow),
  ("papayawhip", Named.papayaWhip),
  ("moccasin", Named.moccasin),
  ("peachpuff", Named.peachPuff),
  ("palegoldenrod", Named.paleGoldenrod),
  ("khaki", Named.khaki),
  ("darkkhaki", Named.darkKhaki),
  -- Purples
  ("lavender", Named.lavender),
  ("thistle", Named.thistle),
  ("plum", Named.plum),
  ("violet", Named.violet),
  ("orchid", Named.orchid),
  ("fuchsia", Named.fuchsia),
  ("magenta", Named.magenta),
  ("mediumorchid", Named.mediumOrchid),
  ("mediumpurple", Named.mediumPurple),
  ("rebeccapurple", Named.rebeccaPurple),
  ("blueviolet", Named.blueViolet),
  ("darkviolet", Named.darkViolet),
  ("darkorchid", Named.darkOrchid),
  ("darkmagenta", Named.darkMagenta),
  ("purple", Named.purple),
  ("indigo", Named.indigo),
  ("slateblue", Named.slateBlue),
  ("darkslateblue", Named.darkSlateBlue),
  ("mediumslateblue", Named.mediumSlateBlue),
  -- Greens
  ("greenyellow", Named.greenYellow),
  ("chartreuse", Named.chartreuse),
  ("lawngreen", Named.lawnGreen),
  ("lime", Named.lime),
  ("limegreen", Named.limeGreen),
  ("palegreen", Named.paleGreen),
  ("lightgreen", Named.lightGreen),
  ("mediumspringgreen", Named.mediumSpringGreen),
  ("springgreen", Named.springGreen),
  ("mediumseagreen", Named.mediumSeaGreen),
  ("seagreen", Named.seaGreen),
  ("forestgreen", Named.forestGreen),
  ("green", Named.green),
  ("darkgreen", Named.darkGreen),
  ("yellowgreen", Named.yellowGreen),
  ("olivedrab", Named.oliveDrab),
  ("olive", Named.olive),
  ("darkolivegreen", Named.darkOliveGreen),
  ("mediumaquamarine", Named.mediumAquamarine),
  ("darkseagreen", Named.darkSeaGreen),
  ("lightseagreen", Named.lightSeaGreen),
  ("darkcyan", Named.darkCyan),
  ("teal", Named.teal),
  -- Blues
  ("aqua", Named.aqua),
  ("cyan", Named.cyan),
  ("lightcyan", Named.lightCyan),
  ("paleturquoise", Named.paleTurquoise),
  ("aquamarine", Named.aquamarine),
  ("turquoise", Named.turquoise),
  ("mediumturquoise", Named.mediumTurquoise),
  ("darkturquoise", Named.darkTurquoise),
  ("cadetblue", Named.cadetBlue),
  ("steelblue", Named.steelBlue),
  ("lightsteelblue", Named.lightSteelBlue),
  ("powderblue", Named.powderBlue),
  ("lightblue", Named.lightBlue),
  ("skyblue", Named.skyBlue),
  ("lightskyblue", Named.lightSkyBlue),
  ("deepskyblue", Named.deepSkyBlue),
  ("dodgerblue", Named.dodgerBlue),
  ("cornflowerblue", Named.cornflowerBlue),
  ("royalblue", Named.royalBlue),
  ("blue", Named.blue),
  ("mediumblue", Named.mediumBlue),
  ("darkblue", Named.darkBlue),
  ("navy", Named.navy),
  ("midnightblue", Named.midnightBlue),
  -- Browns
  ("cornsilk", Named.cornsilk),
  ("blanchedalmond", Named.blanchedAlmond),
  ("bisque", Named.bisque),
  ("navajowhite", Named.navajoWhite),
  ("wheat", Named.wheat),
  ("burlywood", Named.burlyWood),
  ("tan", Named.tan),
  ("rosybrown", Named.rosyBrown),
  ("sandybrown", Named.sandyBrown),
  ("goldenrod", Named.goldenrod),
  ("darkgoldenrod", Named.darkGoldenrod),
  ("peru", Named.peru),
  ("chocolate", Named.chocolate),
  ("saddlebrown", Named.saddleBrown),
  ("sienna", Named.sienna),
  ("brown", Named.brown),
  ("maroon", Named.maroon),
  -- Whites
  ("white", Named.white),
  ("snow", Named.snow),
  ("honeydew", Named.honeydew),
  ("mintcream", Named.mintCream),
  ("azure", Named.azure),
  ("aliceblue", Named.aliceBlue),
  ("ghostwhite", Named.ghostWhite),
  ("whitesmoke", Named.whiteSmoke),
  ("seashell", Named.seashell),
  ("beige", Named.beige),
  ("oldlace", Named.oldLace),
  ("floralwhite", Named.floralWhite),
  ("ivory", Named.ivory),
  ("antiquewhite", Named.antiqueWhite),
  ("linen", Named.linen),
  ("lavenderblush", Named.lavenderBlush),
  ("mistyrose", Named.mistyRose),
  -- Grays
  ("gainsboro", Named.gainsboro),
  ("lightgray", Named.lightGray),
  ("lightgrey", Named.lightGray),
  ("silver", Named.silver),
  ("darkgray", Named.darkGray),
  ("darkgrey", Named.darkGray),
  ("gray", Named.gray),
  ("grey", Named.gray),
  ("dimgray", Named.dimGray),
  ("dimgrey", Named.dimGray),
  ("lightslategray", Named.lightSlateGray),
  ("lightslategrey", Named.lightSlateGray),
  ("slategray", Named.slateGray),
  ("slategrey", Named.slateGray),
  ("darkslategray", Named.darkSlateGray),
  ("darkslategrey", Named.darkSlateGray),
  ("black", Named.black),
  -- Transparent
  ("transparent", Color.transparent)
]

namespace Color

/-- Look up a color by CSS name (case-insensitive). -/
def fromName (name : String) : Option Color :=
  let name := name.toLower.trim
  namedColors.find? (·.1 == name) |>.map (·.2)

/-- Get the CSS name of a color if it matches a named color exactly. -/
def toName (c : Color) : Option String :=
  namedColors.find? (·.2 == c) |>.map (·.1)

end Color

end Tincture
