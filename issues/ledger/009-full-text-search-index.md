# Full-Text Search Index

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** Schema System (to mark attributes as fulltext-indexed)

## Description
Add a full-text search index for string attributes.

## Rationale
The AVET index supports exact value matching but not text search. Full-text search would enable:
- Tokenized text indexing
- Fuzzy matching
- Relevance scoring

## Affected Files
- New file: `Ledger/Index/Fulltext.lean`
- Modify: `Ledger/Index/Manager.lean` (manage fulltext index)
- Modify: `Ledger/Query/AST.lean` (add fulltext clause)
