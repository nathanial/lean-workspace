---
id: 233
title: JSON number parser
status: open
priority: low
created: 2026-01-07T03:51:24
updated: 2026-01-07T03:51:24
labels: [feature]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# JSON number parser

## Description
Add a parser specifically for JSON-compliant numbers.

Rationale: JSON has specific rules for numbers (no leading zeros except 0.x, no +prefix, etc.). A dedicated parser ensures compliance.

Affected: Sift/Text.lean

Effort: Small

Dependencies: Floating-point parser

