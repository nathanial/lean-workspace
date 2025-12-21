# Theme System

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Create a centralized theming system with color schemes, typography scales, spacing tokens, and component-level style overrides.

## Rationale
Arbor's BoxStyle is per-widget. Applications need consistent theming across all widgets. Terminus demonstrates this with its Style types. Canopy should provide a Theme structure that propagates design tokens through the widget tree.

## Affected Files
- `Canopy/Theme/Core.lean` (new)
- `Canopy/Theme/Colors.lean` (new)
- `Canopy/Theme/Typography.lean` (new)
- `Canopy/Theme/Spacing.lean` (new)
- `Canopy/Theme/Presets.lean` (new)

## Proposed Design
```lean
structure Theme where
  colors : ColorScheme
  typography : TypographyScale
  spacing : SpacingScale
  borderRadius : Float
  shadows : ShadowScheme

structure ColorScheme where
  primary : Color
  secondary : Color
  background : Color
  surface : Color
  error : Color
  onPrimary : Color
  onSecondary : Color
  onBackground : Color
  onSurface : Color
  onError : Color
```
