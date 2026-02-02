---
id: 673
title: add class/method parser and stdlib bootstrap
status: closed
priority: high
created: 2026-02-02T04:55:47
updated: 2026-02-02T05:06:57
labels: []
assignee: 
project: smalltalk
blocks: []
blocked_by: []
---

# add class/method parser and stdlib bootstrap

## Description
Extend Smalltalk parser to handle class/method definitions, and add a bootstrap path to load a Smalltalk standard library from source.

## Progress
- [2026-02-02T05:06:54] Implemented class parser with method delimiters, added stdlib loader + default Stdlib.st, updated CLI flags and parser tests.
- [2026-02-02T05:06:57] Closed: Added class definitions parsing, stdlib bootstrap loader + default Stdlib.st, CLI flags, and tests; lake test passes.
