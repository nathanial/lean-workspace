# Remove Hardcoded Font Path

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Font path is hardcoded to system location:
```lean
let titleFont <- Font.load "/System/Library/Fonts/Monaco.ttf" ...
```

Action required:
- Accept font path as configuration or command-line argument
- Fall back to bundled font if system font unavailable
- Consider embedding a default font or using Afferent's font discovery

## Rationale
Portable, cross-platform compatibility.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/Main.lean` (lines 29-30)
