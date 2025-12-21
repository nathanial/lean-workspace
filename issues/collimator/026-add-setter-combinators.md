# Add Setter Combinators

**Priority:** Medium
**Section:** API Enhancements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add more setter-specific combinators for common modification patterns.

Proposed Additions:
- `mapped` - setter for functor contents
- `setting` - create setter from modification function
- `assign` - for use with State monad
- `+=`, `-=`, `*=` operators for numeric fields

## Affected Files
- `Collimator/Combinators.lean`
- `Collimator/Operators.lean`
- Tests
