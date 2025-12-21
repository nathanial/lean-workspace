# Gamut Mapping for OkLab/OkLCH

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Implement gamut mapping to clamp out-of-gamut colors back into the sRGB gamut while preserving perceptual appearance as much as possible. Currently, conversions from wide-gamut color spaces can produce RGB values outside [0,1].

## Rationale
OkLCH in particular can easily produce colors outside the sRGB gamut. Proper gamut mapping (e.g., via chroma reduction) provides better results than simple clamping.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/OkLab.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/OkLCH.lean`
