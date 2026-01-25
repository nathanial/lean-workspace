---
id: 406
title: surface tool-argument parse errors in agent loop
status: open
priority: medium
created: 2026-01-25T01:57:33
updated: 2026-01-25T01:57:33
labels: []
assignee: 
project: oracle
blocks: []
blocked_by: []
---

# surface tool-argument parse errors in agent loop

## Description
parseToolArgs returns Json.null on parse failure; propagate parse errors or include them in tool responses so handlers can react (Oracle/Agent/Loop.lean).

