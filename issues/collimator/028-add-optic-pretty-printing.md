# Add Optic Pretty Printing

**Priority:** Low
**Section:** API Enhancements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Implement `Repr` or custom pretty printing for optic types to aid debugging.

## Rationale
Currently optics are functions and don't print meaningfully. Named optics with metadata would improve debugging experience.

## Affected Files
- New: Potentially `Collimator/Debug/Pretty.lean`
- Modify: Optic type definitions to carry optional metadata
