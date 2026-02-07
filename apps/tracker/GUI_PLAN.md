# Tracker GUI Plan (Canopy + Reactive)

## Objective
Build a desktop GUI for Tracker (invoked via `tracker -gui`) as a single executable, using Afferent Canopy widgets and `data/reactive` as the primary UI architecture.

## Decisions
- Use Canopy widgets first; avoid custom immediate-mode drawing except where Canopy has no equivalent.
- Use Reactive graph/state (`foldDyn`, `foldDynM`, `dynWidget`, trigger events) as the core update model.
- Keep all Tracker persistence behind a single effect boundary that calls `Tracker.Storage`.
- Keep CLI/TUI behavior intact; GUI remains opt-in via `-gui`.

## Implementation References
- Reactive runtime and widget execution pattern:
  - `graphics/afferent-demos/Demos/Core/Runner/Unified.lean`
  - `graphics/afferent-demos/Demos/Core/Runner/CanopyApp.lean`
- Reactive state/event patterns:
  - `graphics/afferent-demos/Demos/Reactive/Showcase/App.lean`
- Canopy reactive APIs:
  - `graphics/afferent/Afferent/Canopy/Reactive/Inputs.lean`
  - `graphics/afferent/Afferent/Canopy/Reactive/Component.lean`

## Architecture

### Runtime Layer (`Tracker.GUI.Runtime`)
- Owns Afferent window creation and frame loop.
- Creates `(ReactiveEvents, ReactiveInputs)` via `createInputs`.
- Fires frame/input events each tick (`fireClick`, `fireHover`, `fireKey`, `fireScroll`, `fireAnimationFrame`).
- Samples current render function from Reactive graph and submits Canopy draw commands.

### App Wiring Layer (`Tracker.GUI.App`)
- Builds the reactive network with `ReactiveM.run`.
- Creates trigger events for user intents and async results.
- Wires dynamic state via `foldDynM`.
- Exposes top-level `ComponentRender` and `shutdown`.

### Domain State Layer (`Tracker.GUI.Model`)
- Normalized UI model:
  - `issuesById : RBMap Nat Issue compare`
  - `issueOrder : Array Nat`
  - `selection : Option Nat`
  - `listFilter : Storage.ListFilter`
  - `query : String`
  - `editor : Option EditorState`
  - `modal : Option ModalState`
  - `toasts : Array ToastState`
  - `loading : Bool`
  - `error : Option String`
- Keep derived values pure (`visibleIssueIds`, grouped counts, blocked flags).

### Intent/Reducer Layer (`Tracker.GUI.Action`, `Tracker.GUI.Update`)
- Define typed intents:
  - `LoadRequested`, `IssuesLoaded`, `IssueSelected`, `FilterChanged`, `QueryChanged`
  - `CreateRequested`, `UpdateRequested`, `ProgressAddRequested`, `CloseRequested`, `ReopenRequested`
  - `BlockRequested`, `UnblockRequested`, `EffectFailed`, `ToastDismissed`
- `update : Model -> Action -> Model * Array Effect` (pure + effect requests).

### Effect Layer (`Tracker.GUI.Effect`)
- Executes effect requests with `Tracker.Storage` IO APIs.
- Emits success/failure actions back into reactive graph.
- No UI logic in this module.

### View Layer (`Tracker.GUI.View.*`)
- Build UI with Canopy widgets (`column'`, `row'`, `tabView`, inputs, buttons, table/list widgets, modal/toast).
- Use `dynWidget` to localize rebuilds:
  - issue list subtree
  - detail/editor subtree
  - status/footer subtree
- Keep reusable components under `Tracker.GUI.View.Components.*`.

## UI Composition Plan
- Header:
  - App title (`Tracker`), search input, quick action buttons (new issue, refresh).
- Body split:
  - Left pane: filter controls + issue list.
  - Right pane: selected issue details, metadata editor, progress timeline.
- Footer:
  - status text, key hints, transient operation feedback.
- Modals/overlays:
  - create issue, confirm destructive actions, error details.

## Data Flow
1. Runtime converts OS input to Reactive events.
2. UI widgets emit intents through trigger events.
3. Reducer updates model and requests effects.
4. Effect runner calls `Tracker.Storage` and emits result actions.
5. Model updates drive `dynWidget` subtrees and rerender.

## FRP State Boundaries
- Keep shared app/domain state in top-level `Model` dynamics:
  - issue dataset/index/order
  - current selection/filter/query
  - loading/error/operation status
  - effect request queue
- Keep ephemeral widget interaction state inside widget-local FRP networks:
  - text cursor/edit buffers while typing
  - dropdown/tab open/hover state
  - modal local visibility wiring
  - scroll offsets and hover transitions
- Lift state from widget-local to top-level only when:
  - another subtree needs it, or
  - it changes persisted/domain behavior.
- This matches existing Canopy usage patterns (`textInput`, `tabView`, `modal`, `toastManager`) where widgets own local mechanics and expose events/dynamics for parent composition.

## Performance Strategy
- Keep normalized in-memory model for active session.
- Use `dynWidget` boundaries to avoid rebuilding entire UI tree each frame.
- Keep search/filter operations over in-memory arrays/maps only.
- Batch mutation refreshes (single reload action for grouped writes where appropriate).
- Benchmark startup/open and common operations against synthetic issue counts.

## Milestones

### M1: Reactive Shell
- Add runtime loop + `createInputs` wiring.
- Replace static text shell with Canopy layout skeleton.
- Add basic focus/selection intent plumbing.
- Enforce FRP boundaries: top-level model for pane focus + shell selection, widget-local state for controls.
- Acceptance: `tracker -gui` shows stable reactive shell and handles keyboard/mouse events.

### M2: Read-Only Browser
- Startup load through effect layer.
- Issue list + detail pane bound to model.
- Search/filter intents with derived visible list.
- Acceptance: browse/select/filter works without any write operations.

### M3: Mutation Workflows
- Create/update/close/reopen/progress actions wired end-to-end.
- Success/error toasts and optimistic busy indicators.
- Acceptance: GUI mutations persist correctly and reflect immediately.

### M4: Dependencies + Polish
- Block/unblock UI and blocked-state visualization.
- Confirmation modals and keyboard shortcuts for common actions.
- Acceptance: dependency workflow matches CLI semantics.

### M5: Performance + Hardening
- Profile large datasets.
- Tighten `dynWidget` boundaries and reducer hot paths.
- Add targeted benchmarks and integration tests.
- Acceptance: responsive interaction at 2k+ issues on local dev machine.

## Testing Plan
- Unit:
  - reducer transitions (`Tracker.GUI.Update`)
  - derived filtering/search/grouping helpers
- Integration:
  - effect layer with temp tracker root
  - mutation flows and error handling
- Bench:
  - GUI startup/open with increasing journal sizes
  - list/filter/select latency at increasing issue counts
- Regression:
  - existing `apps/tracker` CLI/TUI tests remain green

## Immediate Next Tasks
1. Introduce `Tracker.GUI.Runtime` with `createInputs` and event firing.
2. Split current GUI entry into `App`, `Model`, `Action`, `Update`, `Effect`, `View` modules.
3. Implement Canopy shell view (header/body/footer) with reactive selection state.
4. Wire initial load effect (`LoadRequested -> IssuesLoaded`) and render real issue list.
