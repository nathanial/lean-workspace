---
id: 406
title: surface tool-argument parse errors in agent loop
status: closed
priority: medium
created: 2026-01-25T01:57:33
updated: 2026-01-25T02:56:46
labels: []
assignee: 
project: oracle
blocks: []
blocked_by: []
---

# surface tool-argument parse errors in agent loop

## Description
parseToolArgs returns Json.null on parse failure; propagate parse errors or include them in tool responses so handlers can react (Oracle/Agent/Loop.lean).

## Progress
- [2026-01-25T02:56:29] Return parse errors as tool responses instead of Json.null, plus test ensuring handler isn't called.
- [2026-01-25T02:56:46] Closed: Surface tool-argument parse errors as tool responses with tests (commit 3b74f00).
