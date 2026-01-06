---
id: 114
title: Consolidate Test Helper Functions
status: open
priority: medium
created: 2026-01-06T23:29:20
updated: 2026-01-06T23:29:20
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Consolidate Test Helper Functions

## Description
floatNear and shouldBeNear in tests duplicate functionality that could be in Crucible test framework. Either move to Crucible as reusable assertions or add to a shared test utilities module. Affected: TrellisTests/Main.lean. Effort: Small

