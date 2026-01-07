---
id: 220
title: Consider Default instead of Inhabited for Parser
status: open
priority: low
created: 2026-01-07T03:50:30
updated: 2026-01-07T03:50:30
labels: [improvement]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Consider Default instead of Inhabited for Parser

## Description
Parser has an Inhabited instance that returns a failing parser. Consider if Inhabited should instead be Default for semantic clarity (the default parser fails, which may be unexpected).

Affected: Sift/Core.lean

Effort: Small

