---
id: 536
title: Full-Text Search Index
status: open
priority: low
created: 2026-01-31T00:10:37
updated: 2026-01-31T00:10:37
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Full-Text Search Index

## Description
Add a full-text search index for string attributes. AVET index supports exact value matching but not text search. Enables tokenized text indexing, fuzzy matching, relevance scoring. New file: Ledger/Index/Fulltext.lean. Modify: Index/Manager.lean, Query/AST.lean. Large effort. Depends on Schema System.

