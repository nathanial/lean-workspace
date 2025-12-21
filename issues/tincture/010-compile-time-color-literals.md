# Compile-Time Color Literals

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add a macro or elaborator for compile-time validated color literals (e.g., `color!"#ff0000"` or `color!"rgb(255, 0, 0)"`).

## Rationale
Catches color parsing errors at compile time rather than runtime, improves developer experience.

## Affected Files
- New file: `Tincture/Syntax.lean`
