# Replace Axioms with Proofs in Core.lean

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The file `Collimator/Core.lean` contains two axioms at lines 277 and 331:
- `axiom instLawfulStrongArrow : LawfulStrong (fun a b : Type u => a -> b)`
- `axiom instLawfulChoiceArrow : LawfulChoice (fun a b : Type u => a -> b)`

## Rationale
Replace these axioms with actual proofs. The laws should be provable by straightforward case analysis and function extensionality.

Eliminates axioms from the core module, improves trustworthiness of the library.

## Affected Files
- `Collimator/Core.lean`
