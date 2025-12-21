# Named Color Lookup by Closest Match

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** Color distance functionality already exists

## Description
Add a function to find the closest named color to an arbitrary color, using perceptual color distance (deltaE2000).

## Rationale
Useful for color identification, accessibility tools, and generating human-readable color descriptions.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Named.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Distance.lean`
