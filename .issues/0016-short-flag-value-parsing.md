---
id: 16
title: Short flag value parsing
status: closed
priority: medium
created: 2026-01-06T14:48:12
updated: 2026-01-08T06:45:02
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Short flag value parsing

## Description
Handle -ovalue style (short flag with attached value). Currently -ovalue is tokenized as multiple short flags. Both -o file and -ofile should work. Better POSIX compliance. Affects: Parse/Tokenizer.lean (lines 66-72), Parse/Parser.lean

## Progress
- [2026-01-08T06:44:58] Implemented short-flag attached value parsing and cluster handling; added tokenizer/parser tests.
- [2026-01-08T06:45:02] Closed: Support -ofile short flag values with cluster parsing; tests added.
