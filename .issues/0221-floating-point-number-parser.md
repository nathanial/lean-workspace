---
id: 221
title: Floating-point number parser
status: closed
priority: high
created: 2026-01-07T03:50:59
updated: 2026-01-07T04:16:13
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Floating-point number parser

## Description
Add parsers for floating-point numbers (scientific notation, decimals). Currently only integers are supported.

Proposed API:
- float : Parser Float (decimal or scientific notation)
- decimal : Parser Float (decimal only)
- scientific : Parser Float (scientific notation like 1.5e10)

Rationale: Floating-point numbers are extremely common in real-world parsing (JSON, configs, data formats).

Affected: Sift/Text.lean

Effort: Medium

## Progress
- [2026-01-07T04:15:14] float parser already exists - adding decimal and scientific specialized variants
- [2026-01-07T04:16:13] Closed: Added decimal and scientific parsers. float already existed - updated issue description was outdated.
