# Consolidate Key Types with Datom Comparison Functions

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
There are four separate key types (EAVTKey, AEVTKey, AVETKey, VAETKey) in `Ledger/Index/Types.lean` that duplicate ordering logic that also exists in `Ledger/Core/Datom.lean` (compareEAVT, compareAEVT, etc.).

## Rationale
Consider:
- Use newtype wrappers over Datom with different Ord instances
- Or generate key types and their instances with metaprogramming
- Or consolidate comparison logic to avoid duplication

Benefits:
- Reduced code duplication
- Single source of truth for ordering semantics
- Easier maintenance

## Affected Files
- `Ledger/Index/Types.lean`
- `Ledger/Core/Datom.lean`
