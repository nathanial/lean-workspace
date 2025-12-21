# Unify Operators Module Organization

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
The `Collimator/Operators.lean` file (427 lines) contains all operators and is well-organized but quite long.

## Rationale
Consider splitting into logical groups (viewing operators, modification operators, composition operators) or adding section markers for navigation.

Easier maintenance and navigation.

## Affected Files
- `Collimator/Operators.lean`
