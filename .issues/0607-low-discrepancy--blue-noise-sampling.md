---
id: 607
title: Low-discrepancy + blue-noise sampling
status: closed
priority: medium
created: 2026-02-02T02:15:01
updated: 2026-02-02T07:50:14
labels: []
assignee: 
project: linalg
blocks: []
blocked_by: []
---

# Low-discrepancy + blue-noise sampling

## Description
Poisson-disk sampling, blue-noise generators, and low-discrepancy sequences (Halton/Sobol/Hammersley).

## Progress
- [2026-02-02T07:50:10] Added sampling module with Halton, Hammersley, Sobol (2D) sequences, Poisson-disk blue-noise sampling, and tests.
- [2026-02-02T07:50:14] Closed: Implemented low-discrepancy sequences (Halton/Hammersley/Sobol2) and blue-noise Poisson-disk sampling with tests; wired into Linalg and test suite; lake test passes.
