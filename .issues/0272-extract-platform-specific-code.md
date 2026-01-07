---
id: 272
title: Extract Platform-Specific Code
status: open
priority: medium
created: 2026-01-07T04:09:07
updated: 2026-01-07T04:09:07
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Extract Platform-Specific Code

## Description
macOS-specific code (keycodes, PTY FFI) is mixed with portable code. Create platform abstraction layer for PTY and input handling for easier future porting to Linux/Windows. Affects: Vane/PTY/, Vane/App/Input.lean

