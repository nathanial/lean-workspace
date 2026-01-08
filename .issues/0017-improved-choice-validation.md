---
id: 17
title: Improved choice validation
status: closed
priority: medium
created: 2026-01-06T14:48:12
updated: 2026-01-08T07:02:30
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Improved choice validation

## Description
Choice arguments (ArgType.choice) are parsed but validation against valid options is not enforced. Add choice validation during parsing, generate proper invalidChoice errors. Better error messages, fail-fast behavior. Affects: Parse/Parser.lean, Parse/Extractor.lean

## Progress
- [2026-01-08T07:02:26] Added choice validation in parser for flags/args/defaults/env values; added parser tests for valid/invalid choices.
- [2026-01-08T07:02:30] Closed: Validate choice values during parsing with invalidChoice errors; tests added.
