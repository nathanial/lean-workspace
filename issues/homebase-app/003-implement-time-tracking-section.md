# Implement Time Tracking Section

## Summary

The Time section is currently a placeholder stub. Implement a time tracking feature for logging activities, projects, and generating reports.

## Current State

- Route exists: `GET /time`
- Action: `Time.index` only checks login and renders placeholder
- View: Shows "Time - Coming soon!" with emoji
- No data model defined

## Requirements

### Data Model (Models.lean)

```lean
-- Time tracking attributes
def timeEntryDescription : LedgerAttribute := ...
def timeEntryDuration : LedgerAttribute := ...  -- minutes
def timeEntryDate : LedgerAttribute := ...
def timeEntryCategory : LedgerAttribute := ...
def timeEntryProject : LedgerAttribute := ...  -- ref
def timeProjectName : LedgerAttribute := ...
def timeProjectColor : LedgerAttribute := ...

structure DbTimeEntry where
  id : Nat
  description : String
  duration : Nat           -- minutes
  date : Nat               -- Unix timestamp
  category : String
  project : Option EntityId
  deriving Repr, BEq

structure DbProject where
  id : Nat
  name : String
  color : String           -- hex color
  deriving Repr, BEq
```

### Routes to Add

```
GET  /time                        → Dashboard/today view
GET  /time/entries                → List all entries
POST /time/entry                  → Create entry
GET  /time/entry/:id/edit         → Edit entry form
PUT  /time/entry/:id              → Update entry
DELETE /time/entry/:id            → Delete entry
GET  /time/week                   → Weekly view
GET  /time/month                  → Monthly view
GET  /time/report                 → Generate report
POST /time/project                → Create project
GET  /time/timer/start            → Start timer (HTMX)
GET  /time/timer/stop             → Stop timer (HTMX)
```

### Actions (Actions/Time.lean)

- `index`: Today's entries with quick-add form
- `listEntries`: Paginated list of all entries
- `createEntry`: Log new time entry
- `editEntry`: Show edit form
- `updateEntry`: Update entry
- `deleteEntry`: Delete entry
- `weekView`: Show week with totals
- `monthView`: Show month with totals
- `report`: Generate time report by project/category
- `createProject`: Create new project
- `startTimer`: Begin tracking (store start time in session)
- `stopTimer`: End tracking, create entry

### Views (Views/Time.lean)

- Today's timeline view
- Quick-add entry form
- Timer widget (start/stop button with elapsed time)
- Weekly calendar grid
- Monthly summary
- Project list with colors
- Category breakdown chart (simple ASCII or SVG)
- Report table with totals

### Timer Feature

- Start button starts timer (timestamp in session)
- Elapsed time display updates via SSE or polling
- Stop button creates entry with calculated duration
- Running timer persists across page navigations

## Acceptance Criteria

- [ ] User can log time entries manually
- [ ] Timer for real-time tracking
- [ ] Entries have description, duration, date, project, category
- [ ] Weekly and monthly views with totals
- [ ] Project management with colors
- [ ] Category-based organization
- [ ] Reports showing time by project/category
- [ ] HTMX for smooth interactions
- [ ] Audit logging for entries

## Technical Notes

- Duration stored in minutes for simplicity
- Timer state in session (startTime)
- Consider keyboard shortcuts for quick entry
- Charts can be simple ASCII tables initially

## Priority

High - Productivity tracking is a key dashboard feature

## Estimate

Large - Multiple views + timer + reports
