---
id: 109
title: Add Termination Proofs for Recursive Functions
status: open
priority: low
created: 2026-01-06T23:28:57
updated: 2026-01-06T23:28:57
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Add Termination Proofs for Recursive Functions

## Description
layoutNode is marked partial without a termination proof. Similarly, nodeCount and allIds in Node.lean. Add termination_by clauses or refactor to use Nat.rec patterns to prove termination. Stronger correctness guarantees. Effort: Medium

