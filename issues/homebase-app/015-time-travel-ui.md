# Expose Ledger Time-Travel in UI

## Summary

Ledger supports time-travel queries (viewing database state at any point in time). Expose this powerful feature in the UI for viewing history and potentially undoing changes.

## Current State

- Ledger database supports `db.asOf(txId)` and `db.history(entityId)`
- This capability is not exposed in any UI
- Users cannot see or undo past changes
- Audit logs exist but are separate from database history

## Requirements

### Use Cases

1. **View entity history**: See all changes to a card/note/etc.
2. **Restore previous version**: Undo accidental changes
3. **Audit trail**: See who changed what and when
4. **Point-in-time view**: See board state at specific date

### Data Model

Ledger already tracks:
- Transaction ID for each change
- Timestamp of each transaction
- Entity/Attribute/Value/Tx tuples

### Routes

```
GET /history/entity/:id           → Entity change history
GET /history/tx/:txId             → Transaction details
GET /snapshot?date=<timestamp>    → Point-in-time view
POST /history/restore/:id/:txId   → Restore entity to previous state
```

### Actions (Actions/History.lean)

```lean
def entityHistory (entityId : Nat) : ActionM Unit := do
  requireAuth
  let history ← getEntityHistory ctx.db (EntityId.ofNat entityId)
  render (Views.History.entityHistory history)

def transactionDetails (txId : Nat) : ActionM Unit := do
  requireAuth
  let tx ← getTransactionDetails ctx.db txId
  render (Views.History.transactionDetails tx)

def snapshot : ActionM Unit := do
  requireAuth
  let timestamp ← param "date"
  let db ← ctx.db.asOf timestamp
  -- Render current view with historical data

def restoreEntity (entityId txId : Nat) : ActionM Unit := do
  requireAuth
  -- Get entity state at txId
  -- Create new transaction with those values
  -- Flash success
  redirect "/history/entity/{entityId}"
```

### History Query Functions

```lean
structure HistoryEntry where
  txId : Nat
  timestamp : Nat
  attribute : String
  oldValue : Option Value
  newValue : Value
  deriving Repr

def getEntityHistory (db : Database) (entityId : EntityId) : IO (List HistoryEntry) := do
  -- Use Ledger's history API
  let history ← db.history entityId
  return history.map fun (attr, val, tx, added) => {
    txId := tx
    timestamp := getTimestamp tx
    attribute := attr
    oldValue := if added then none else some val
    newValue := if added then val else none
  }

def getTransactionDetails (db : Database) (txId : Nat) : IO TransactionDetails := do
  -- Get all datoms from this transaction
  ...
```

### Views (Views/History.lean)

```lean
def entityHistory (entity : EntityDetails) (history : List HistoryEntry) : HtmlM Unit := do
  layout s!"History: {entity.title}" do
    h1 do text s!"History for {entity.title}"

    a [href entity.url] do text "← Back to entity"

    div [class "timeline"] do
      for entry in history do
        div [class "timeline-entry"] do
          div [class "timestamp"] do
            text (formatTimestamp entry.timestamp)
          div [class "change"] do
            span [class "attribute"] do text entry.attribute
            match entry.oldValue with
            | some old =>
              span [class "old-value"] do text (formatValue old)
              text " → "
            | none => pure ()
            span [class "new-value"] do text (formatValue entry.newValue)
          div [class "actions"] do
            button [
              hxPost s!"/history/restore/{entity.id}/{entry.txId}",
              hxConfirm "Restore to this version?"
            ] do text "Restore"

def transactionDetails (tx : TransactionDetails) : HtmlM Unit := do
  layout s!"Transaction #{tx.id}" do
    h1 do text s!"Transaction #{tx.id}"

    div [class "tx-meta"] do
      p do text s!"Time: {formatTimestamp tx.timestamp}"
      p do text s!"Changes: {tx.changes.length}"

    table [class "changes-table"] do
      thead do
        tr do
          th do text "Entity"
          th do text "Attribute"
          th do text "Value"
          th do text "Operation"
      tbody do
        for change in tx.changes do
          tr do
            td do a [href s!"/history/entity/{change.entityId}"] do
              text s!"#{change.entityId}"
            td do text change.attribute
            td do text (formatValue change.value)
            td do text (if change.added then "Added" else "Retracted")
```

### Integration Points

Add history links throughout the app:

```lean
-- In Kanban card view
div [class "card-footer"] do
  a [href s!"/history/entity/{card.id}"] do
    text "View history"

-- In settings
a [href "/history/snapshot"] do
  text "Time Machine"
```

### Time Machine Feature

Point-in-time view of entire board:

```lean
def timeMachine : HtmlM Unit := do
  layout "Time Machine" do
    h1 do text "Time Machine"

    form [action "/snapshot", method "get"] do
      label do text "View data as of:"
      input [type "datetime-local", name "date"]
      button [type "submit"] do text "Go"

    -- Show calendar of changes
    div [class "activity-calendar"] do
      -- Days with changes highlighted
      ...
```

## Acceptance Criteria

- [ ] View history for any entity
- [ ] See all changes with timestamps
- [ ] Restore entity to previous version
- [ ] View transaction details
- [ ] Point-in-time snapshots of board
- [ ] History links on entity views
- [ ] Activity calendar showing change density
- [ ] Proper authorization (only own data)

## Technical Notes

- Ledger's fact-based model makes this possible
- Restoration creates new facts, doesn't delete history
- Large histories may need pagination
- Consider caching recent history queries

## Priority

Low - Advanced feature, foundation already exists

## Estimate

Medium - UI work + integration with Ledger history API
