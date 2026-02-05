# Lighthouse Roadmap

This document outlines potential improvements, new features, and code cleanup opportunities for the Lighthouse terminal debugger for Ledger databases.

---

## Feature Proposals

### [Priority: High] Full Datalog Query Support

**Description:** Replace the simple `:attr=value` query syntax with full Datalog-style query support using Ledger's `Query` AST and executor.

**Rationale:** The current query interface only supports basic attribute/value lookup. Ledger already provides a full Datalog-style query engine with logic variables, pattern matching, AND/OR/NOT clauses, and multi-pattern joins. Exposing this would make Lighthouse a much more powerful debugging tool.

**Current State:** Query.lean uses a custom simple parser that only handles `:attr` or `:attr="value"` patterns.

**Proposed Change:**
- Add a query parser that converts text to `Ledger.Query` AST
- Support syntax like: `[:find ?e :where [?e :user/name ?n] [?e :user/age 30]]`
- Display multi-column results for queries with multiple find variables
- Add query history with up/down arrow navigation

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Query.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/State/AppState.lean` (add query history)

**Estimated Effort:** Large

**Dependencies:** None (Ledger.Query already exists)

---

### [Priority: High] Pull Pattern Display in Entity View

**Description:** Use Ledger's Pull API to display nested entity trees in the detail pane, with expandable references.

**Rationale:** The Entity view currently shows a flat list of datoms. When an entity references another entity, users must manually navigate to see the referenced data. The Pull API supports nested patterns that could display entity trees inline.

**Current State:** Entity.lean shows flat `[attr: value]` rows with reference values displayed as `-> Entity N`.

**Proposed Change:**
- Add expandable tree display for reference values using the Tree widget from terminus
- Support `[` and `]` or `+`/`-` keys to expand/collapse nested entities
- Configure pull depth limit (default 2 levels)
- Show reverse references (entities that point to this one)

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/State/AppState.lean` (add expanded state)

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: High] Comprehensive Test Suite

**Description:** Add actual unit tests for the application logic beyond the placeholder test file.

**Rationale:** The current test file (`Tests/Main.lean`) only contains a placeholder that prints a message. No actual tests exist for state management, query parsing, navigation logic, or view state updates.

**Current State:**
```lean
def main : IO UInt32 := do
  IO.println "Lighthouse tests (placeholder)"
  return 0
```

**Proposed Change:**
- Add tests for `EntityViewState` navigation (up/down/history)
- Add tests for `TxViewState` expand/collapse and time-travel
- Add tests for `AttrViewState` matching entity refresh
- Add tests for `QueryViewState` query parsing and execution
- Add tests for `collectEntities` and `collectAttributes` deduplication
- Add tests for scroll offset calculations

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Tests/Main.lean`
- New file: `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Tests/State.lean`
- New file: `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Tests/Query.lean`
- New file: `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Tests/Navigation.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Entity Search/Filter

**Description:** Add a search/filter capability to the Entity view to quickly find entities by attribute values.

**Rationale:** Databases can have thousands of entities. Currently users must scroll through the entire list. A filter would allow typing to narrow down the list.

**Proposed Change:**
- Add `/` key binding to enter search mode in Entity view (similar to Query view)
- Filter entity list as user types (match entity ID or any attribute value)
- Highlight matching terms in the detail pane
- Show result count in the title (e.g., "Entities (5/100 matching)")

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/State/AppState.lean` (add filter state)

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Transaction Diff View

**Description:** Show a diff view comparing database state before and after a transaction.

**Rationale:** Currently transactions show added/removed datoms, but it's hard to understand the net effect. A diff view would show which entities changed and what their before/after states are.

**Proposed Change:**
- Add `d` key binding for "diff mode" in Transaction view
- Split the transaction detail into "Before" and "After" columns
- Highlight changed attributes with colors (green=added, red=removed, yellow=changed)
- Allow navigation between changed entities

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Transaction.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/State/AppState.lean` (add diff mode state)

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Export Functionality

**Description:** Export query results, entity data, or transaction history to JSON or other formats.

**Rationale:** Users may want to extract data for external analysis, reporting, or sharing. Currently there's no way to export data from the TUI.

**Proposed Change:**
- Add `e` or `Ctrl+E` binding to export current view's data
- Support export formats: JSON, CSV (for tabular data), EDN
- For entities: export all datoms for selected entity
- For queries: export all result rows
- For transactions: export transaction log with datoms
- Write to file with configurable path or clipboard

