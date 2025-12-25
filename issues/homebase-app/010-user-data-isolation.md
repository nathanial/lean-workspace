# Implement User Data Isolation

## Summary

Currently all users share the same database - any user can see and modify all Kanban boards, notes, etc. Implement proper user data isolation so each user only sees their own data.

## Current State

- Single database file: `data/homebase.jsonl`
- No user reference on Kanban columns/cards
- All queries return all data regardless of logged-in user
- Any authenticated user can modify any entity

## Problems

1. **Privacy**: Users can see each other's data
2. **Security**: Users can modify each other's data
3. **Multi-tenancy**: Cannot support multiple users properly

## Requirements

### Schema Changes

Add user references to all entities:

```lean
-- Add to Models.lean
def columnUser : LedgerAttribute :=
  ⟨":column/user", .ref, .one⟩

def cardUser : LedgerAttribute :=
  ⟨":card/user", .ref, .one⟩

-- Update DbColumn
structure DbColumn where
  id : Nat
  name : String
  order : Nat
  user : EntityId  -- NEW: owner reference
  deriving Repr, BEq

-- Update DbCard
structure DbCard where
  id : Nat
  title : String
  description : String
  labels : String
  order : Nat
  column : EntityId
  user : EntityId  -- NEW: owner reference
  deriving Repr, BEq
```

### Query Changes

All queries must filter by current user:

```lean
-- Before
def getColumns (db : Database) : IO (List DbColumn) := do
  let results ← db.query [
    .find [.var "e", .var "name", .var "order"]
    .where_ [
      [.var "e", .keyword ":column/name", .var "name"],
      [.var "e", .keyword ":column/order", .var "order"]
    ]
  ]
  ...

-- After
def getColumns (db : Database) (userId : EntityId) : IO (List DbColumn) := do
  let results ← db.query [
    .find [.var "e", .var "name", .var "order"]
    .where_ [
      [.var "e", .keyword ":column/name", .var "name"],
      [.var "e", .keyword ":column/order", .var "order"],
      [.var "e", .keyword ":column/user", .entityId userId]  -- NEW
    ]
  ]
  ...
```

### Authorization Checks

Add ownership verification for all mutations:

```lean
def authorizeColumn (db : Database) (userId : EntityId) (columnId : EntityId) : IO Bool := do
  let owner ← db.pull columnId [":column/user"]
  return owner.get? ":column/user" == some (.ref userId)

def updateColumn (ctx : ActionContext) (columnId : Nat) (name : String) : ActionM Unit := do
  let userId ← currentUserId ctx
  let authorized ← authorizeColumn ctx.db userId (EntityId.ofNat columnId)
  if !authorized then
    return forbidden "Not authorized to modify this column"
  -- proceed with update
```

### Helper Functions

```lean
-- Get current user's EntityId
def currentUserEntityId (ctx : ActionContext) : IO (Option EntityId) := do
  let sessionUserId ← currentUserId ctx
  -- Convert session user ID to EntityId
  return some (EntityId.ofNat sessionUserId)

-- Scoped query helper
def withUserScope (db : Database) (userId : EntityId) (query : Query) : Query :=
  -- Add user filter to existing query
  ...
```

### Migration

For existing data:
1. Find the first user in database
2. Assign all orphaned entities to that user
3. Or: Add migration prompt on startup

```lean
def migrateOrphanedEntities (db : Database) : IO Unit := do
  -- Find entities without user reference
  let orphaned ← db.query [...]
  -- Prompt or auto-assign to admin user
  ...
```

## Acceptance Criteria

- [ ] All entities have user reference attribute
- [ ] All queries filter by current user
- [ ] All mutations verify ownership before proceeding
- [ ] Users cannot see other users' data
- [ ] Users cannot modify other users' data
- [ ] Migration path for existing data
- [ ] Tests verify isolation

## Technical Notes

- EntityId comparison needs to be robust
- Consider admin role that can see all data
- Sharing features would be a future enhancement
- Audit logs should include user context

## Priority

**High** - Privacy and security requirement for multi-user

## Estimate

Large - Schema changes + query updates + authorization + migration
