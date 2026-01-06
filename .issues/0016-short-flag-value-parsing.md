---
id: 16
title: Short flag value parsing
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

# Short flag value parsing

## Description
Handle -ovalue style (short flag with attached value). Currently -ovalue is tokenized as multiple short flags. Both -o file and -ofile should work. Better POSIX compliance. Affects: Parse/Tokenizer.lean (lines 66-72), Parse/Parser.lean

