/-
  Measures - Type-Safe Units of Measure for Lean 4

  A library for compile-time dimensional analysis. Prevents unit mismatch
  bugs at compile time with zero runtime overhead.

  ## Features

  - Type-safe quantities with dimension tracking
  - SI, Imperial, and custom unit support
  - Compile-time dimension checking
  - Temperature scales with offset handling
  - Angle units (dimensionless)

  ## Quick Start

  ```lean
  import Measures

  open Measures
  open Measures.Units.SI
  open Measures.Units.Imperial

  -- Create quantities
  def distance := 100.0 *: meter
  def time := 9.58 *: second

  -- Arithmetic with dimension tracking
  def speed := distance /. time  -- Quantity Dimension.Velocity

  -- Convert units
  #eval distance.asUnit foot  -- ~328.084

  -- This would be a compile-time error:
  -- def bad := distance + time  -- Type mismatch!
  ```
-/

-- Core types
import Measures.Core.Dimension
import Measures.Core.Quantity
import Measures.Core.Unit

-- Common dimensions
import Measures.Dimensions

-- Constants
import Measures.Constants

-- Operations
import Measures.Ops.Arithmetic
import Measures.Ops.Comparison

-- Units
import Measures.Units.SI
import Measures.Units.Imperial
import Measures.Units.Time
import Measures.Units.Temperature
import Measures.Units.Angle
