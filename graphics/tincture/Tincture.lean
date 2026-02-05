/-
  Tincture - Comprehensive Color Library for Lean 4

  Features:
  - Multiple color spaces: RGB, HSL, HSV, HWB, XYZ, Lab, LCH, OkLab, OkLCH, CMYK
  - Color operations: lighten, darken, saturate, blend modes, mixing
  - Color harmony: complementary, triadic, analogous, and more
  - Accessibility: WCAG contrast ratios, color blindness simulation
  - Parsing/formatting: hex, CSS strings, named colors
  - Gradients and palettes
-/

-- Core color type
import Tincture.Color

-- Color spaces
import Tincture.Space.RGB
import Tincture.Space.HSL
import Tincture.Space.HSV
import Tincture.Space.HWB
import Tincture.Space.XYZ
import Tincture.Space.Lab
import Tincture.Space.LCH
import Tincture.Space.OkLab
import Tincture.Space.OkLCH
import Tincture.Space.CMYK

-- Unified conversion
import Tincture.Convert

-- Color operations
import Tincture.Adjust
import Tincture.Blend
import Tincture.Harmony

-- Color analysis
import Tincture.Distance
import Tincture.Contrast
import Tincture.Blindness

-- Parsing and formatting
import Tincture.Parse
import Tincture.Format
import Tincture.Named

-- Gradients and palettes
import Tincture.Gradient
import Tincture.Palette
