# Implement Health Tracker Section

## Summary

The Health section is currently a placeholder stub. Implement a health tracking feature specifically designed for Crohn's Disease management (as noted in the original design), tracking meals, symptoms, medications, and patterns.

## Current State

- Route exists: `GET /health`
- Action: `Health.index` only checks login and renders placeholder
- View: Shows "Health - Coming soon!" with emoji and "Crohn's Disease Tracker" subtitle
- No data model defined

## Requirements

### Data Model (Models.lean)

```lean
-- Health tracking attributes
def healthEntryDate : LedgerAttribute := ...
def healthEntryMealQuality : LedgerAttribute := ...  -- 1-5 scale
def healthEntrySymptomLevel : LedgerAttribute := ... -- 1-5 scale
def healthEntryMedication : LedgerAttribute := ...
def healthEntryNotes : LedgerAttribute := ...
def healthEntryMeals : LedgerAttribute := ...        -- cardinality many
def healthEntrySymptoms : LedgerAttribute := ...     -- cardinality many

structure DbHealthEntry where
  id : Nat
  date : Nat              -- Unix timestamp
  mealQuality : Nat       -- 1-5 scale
  symptomLevel : Nat      -- 1-5 scale
  medication : Bool
  notes : String
  meals : List String     -- what was eaten
  symptoms : List String  -- specific symptoms
  deriving Repr, BEq

-- Predefined symptom types
def symptomTypes := ["fatigue", "pain", "cramping", "bloating", "nausea", "diarrhea", "other"]

-- Predefined meal categories
def mealCategories := ["safe", "risky", "new", "trigger"]
```

### Routes to Add

```
GET  /health                      → Dashboard with recent entries
GET  /health/log                  → New entry form
POST /health/entry                → Create entry
GET  /health/entry/:id            → View entry details
GET  /health/entry/:id/edit       → Edit entry form
PUT  /health/entry/:id            → Update entry
DELETE /health/entry/:id          → Delete entry
GET  /health/calendar             → Monthly calendar view
GET  /health/trends               → Trend analysis
GET  /health/triggers             → Food trigger analysis
```

### Actions (Actions/Health.lean)

- `index`: Dashboard with today's status and recent history
- `logForm`: Show entry form (date, meals, symptoms, medication, notes)
- `createEntry`: Create new health entry
- `showEntry`: Display entry details
- `editEntry`: Show edit form
- `updateEntry`: Update entry
- `deleteEntry`: Delete entry
- `calendarView`: Monthly view with color-coded days
- `trendsView`: Show patterns over time
- `triggersView`: Analyze food-symptom correlations

### Views (Views/Health.lean)

- Daily log form with:
  - Meal quality slider (1-5)
  - Symptom level slider (1-5)
  - Medication checkbox
  - Symptom multi-select (fatigue, pain, cramping, etc.)
  - Meals text area (what was eaten)
  - Notes text area
- Calendar view with color-coded days (green=good, yellow=moderate, red=bad)
- Trend charts showing symptom patterns
- Food trigger correlation list
- Weekly/monthly summary stats

### Dashboard Widgets

- Today's status indicator
- Week trend mini-chart
- Streak counter (days logged)
- Quick-log button

## Acceptance Criteria

- [ ] User can log daily health entries
- [ ] Entries include meal quality, symptoms, medication, notes
- [ ] Multi-select for symptom types
- [ ] Calendar view with color coding by symptom level
- [ ] Trend visualization over time
- [ ] Food trigger analysis (correlate meals with bad days)
- [ ] HTMX for smooth form interactions
- [ ] Audit logging for entries

## Technical Notes

- Privacy: This is sensitive health data - consider encryption at rest
- Symptom level affects day color: 1-2=green, 3=yellow, 4-5=red
- Meal quality inverse relationship with symptoms
- Time-travel queries useful for historical analysis
- Consider export to share with doctors

## Priority

Medium - Specialized feature, important for target user

## Estimate

Large - Multiple views + analysis + charts
