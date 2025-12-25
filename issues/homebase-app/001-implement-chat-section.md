# Implement Chat Section

## Summary

The Chat section is currently a placeholder stub. Implement a full real-time chat feature for personal notes/conversations or future multi-user messaging.

## Current State

- Route exists: `GET /chat`
- Action: `Chat.index` only checks login and renders placeholder
- View: Shows "Chat - Coming soon!" with emoji
- No data model defined

## Requirements

### Data Model (Models.lean)

```lean
-- Chat attributes
def chatMessageContent : LedgerAttribute := ...
def chatMessageTimestamp : LedgerAttribute := ...
def chatMessageUser : LedgerAttribute := ...  -- ref to user
def chatThreadTitle : LedgerAttribute := ...
def chatThreadMessages : LedgerAttribute := ... -- ref many

structure DbChatMessage where
  id : Nat
  content : String
  timestamp : Nat  -- Unix timestamp
  user : EntityId
  deriving Repr, BEq

structure DbChatThread where
  id : Nat
  title : String
  messages : List EntityId
  deriving Repr, BEq
```

### Routes to Add

```
GET  /chat                    → List threads
GET  /chat/thread/:id         → View thread messages
POST /chat/thread             → Create new thread
POST /chat/thread/:id/message → Add message to thread
DELETE /chat/thread/:id       → Delete thread
GET  /chat/search?q=          → Search messages
```

### Actions (Actions/Chat.lean)

- `index`: List all chat threads with preview
- `showThread`: Display thread with all messages
- `createThread`: Create new thread
- `addMessage`: Add message to thread (HTMX partial)
- `deleteThread`: Delete thread with confirmation
- `search`: Search across all messages

### Views (Views/Chat.lean)

- Thread list sidebar
- Message display area
- New message input with send button
- Thread creation modal
- Search results view
- Timestamp formatting (relative: "2 hours ago")

### SSE Integration

- Real-time message updates using existing SSE infrastructure
- Topic: `chat` or `chat-thread-{id}`

## Acceptance Criteria

- [ ] User can create new chat threads
- [ ] User can send messages in threads
- [ ] Messages display with timestamps
- [ ] Threads show unread count or last message preview
- [ ] Search finds messages across all threads
- [ ] Real-time updates via SSE
- [ ] HTMX for smooth UX without page reloads
- [ ] Audit logging for message operations

## Technical Notes

- Reuse patterns from Kanban implementation
- Consider markdown support for messages
- Timestamps should be server-generated (not client)

## Priority

Medium - Nice to have for personal dashboard

## Estimate

Large - Full CRUD + real-time + search