**Affected Files:**
- New file: `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/Export.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Update.lean` (add export key handling)

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Bookmarks/Favorites

**Description:** Allow users to bookmark frequently accessed entities or save named queries.

**Rationale:** During debugging sessions, users often return to the same entities or run the same queries. Bookmarks would speed up navigation.

**Proposed Change:**
- Add `m` key to bookmark current entity with a name
- Add `'` key to open bookmark list popup
- Store bookmarks in a local config file (e.g., `~/.lighthouse/bookmarks.json`)
- For queries: allow saving named queries that can be re-executed
- Show bookmarked entities with a star marker in the entity list

**Affected Files:**
- New file: `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/Bookmarks.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/State/AppState.lean` (add bookmark state)
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Mouse Support

**Description:** Enable mouse-based navigation (click to select, scroll wheel).

**Rationale:** The current implementation explicitly ignores mouse events (`| _ => (state, false)`). Many terminal emulators support mouse input, which would make the tool more accessible.

**Proposed Change:**
- Handle `.mouse` events in Update.lean
- Implement click-to-select in entity/attribute/transaction lists
- Implement scroll wheel for list navigation
- Add clickable tab switching
- Add click-to-expand for transactions and tree nodes

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Update.lean`
- All view files in `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/`

**Estimated Effort:** Medium

**Dependencies:** Terminus mouse event support (already available)

---

### [Priority: Medium] Resize Event Handling

**Description:** Properly handle terminal resize events to recalculate layout.

**Rationale:** Currently resize events are ignored. If the terminal is resized, the layout may become corrupted until the user triggers a redraw.

**Proposed Change:**
- Handle `.resize` events in Update.lean
- Recalculate scroll offsets to keep selected items visible
- Trigger full redraw on resize

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Update.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Low] Schema View

**Description:** Add a new view (5: Schema) showing the database schema derived from attribute usage patterns.

**Rationale:** Ledger databases are schemaless, but patterns emerge from usage. A schema view would help users understand the data model.

**Proposed Change:**
- Add new `View.schema` variant
- Show all attributes grouped by namespace prefix (e.g., `user/*`, `card/*`)
- For each attribute, show: value types observed, cardinality (one/many), referenced entity types
- Show entity "types" inferred from attribute co-occurrence patterns

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/Core/Types.lean`
- New file: `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Schema.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Draw.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Update.lean`

**Estimated Effort:** Large

**Dependencies:** None

---

### [Priority: Low] Statistics Dashboard

**Description:** Add a statistics view showing database metrics and health information.

**Rationale:** For large databases, understanding size, distribution, and performance characteristics would be valuable.

**Proposed Change:**
- Show total datom count, entity count, attribute count
- Show transaction rate over time (if timestamps available)
- Show storage size (file size)
- Show attribute value type distribution (per attribute)
- Show entity "type" distribution (by common attribute patterns)
- Use terminus Chart widgets (BarChart, PieChart) for visualization

**Affected Files:**
- New file: `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Stats.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/Core/Types.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Low] Command Palette

**Description:** Add a fuzzy-searchable command palette (like VS Code Ctrl+Shift+P).

**Rationale:** As features grow, remembering all key bindings becomes difficult. A command palette would make all actions discoverable.

**Proposed Change:**
- Add `Ctrl+P` or `:` binding to open command palette
- Show all available commands with their key bindings
- Support fuzzy matching for command names
- Use terminus Popup widget for overlay

**Affected Files:**
- New file: `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/CommandPalette.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Update.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Draw.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Low] Help Screen

**Description:** Add a help screen showing all available key bindings for the current view.

**Rationale:** The current help text in the status bar is very limited. Users need a way to discover all available commands.

**Proposed Change:**
- Add `?` or `F1` key binding to toggle help overlay
- Show context-sensitive help based on current view
- Show both global and view-specific bindings
- Use terminus Popup widget

**Affected Files:**
- New file: `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Help.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Update.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Draw.lean`

**Estimated Effort:** Small

**Dependencies:** None

---

## Code Improvements

### [Priority: High] Extract Duplicated formatValue Functions

**Current State:** The `formatValue` function is duplicated across three files with minor variations:
- `Entity.lean` (lines 22-31)
- `Transaction.lean` (lines 18-29, as `formatDatom`)
- `Attribute.lean` (lines 22-31)

**Proposed Change:** Extract to a shared module (e.g., `Lighthouse/Core/Format.lean`) with configurable truncation length.

**Benefits:** Reduces code duplication, ensures consistent formatting across views.

**Affected Files:**
- New file: `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/Core/Format.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Transaction.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Attribute.lean`

**Estimated Effort:** Small

---

### [Priority: High] Extract Duplicated borderStyle Functions

**Current State:** The `borderStyle` function is duplicated in Entity.lean (line 18) and Attribute.lean (line 18) with identical implementations.

**Proposed Change:** Move to a shared UI utilities module.

**Benefits:** Single source of truth for styling conventions.

**Affected Files:**
- New file: `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Styles.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Attribute.lean`

**Estimated Effort:** Small

---

### [Priority: High] Fix Scroll Offset Calculation for Down Navigation

**Current State:** In Entity.lean (lines 128-131), when navigating down, the scroll offset is not adjusted to keep the selection visible. The up navigation properly adjusts scrollOffset (lines 122-127), but down navigation does not.

**Proposed Change:** Add scroll offset adjustment when selectedIdx moves below visible area:
```lean
| .down | .char 'j' =>
  let maxIdx := state.entityState.entities.size - 1
  let newIdx := min (state.entityState.selectedIdx + 1) maxIdx
  -- Adjust scroll if selection moved below visible area
  let visibleHeight := 20 -- Should be passed from draw context
  let newOffset := if newIdx >= state.entityState.scrollOffset + visibleHeight
    then newIdx - visibleHeight + 1
    else state.entityState.scrollOffset
  { state with entityState.selectedIdx := newIdx, entityState.scrollOffset := newOffset }
```

**Benefits:** Fixes bug where scrolling down past visible area doesn't scroll the list.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Attribute.lean` (same issue)

**Estimated Effort:** Small

---

### [Priority: Medium] Use Terminus List Widget Instead of Manual Rendering

**Current State:** Entity list, attribute list, and query results are rendered manually with loops writing strings to the frame.

**Proposed Change:** Use the Terminus `List` widget which handles selection, scrolling, and highlighting automatically.

**Benefits:** Cleaner code, consistent behavior, built-in scroll indicator.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Attribute.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Query.lean`

**Estimated Effort:** Medium

---

### [Priority: Medium] Use Terminus Tree Widget for Transaction View

**Current State:** Transactions with expandable datoms are rendered manually with custom expand/collapse logic.

**Proposed Change:** Use the Terminus `Tree` widget which provides built-in expand/collapse, indentation, and keyboard navigation.

**Benefits:** Better UX, consistent with other tree-based tools, less manual rendering code.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Transaction.lean`

**Estimated Effort:** Medium

---

### [Priority: Medium] Add Scrollbar Indicators

**Current State:** Long lists have no visual indication of scroll position or total size.

**Proposed Change:** Use the Terminus `Scrollbar` widget to show position within scrollable content.

**Benefits:** Better UX for large datasets.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Attribute.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Transaction.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Query.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Use TextInput Widget for Query Input

**Current State:** Query input is manually implemented with cursor tracking and character insertion logic (Query.lean lines 134-161).

**Proposed Change:** Use the Terminus `TextInput` widget which provides cursor rendering, selection, copy/paste, and proper text editing.

**Benefits:** Better input experience, less code to maintain, consistent with standard text input behavior.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Query.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/State/AppState.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Improve Entity Collection Performance

**Current State:** `collectEntities` and `collectAttributes` in App.lean use O(n^2) deduplication:
```lean
let seen := entityIds.foldl (init := (#[] : Array EntityId)) fun acc eid =>
  if acc.contains eid then acc else acc.push eid
```

**Proposed Change:** Use a HashSet for O(n) deduplication, then convert to Array.

**Benefits:** Much faster for large databases.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/App.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Add Type Annotations for Clarity

**Current State:** Many functions use type inference without explicit signatures.

**Proposed Change:** Add explicit type signatures to all public functions for documentation.

**Benefits:** Better readability, self-documenting code.

**Affected Files:** All source files

**Estimated Effort:** Small

---

### [Priority: Low] Extract View-Specific Update Functions

**Current State:** Each view has an `update` function that handles all key events inline with match statements.

**Proposed Change:** Split into smaller, focused functions (e.g., `handleNavigation`, `handleSelection`, `handleAction`) for better testability.

**Benefits:** Easier testing, clearer logic separation.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Transaction.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Attribute.lean`
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Query.lean`

**Estimated Effort:** Medium

---

## Code Cleanup

### [Priority: High] Remove Unused hi Variable in For Loops

**Issue:** Multiple for loops declare an unused `hi` hypothesis variable (e.g., `for hi : i in [startIdx:endIdx]`). The `hi` is never used.

**Location:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean` (line 56)
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Attribute.lean` (line 50, 82)
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Query.lean` (line 90)
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Transaction.lean` (line 54)

**Action Required:** Remove `hi :` prefix from loop declarations or use `_` if hypothesis needed.

**Estimated Effort:** Small

---

### [Priority: Medium] Status Message Never Cleared

**Issue:** `statusMessage` is set in Transaction.lean but never cleared after display. It will persist until another action sets it.

**Location:** `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Transaction.lean` (lines 133, 142)

**Action Required:** Either:
1. Clear status message on next key event
2. Add timeout-based clearing
3. Make status message transient (cleared after one render)

**Estimated Effort:** Small

---

### [Priority: Medium] Inconsistent Error Handling

**Issue:** Some functions return `Option` while others use `Except`. Query execution uses `Except String` but error is stored as `Option String`.

**Location:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Query.lean` (lines 18, 74)
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/State/AppState.lean` (line 74)

**Action Required:** Standardize on one error handling pattern. Consider using a dedicated `Result` type or consistent `Except`.

**Estimated Effort:** Small

---

### [Priority: Medium] Magic Numbers in Layout

**Issue:** Hard-coded percentages and heights appear throughout:
- Split ratios: 35%, 40%
- Input area height: 5

**Location:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean` (line 41: `35`)
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Attribute.lean` (line 35: `40`)
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Query.lean` (line 46: `5`)

**Action Required:** Extract to named constants in a Config or Theme module.

**Estimated Effort:** Small

---

### [Priority: Low] Improve CLI Help Message

**Issue:** The CLI usage message is minimal: `"Usage: lighthouse <database.jsonl>"`. It doesn't describe what the tool does or available options.

**Location:** `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Main.lean` (line 13)

**Action Required:** Add more descriptive help text, consider using parlance CLI library for proper argument parsing.

**Estimated Effort:** Small

---

### [Priority: Low] Add Error Handling for Database Load

**Issue:** Database loading in `initState` doesn't handle errors gracefully (e.g., file not found, parse errors).

**Location:** `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/App.lean` (lines 39-82)

**Action Required:** Wrap in try/catch, display user-friendly error message.

**Estimated Effort:** Small

---

### [Priority: Low] Add Comments for Complex Navigation Logic

**Issue:** The entity navigation with history (Entity.lean lines 146-182) and attribute refresh logic lack explanatory comments.

**Location:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean` (lines 146-182)
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Attribute.lean` (lines 105-113)

**Action Required:** Add comments explaining the navigation flow and when refresh is triggered.

**Estimated Effort:** Small

---

### [Priority: Low] Clean Up Unused pure () Statements

**Issue:** Several for loops have `| none => pure ()` branches that do nothing. In a do block, this is unnecessary.

**Location:**
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Entity.lean` (line 69)
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Attribute.lean` (lines 64, 99)
- `/Users/Shared/Projects/lean-workspace/apps/lighthouse/Lighthouse/UI/Views/Transaction.lean` (line 94)

**Action Required:** Remove the unnecessary `| none => pure ()` branches or use `if let` pattern.

**Estimated Effort:** Small

---

## Summary

### High Priority Items
1. Full Datalog Query Support - Major feature gap
2. Pull Pattern Display - Improves core use case
3. Comprehensive Test Suite - Quality assurance gap
4. Extract Duplicated Code - Code smell
5. Fix Scroll Offset Bug - Usability issue

### Quick Wins (Small Effort, High Impact)
1. Fix scroll offset for down navigation
2. Add scrollbar indicators
3. Use TextInput widget for query
4. Remove unused variables
5. Add help screen

### Technical Debt
- Duplicated formatting functions across views
- Manual widget rendering instead of using Terminus widgets
- O(n^2) entity deduplication
- Inconsistent error handling patterns

### Future Vision
Transform Lighthouse from a basic browser into a comprehensive database debugging environment with:
- Full query language support
- Visual schema exploration
- Export/import capabilities
- Bookmarks and session management
- Statistical analysis dashboard
