/-
  Measures.Constants

  Mathematical and physical constants used throughout the library.
  Physical constants are defined as typed Quantity values with correct dimensions.

  Values are from CODATA 2018 recommended values.
  https://physics.nist.gov/cuu/Constants/
-/

import Measures.Core.Quantity
import Measures.Dimensions

namespace Measures.Constants

/-! ## Mathematical Constants -/

/-- Pi - the ratio of a circle's circumference to its diameter. -/
def π : Float := 3.14159265358979323846

/-- Tau (2π) - the ratio of a circle's circumference to its radius. -/
def τ : Float := 2.0 * π

/-! ## Fundamental Physical Constants -/

/-- Speed of light in vacuum (c).
    Exact value: 299,792,458 m/s -/
def speedOfLight : Quantity Dimension.Velocity :=
  { value := 299792458.0 }

/-- Alias for speed of light. -/
abbrev c := speedOfLight

/-- Planck constant (h).
    Value: 6.62607015 × 10⁻³⁴ J·s (exact) -/
def planckConstant : Quantity Dimension.Action :=
  { value := 6.62607015e-34 }

/-- Alias for Planck constant. -/
abbrev h := planckConstant

/-- Reduced Planck constant (ℏ = h/2π).
    Value: 1.054571817 × 10⁻³⁴ J·s -/
def reducedPlanckConstant : Quantity Dimension.Action :=
  { value := 6.62607015e-34 / (2.0 * π) }

/-- Alias for reduced Planck constant. -/
abbrev ℏ := reducedPlanckConstant
abbrev hbar := reducedPlanckConstant

/-- Newtonian constant of gravitation (G).
    Value: 6.67430 × 10⁻¹¹ m³/(kg·s²) -/
def gravitationalConstant : Quantity Dimension.GravitationalConstant :=
  { value := 6.67430e-11 }

/-- Alias for gravitational constant. -/
abbrev G := gravitationalConstant

/-! ## Electromagnetic Constants -/

/-- Elementary charge (e).
    Exact value: 1.602176634 × 10⁻¹⁹ C -/
def elementaryCharge : Quantity Dimension.Charge :=
  { value := 1.602176634e-19 }

/-- Alias for elementary charge. -/
abbrev e_charge := elementaryCharge

/-- Vacuum electric permittivity (ε₀).
    Value: 8.8541878128 × 10⁻¹² F/m -/
def vacuumPermittivity : Quantity Dimension.Permittivity :=
  { value := 8.8541878128e-12 }

/-- Alias for vacuum permittivity. -/
abbrev ε₀ := vacuumPermittivity

/-- Vacuum magnetic permeability (μ₀).
    Value: 1.25663706212 × 10⁻⁶ H/m -/
def vacuumPermeability : Quantity Dimension.Permeability :=
  { value := 1.25663706212e-6 }

/-- Alias for vacuum permeability. -/
abbrev μ₀ := vacuumPermeability

/-! ## Thermodynamic Constants -/

/-- Boltzmann constant (k_B).
    Exact value: 1.380649 × 10⁻²³ J/K -/
def boltzmannConstant : Quantity Dimension.Entropy :=
  { value := 1.380649e-23 }

/-- Alias for Boltzmann constant. -/
abbrev k_B := boltzmannConstant

/-- Stefan-Boltzmann constant (σ).
    Value: 5.670374419 × 10⁻⁸ W/(m²·K⁴) -/
def stefanBoltzmannConstant : Quantity Dimension.StefanBoltzmann :=
  { value := 5.670374419e-8 }

/-- Alias for Stefan-Boltzmann constant. -/
abbrev σ := stefanBoltzmannConstant

/-- Molar gas constant (R).
    Exact value: 8.314462618 J/(mol·K) -/
def gasConstant : Quantity Dimension.MolarEntropy :=
  { value := 8.314462618 }

/-- Alias for gas constant. -/
abbrev R := gasConstant

/-! ## Atomic and Nuclear Constants -/

/-- Avogadro constant (N_A).
    Exact value: 6.02214076 × 10²³ mol⁻¹ -/
def avogadroConstant : Quantity Dimension.InverseAmount :=
  { value := 6.02214076e23 }

/-- Alias for Avogadro constant. -/
abbrev N_A := avogadroConstant

/-- Electron mass (m_e).
    Value: 9.1093837015 × 10⁻³¹ kg -/
def electronMass : Quantity Dimension.Mass :=
  { value := 9.1093837015e-31 }

/-- Alias for electron mass. -/
abbrev m_e := electronMass

/-- Proton mass (m_p).
    Value: 1.67262192369 × 10⁻²⁷ kg -/
def protonMass : Quantity Dimension.Mass :=
  { value := 1.67262192369e-27 }

/-- Alias for proton mass. -/
abbrev m_p := protonMass

/-- Neutron mass (m_n).
    Value: 1.67492749804 × 10⁻²⁷ kg -/
def neutronMass : Quantity Dimension.Mass :=
  { value := 1.67492749804e-27 }

/-- Alias for neutron mass. -/
abbrev m_n := neutronMass

/-- Atomic mass unit (u).
    Value: 1.66053906660 × 10⁻²⁷ kg -/
def atomicMassUnit : Quantity Dimension.Mass :=
  { value := 1.66053906660e-27 }

/-- Alias for atomic mass unit. -/
abbrev u := atomicMassUnit
abbrev amu := atomicMassUnit

/-! ## Derived Constants -/

/-- Fine-structure constant (α ≈ 1/137).
    Dimensionless. Value: 7.2973525693 × 10⁻³ -/
def fineStructureConstant : Quantity Dimension.one :=
  { value := 7.2973525693e-3 }

/-- Alias for fine-structure constant. -/
abbrev α := fineStructureConstant

/-- Rydberg constant (R_∞).
    Value: 10,973,731.568160 m⁻¹ -/
def rydbergConstant : Quantity Dimension.Length.inv :=
  { value := 10973731.568160 }

/-- Alias for Rydberg constant. -/
abbrev R_inf := rydbergConstant

/-- Bohr radius (a_0).
    Value: 5.29177210903 × 10⁻¹¹ m -/
def bohrRadius : Quantity Dimension.Length :=
  { value := 5.29177210903e-11 }

/-- Alias for Bohr radius. -/
abbrev a_0 := bohrRadius

/-- Standard acceleration of gravity (g_n).
    Value: 9.80665 m/s² (exact, by definition) -/
def standardGravity : Quantity Dimension.Acceleration :=
  { value := 9.80665 }

/-- Alias for standard gravity. -/
abbrev g_n := standardGravity

/-- Standard atmosphere pressure.
    Value: 101,325 Pa (exact, by definition) -/
def standardAtmosphere : Quantity Dimension.Pressure :=
  { value := 101325.0 }

/-- Alias for standard atmosphere. -/
abbrev atm := standardAtmosphere

end Measures.Constants
