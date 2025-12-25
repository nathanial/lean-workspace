# Add Notifications System

## Summary

Implement an in-app notification system for alerts, reminders, and activity updates.

## Current State

- Flash messages for immediate feedback
- SSE for Kanban updates
- No persistent notifications
- No system for alerts/reminders

## Requirements

### Data Model

```lean
-- Notification attributes
def notificationUser : LedgerAttribute := ⟨":notification/user", .ref, .one⟩
def notificationType : LedgerAttribute := ⟨":notification/type", .string, .one⟩
def notificationTitle : LedgerAttribute := ⟨":notification/title", .string, .one⟩
def notificationBody : LedgerAttribute := ⟨":notification/body", .string, .one⟩
def notificationRead : LedgerAttribute := ⟨":notification/read", .bool, .one⟩
def notificationCreatedAt : LedgerAttribute := ⟨":notification/created-at", .nat, .one⟩
def notificationLink : LedgerAttribute := ⟨":notification/link", .string, .one⟩

structure DbNotification where
  id : Nat
  user : EntityId
  type : String         -- "info", "warning", "reminder", "activity"
  title : String
  body : String
  read : Bool
  createdAt : Nat
  link : Option String  -- URL to related content
  deriving Repr, BEq
```

### Notification Types

```lean
inductive NotificationType
  | info           -- General information
  | warning        -- Important alerts
  | reminder       -- Time-based reminders
  | activity       -- Actions by others (future: collaboration)
  | system         -- System messages
  deriving Repr, BEq
```

### Routes

```
GET  /notifications               → List notifications
GET  /notifications/unread        → Unread count (HTMX)
POST /notifications/:id/read      → Mark as read
POST /notifications/read-all      → Mark all as read
DELETE /notifications/:id         → Delete notification
DELETE /notifications/clear       → Clear all read notifications
```

### Actions

```lean
-- Actions/Notifications.lean

def list : ActionM Unit := do
  requireAuth
  let userId ← currentUserEntityId
  let notifications ← getNotifications ctx.db userId
  render (Views.Notifications.list notifications)

def unreadCount : ActionM Unit := do
  requireAuth
  let userId ← currentUserEntityId
  let count ← countUnread ctx.db userId
  -- HTMX partial for badge
  respondHtml do
    when count > 0 do
      span [class "badge"] do text (toString count)

def markRead (notificationId : Nat) : ActionM Unit := do
  requireAuth
  let userId ← currentUserEntityId
  -- Verify ownership
  setRead ctx.db (EntityId.ofNat notificationId) true
  respondHtml do text "✓"

def markAllRead : ActionM Unit := do
  requireAuth
  let userId ← currentUserEntityId
  markAllAsRead ctx.db userId
  redirect "/notifications"
```

### Creating Notifications

```lean
-- Helpers/Notifications.lean

def createNotification
    (db : Database)
    (userId : EntityId)
    (type : NotificationType)
    (title body : String)
    (link : Option String := none)
    : IO EntityId := do
  db.transact [
    .tempid "n" |>.add ":notification/user" (.ref userId)
    .tempid "n" |>.add ":notification/type" (.string type.toString)
    .tempid "n" |>.add ":notification/title" (.string title)
    .tempid "n" |>.add ":notification/body" (.string body)
    .tempid "n" |>.add ":notification/read" (.bool false)
    .tempid "n" |>.add ":notification/created-at" (.nat (← now))
    .tempid "n" |>.add ":notification/link" (.string (link.getD ""))
  ]

-- Example usage in Kanban
def notifyCardDue (userId : EntityId) (card : DbCard) : IO Unit := do
  createNotification ctx.db userId .reminder
    s!"Card due soon: {card.title}"
    s!"The card '{card.title}' is due in 1 hour"
    (some s!"/kanban/card/{card.id}")
```

### Views

```lean
-- Views/Notifications.lean

def bell (unreadCount : Nat) : HtmlM Unit := do
  a [
    href "/notifications",
    class "notification-bell",
    hxGet "/notifications/unread",
    hxTrigger "every 30s",
    hxSwap "innerHTML"
  ] do
    text "🔔"
    when unreadCount > 0 do
      span [class "badge"] do text (toString unreadCount)

def list (notifications : List DbNotification) : HtmlM Unit := do
  layout "Notifications" do
    div [class "notifications-header"] do
      h1 do text "Notifications"
      button [
        hxPost "/notifications/read-all",
        hxSwap "none"
      ] do text "Mark all read"

    if notifications.isEmpty then
      div [class "empty"] do text "No notifications"
    else
      ul [class "notification-list"] do
        for n in notifications do
          notificationItem n

def notificationItem (n : DbNotification) : HtmlM Unit := do
  li [
    class (if n.read then "notification read" else "notification unread"),
    id s!"notification-{n.id}"
  ] do
    div [class "notification-icon"] do
      text (iconFor n.type)

    div [class "notification-content"] do
      h3 do text n.title
      p do text n.body
      span [class "time"] do text (formatRelativeTime n.createdAt)

    div [class "notification-actions"] do
      unless n.read do
        button [
          hxPost s!"/notifications/{n.id}/read",
          hxTarget s!"#notification-{n.id}",
          hxSwap "outerHTML"
        ] do text "✓"

      match n.link with
      | some link => a [href link] do text "View"
      | none => pure ()

def iconFor (type : NotificationType) : String :=
  match type with
  | .info => "ℹ️"
  | .warning => "⚠️"
  | .reminder => "⏰"
  | .activity => "👤"
  | .system => "⚙️"
```

### Layout Integration

```lean
-- In navbar
div [class "navbar-right"] do
  Views.Notifications.bell unreadCount
  -- ... user menu
```

### SSE for Real-Time

```lean
-- Push notification via SSE
def pushNotification (userId : EntityId) (notification : DbNotification) : IO Unit := do
  let event := {
    type := "notification"
    data := toJson notification
  }
  sseManager.send userId event
```

```javascript
// Client-side SSE handler
const eventSource = new EventSource('/events/user');
eventSource.addEventListener('notification', (e) => {
  const notification = JSON.parse(e.data);
  showToast(notification.title, notification.body);
  updateBadge();
});

function showToast(title, body) {
  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.innerHTML = `<h4>${title}</h4><p>${body}</p>`;
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 5000);
}
```

## Acceptance Criteria

- [ ] Notification bell in navbar
- [ ] Unread count badge
- [ ] List all notifications
- [ ] Mark individual as read
- [ ] Mark all as read
- [ ] Delete notifications
- [ ] Notification types with icons
- [ ] Click to navigate to related content
- [ ] Real-time updates via SSE
- [ ] Toast notifications for new items

## Technical Notes

- Notifications auto-expire after 30 days (cleanup job)
- Consider browser notifications (Web Notifications API)
- SSE channel per user for real-time
- Mobile push notifications (future)

## Priority

Low - Nice to have for engagement

## Estimate

Medium - Data model + UI + real-time
