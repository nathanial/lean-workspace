---
id: 17
title: Improved choice validation
status: open
priority: medium
created: 2026-01-06T14:48:12
updated: 2026-01-06T14:48:12
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Improved choice validation

## Description
Choice arguments (ArgType.choice) are parsed but validation against valid options is not enforced. Add choice validation during parsing, generate proper invalidChoice errors. Better error messages, fail-fast behavior. Affects: Parse/Parser.lean, Parse/Extractor.lean

