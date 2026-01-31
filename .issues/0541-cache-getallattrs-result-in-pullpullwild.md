---
id: 541
title: Cache getAllAttrs Result in Pull.pullWildcard
status: open
priority: low
created: 2026-01-31T00:10:50
updated: 2026-01-31T00:10:50
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Cache getAllAttrs Result in Pull.pullWildcard

## Description
getAllAttrs in Ledger/Pull/Executor.lean (lines 66-77) iterates through entity datoms and deduplicates attributes on every wildcard pull. Consider caching attribute lists per entity or using a set for deduplication. Small effort.

