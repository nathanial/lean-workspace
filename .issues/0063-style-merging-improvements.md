---
id: 63
title: Style Merging Improvements
status: open
priority: medium
created: 2026-01-06T22:46:10
updated: 2026-01-06T22:46:10
labels: [improvement]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Style Merging Improvements

## Description
Style.merge in Terminus/Core/Style.lean has simple override semantics that may not match user expectations. Implement more nuanced style merging with explicit inheritance rules, possibly using a StyleDiff type. More predictable style composition for complex UIs.

