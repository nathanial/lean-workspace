---
id: 608
title: Signed distance fields + CSG ops
status: closed
priority: medium
created: 2026-02-02T02:15:05
updated: 2026-02-02T07:55:13
labels: []
assignee: 
project: linalg
blocks: []
blocked_by: []
---

# Signed distance fields + CSG ops

## Description
SDF primitives (sphere/box/capsule/etc.), combine ops (union/intersect/subtract), and distance helpers.

## Progress
- [2026-02-02T07:55:09] Added SDF module with sphere/box/capsule/circle/plane primitives, composition ops, distance helpers, and tests.
- [2026-02-02T07:55:13] Closed: Implemented SDF primitives and CSG ops with distance helpers, wired into Linalg and tests; lake test passes.
