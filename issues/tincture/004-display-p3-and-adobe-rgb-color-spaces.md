# Display-P3 and Adobe RGB Color Spaces

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add support for wide-gamut color spaces like Display-P3 (used on modern Apple devices) and Adobe RGB (used in photography).

## Rationale
Wide-gamut displays are increasingly common. Supporting these spaces would enable accurate color representation for professional graphics workflows.

## Affected Files
- New file: `Tincture/Space/DisplayP3.lean`
- New file: `Tincture/Space/AdobeRGB.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Convert.lean`
