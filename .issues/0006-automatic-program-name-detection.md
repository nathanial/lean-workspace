---
id: 6
title: Automatic program name detection
status: open
priority: high
created: 2026-01-06T14:47:03
updated: 2026-01-06T14:47:03
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Automatic program name detection

## Description
Auto-detect program name from argv[0] instead of requiring explicit specification in command builder. Proposed: parseArgs myCommand (uses System.programName automatically). Affects: Parse/Parser.lean, add convenience functions

