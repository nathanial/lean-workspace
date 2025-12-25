# Enhance Home Dashboard with Widgets

## Summary

Transform the home page from a simple welcome message into a useful dashboard with widgets showing data from all sections.

## Current State

- Home page shows simple welcome message
- No aggregated data from sections
- No customization options
- No quick actions

## Requirements

### Dashboard Layout

```lean
def index : HtmlM Unit := do
  layout "Dashboard" do
    div [class "dashboard"] do
      div [class "dashboard-header"] do
        h1 do text s!"Welcome back, {userName}"
        span [class "date"] do text (formatDate today)

      div [class "widget-grid"] do
        kanbanWidget
        notebookWidget
        timeWidget
        healthWidget
        -- Add more as sections are implemented
```

### Widget Components

#### Kanban Summary Widget

```lean
def kanbanWidget (summary : KanbanSummary) : HtmlM Unit := do
  div [class "widget kanban-widget"] do
    div [class "widget-header"] do
      h3 do text "📋 Kanban"
      a [href "/kanban"] do text "View all →"

    div [class "widget-stats"] do
      div [class "stat"] do
        span [class "value"] do text (toString summary.todoCount)
        span [class "label"] do text "To Do"
      div [class "stat"] do
        span [class "value"] do text (toString summary.inProgressCount)
        span [class "label"] do text "In Progress"
      div [class "stat"] do
        span [class "value"] do text (toString summary.doneCount)
        span [class "label"] do text "Done"

    div [class "widget-content"] do
      h4 do text "Recent Cards"
      ul do
        for card in summary.recentCards do
          li do
            a [href s!"/kanban/card/{card.id}"] do text card.title

structure KanbanSummary where
  todoCount : Nat
  inProgressCount : Nat
  doneCount : Nat
  recentCards : List DbCard
```

#### Time Tracking Widget

```lean
def timeWidget (stats : TimeStats) : HtmlM Unit := do
  div [class "widget time-widget"] do
    div [class "widget-header"] do
      h3 do text "⏱️ Time Today"
      a [href "/time"] do text "View all →"

    div [class "time-total"] do
      span [class "hours"] do text (formatHours stats.todayTotal)
      span [class "label"] do text "hours today"

    div [class "time-chart"] do
      -- Simple bar chart of week
      for (day, hours) in stats.weekData do
        div [class "bar", style s!"height: {hours * 10}px"] do
          span [class "day"] do text day

    div [class "quick-actions"] do
      button [
        hxGet "/time/timer/start",
        hxTarget "#timer-status"
      ] do text "Start Timer"
```

#### Health Widget

```lean
def healthWidget (entry : Option DbHealthEntry) : HtmlM Unit := do
  div [class "widget health-widget"] do
    div [class "widget-header"] do
      h3 do text "💚 Health"
      a [href "/health"] do text "Log today →"

    match entry with
    | some e =>
      div [class "health-status"] do
        div [class "metric"] do
          span [class "label"] do text "Symptoms"
          div [class "scale"] do
            for i in [1, 2, 3, 4, 5] do
              span [class (if i <= e.symptomLevel then "filled" else "")] do text "●"
        div [class "metric"] do
          span [class "label"] do text "Meal Quality"
          div [class "scale"] do
            for i in [1, 2, 3, 4, 5] do
              span [class (if i <= e.mealQuality then "filled" else "")] do text "●"
    | none =>
      div [class "not-logged"] do
        text "Not logged today"
        a [href "/health/log"] do text "Log now"
```

#### Quick Notes Widget

```lean
def notebookWidget (notes : List DbNote) : HtmlM Unit := do
  div [class "widget notebook-widget"] do
    div [class "widget-header"] do
      h3 do text "📝 Notes"
      a [href "/notebook"] do text "View all →"

    div [class "recent-notes"] do
      for note in notes.take 3 do
        a [href s!"/notebook/note/{note.id}", class "note-preview"] do
          h4 do text note.title
          p do text (note.content.take 100 ++ "...")
          span [class "date"] do text (formatDate note.updatedAt)

    button [hxGet "/notebook/new", class "quick-add"] do
      text "+ Quick Note"
```

#### Activity Feed Widget

```lean
def activityWidget (events : List AuditLogEntry) : HtmlM Unit := do
  div [class "widget activity-widget"] do
    div [class "widget-header"] do
      h3 do text "📊 Recent Activity"

    ul [class "activity-feed"] do
      for event in events.take 10 do
        li [class "activity-item"] do
          span [class "icon"] do text (iconFor event.action)
          span [class "description"] do text event.description
          span [class "time"] do text (formatRelativeTime event.timestamp)
```

### Dashboard Data Aggregation

```lean
-- Actions/Home.lean

def index : ActionM Unit := do
  requireAuth
  let userId ← currentUserEntityId

  -- Gather data from all sections in parallel
  let kanbanSummary ← getKanbanSummary ctx.db userId
  let timeStats ← getTimeStats ctx.db userId
  let healthToday ← getTodayHealthEntry ctx.db userId
  let recentNotes ← getRecentNotes ctx.db userId 3
  let activity ← getRecentActivity ctx.db userId 10

  render (Views.Home.dashboard {
    userName := ← currentUserName
    kanban := kanbanSummary
    time := timeStats
    health := healthToday
    notes := recentNotes
    activity := activity
  })
```

### Widget Customization (Future)

```lean
-- User can reorder/hide widgets
def userDashboardConfig : LedgerAttribute := ⟨":user/dashboard-config", .string, .one⟩

structure DashboardConfig where
  widgets : List String        -- Widget IDs in order
  hiddenWidgets : List String  -- Hidden widget IDs
  deriving ToJson, FromJson
```

### CSS Grid Layout

```css
.widget-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
  padding: 24px;
}

.widget {
  background: var(--bg-primary);
  border-radius: 8px;
  border: 1px solid var(--border-color);
  padding: 16px;
}

.widget-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.widget-stats {
  display: flex;
  gap: 24px;
}

.stat {
  text-align: center;
}

.stat .value {
  font-size: 24px;
  font-weight: bold;
  color: var(--accent-primary);
}
```

## Acceptance Criteria

- [ ] Dashboard replaces simple home page
- [ ] Kanban summary widget with stats
- [ ] Time tracking widget with today's hours
- [ ] Health status widget
- [ ] Recent notes widget
- [ ] Activity feed widget
- [ ] Quick action buttons
- [ ] Responsive grid layout
- [ ] Widgets update via HTMX

## Technical Notes

- Parallel data fetching for performance
- Cache widget data for fast refresh
- HTMX partials for individual widget updates
- Consider lazy loading for below-fold widgets

## Priority

Medium - Improves daily usability

## Estimate

Medium - Multiple widgets + aggregation logic
