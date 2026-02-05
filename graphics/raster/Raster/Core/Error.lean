/-
  Raster.Core.Error - Error types for image operations
-/

namespace Raster

/-- Errors that can occur during image operations -/
inductive RasterError where
  | loadFailed (path : String) (reason : String)
  | decodeFailed (reason : String)
  | encodeFailed (format : String) (reason : String)
  | writeFailed (path : String) (reason : String)
  | invalidDimensions (width height : Nat)
  | invalidFormat (msg : String)
  | outOfBounds (x y width height : Nat)
  | unsupportedOperation (msg : String)
  | ioError (msg : String)
  deriving Repr

instance : ToString RasterError where
  toString e := match e with
    | .loadFailed path reason => s!"Failed to load image '{path}': {reason}"
    | .decodeFailed reason => s!"Failed to decode image: {reason}"
    | .encodeFailed fmt reason => s!"Failed to encode {fmt}: {reason}"
    | .writeFailed path reason => s!"Failed to write to '{path}': {reason}"
    | .invalidDimensions w h => s!"Invalid dimensions: {w}x{h}"
    | .invalidFormat msg => s!"Invalid format: {msg}"
    | .outOfBounds x y w h => s!"Coordinates ({x}, {y}) out of bounds for {w}x{h} image"
    | .unsupportedOperation msg => s!"Unsupported operation: {msg}"
    | .ioError msg => s!"IO error: {msg}"

/-- Result type for raster operations -/
abbrev RasterResult (α : Type) := Except RasterError α

end Raster
