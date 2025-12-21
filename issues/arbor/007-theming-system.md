# Theming System

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add a theming layer for consistent styling across widgets.

## Rationale
Currently styles are set per-widget. A theming system would provide default styles, color tokens, and typography presets that widgets inherit.

## Affected Files
- `Arbor/Theme.lean` (new file)
- `Arbor/Widget/DSL.lean` - themed widget builders

## Proposed API
```lean
structure Theme where
  colors : ThemeColors
  typography : ThemeTypography
  spacing : ThemeSpacing
  borders : ThemeBorders

structure ThemeColors where
  primary : Color
  secondary : Color
  background : Color
  surface : Color
  error : Color
  onPrimary : Color
  ...
```
