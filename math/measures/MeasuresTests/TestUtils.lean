/-
  MeasuresTests.TestUtils

  Shared utilities for test modules.
-/

import Measures.Constants

namespace MeasuresTests.TestUtils

open Measures.Constants

/-- Re-export π from Constants for convenience in tests. -/
abbrev π := Measures.Constants.π

/-- Check if two floats are approximately equal. -/
def approxEq (a b : Float) (tol : Float := 1e-6) : Bool :=
  Float.abs (a - b) ≤ tol

end MeasuresTests.TestUtils
