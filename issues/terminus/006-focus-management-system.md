# Focus Management System

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** Composable Widget Typeclass

## Description
Implement a focus management system for navigating between interactive widgets using Tab/Shift+Tab or arrow keys.

## Rationale
Currently each application must manually track focus state. A centralized focus system would reduce boilerplate and provide consistent behavior across applications.

## Affected Files
- New file: `Terminus/Core/Focus.lean`
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Widgets/Widget.lean` (focusable trait)
- Interactive widgets (TextInput, TextArea, etc.)
