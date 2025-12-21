# Rich Comparison Assertions

**Priority:** High
**Section:** API Enhancements
**Estimated Effort:** Medium
**Dependencies:** None

## Description

Add assertions that provide better diff output for complex types.

## Proposed Additions

- `shouldContainAll` - Check list contains all expected elements
- `shouldHaveKeys` - Check map/dict has expected keys
- `shouldStartWith`, `shouldEndWith` - String prefix/suffix checks
- `shouldMatchRegex` - Regular expression matching

## Affected Files

- `Crucible/Core.lean`
