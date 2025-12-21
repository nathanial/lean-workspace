# Standardize Infix Operator Documentation

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description

The infix operators `≡` and `≡?` defined at lines 69-70 of `Crucible/Core.lean` lack comprehensive documentation about their precedence and behavior.

## Affected Files

- `/Users/Shared/Projects/lean-workspace/crucible/Crucible/Core.lean` lines 69-70

## Action Required

Add detailed docstrings explaining:
- What each operator does
- Precedence level (currently 50)
- How to type the Unicode characters
- Comparison with named functions
