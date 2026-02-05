# Tincture

Color library for Lean 4 with RGBA and HSV support.

## Features

- **RGBA Colors**: Create colors with red, green, blue, and alpha components
- **HSV Support**: Create colors using hue, saturation, value color model
- **Named Colors**: Common colors like red, blue, green, white, black, etc.
- **Color Operations**: Interpolation, alpha manipulation, premultiplied alpha

## Installation

Add to your `lakefile.lean`:

```lean
require tincture from git "https://github.com/nathanial/tincture" @ "master"
```

## Usage

```lean
import Tincture

open Tincture (Color)

-- Create colors
let red := Color.red
let custom := Color.rgb 0.5 0.3 0.8
let withAlpha := Color.rgba 1.0 0.0 0.0 0.5
let fromHsv := Color.hsv 0.33 1.0 1.0  -- green

-- Manipulate colors
let faded := red.withAlpha 0.5
let mixed := Color.lerp Color.red Color.blue 0.5  -- purple
let premult := Color.premultiply custom
```

## API

### Creation

- `Color.rgba r g b a` - Create with explicit alpha
- `Color.rgb r g b` - Create with alpha = 1.0
- `Color.hsv h s v` - Create from HSV (h in [0,1])
- `Color.hsva h s v a` - Create from HSV with alpha

### Named Colors

`black`, `white`, `red`, `green`, `blue`, `yellow`, `cyan`, `magenta`, `orange`, `purple`, `transparent`

### Grays

- `Color.gray value` - Create grayscale color
- `Color.darkGray` - 25% gray
- `Color.lightGray` - 75% gray

### Manipulation

- `withAlpha c a` - Replace alpha channel
- `lerp c1 c2 t` - Linear interpolation
- `premultiply c` - Convert to premultiplied alpha
- `unpremultiply c` - Convert from premultiplied alpha

## License

MIT
