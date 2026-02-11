# Node Editor Roadmap

This plan covers the next set of node editor capabilities for `graphics/afferent` and its demo in `graphics/afferent-demos`.

## Phase 1: Port Type System And Validation

Goal: Introduce typed ports and enforce valid graph wiring.

Scope:
- Define port and value kinds (example: `model`, `conditioning`, `latent`, `image`).
- Add compatibility checks for link creation.
- Add validation feedback for invalid existing links.
- Standardize type-based port colors.

Exit criteria:
- Invalid links cannot be created in the UI.
- Existing invalid links are visually flagged.
- Type definitions are centralized and reusable.

## Phase 2: Interactive Wiring UX

Goal: Make edge creation and editing direct and fast.

Scope:
- Click-drag from output ports to input ports to create links.
- Live preview wire while dragging.
- Reconnect by dragging wire endpoints.
- Remove edges via keybind or context action.
- Hover and selection states for ports and edges.

Exit criteria:
- Users can create, reconnect, and delete links without editing model data manually.
- Wire interactions work with panning and node drag.

## Phase 3: Navigation At Scale (Zoom + Minimap)

Goal: Keep large graphs manageable.

Scope:
- Zoom centered around cursor.
- Zoom-aware stroke and hit-test behavior.
- Minimap with viewport rectangle.
- Click/drag minimap to navigate.

Exit criteria:
- Graph remains usable beyond a single screen.
- Node and edge interaction stays accurate at multiple zoom levels.

## Phase 4: Multi-Selection And Group Moves

Goal: Improve layout editing throughput.

Scope:
- Shift/Cmd click multi-select.
- Box select on empty canvas.
- Group drag for selected nodes.
- Selection outline and count indicator.

Exit criteria:
- Multiple nodes can be selected and moved as one action.
- Single-node behavior remains unchanged.

## Phase 5: Undo/Redo Command Stack

Goal: Provide safe, reversible editing.

Scope:
- Command model for node move, add/remove link, add/remove node, property edits.
- Undo/redo stacks with merge for drag operations.
- Keyboard shortcuts (`Cmd/Ctrl+Z`, `Cmd/Ctrl+Shift+Z`).

Exit criteria:
- Core edit actions are reversible.
- Dragging a node produces one undo step after release.

## Phase 6: Node Palette And Quick Add

Goal: Remove hardcoded graph editing flow.

Scope:
- Node type registry with metadata.
- Spacebar and context-menu quick add.
- Fuzzy search and keyboard navigation.
- Spawn node at cursor or selected position.

Exit criteria:
- Users can add any registered node type from the editor UI.
- Node creation does not require code changes in the demo graph.

## Phase 7: Graph Serialization

Goal: Persist and share graphs.

Scope:
- Stable graph schema for nodes, links, positions, and node data.
- Save/load API and demo actions.
- Versioned schema field for migration support.
- Validation on load with useful error output.

Exit criteria:
- A graph can be saved and loaded with no structural loss.
- Unsupported or invalid files fail with clear errors.

## Phase 8: Execution-State Visualization

Goal: Reflect runtime pipeline execution in the graph.

Scope:
- Node status model (`idle`, `queued`, `running`, `success`, `error`).
- Visual status indicators on nodes and edges.
- Error details on failing nodes.
- Optional duration/progress metadata.

Exit criteria:
- Runtime status is visible and updates reactively.
- Failed nodes are easy to identify and inspect.

## Phase 9: Node Body Collapse/Expand

Goal: Reduce clutter while preserving rich embedded widgets.

Scope:
- Per-node collapsed state.
- Header toggle affordance.
- Preserve node body widget state across collapse transitions.
- Auto-layout adjustments for edge anchors.

Exit criteria:
- Collapsed nodes remain connectable and readable.
- Expanding restores the same editable widget state.

## Phase 10: Performance Hardening

Goal: Keep interaction smooth for large graphs.

Scope:
- Dirty-region or dirty-object redraw tracking.
- Edge batching and reduced path recomputation.
- Optional viewport culling for offscreen content.
- Profiling and benchmark scenarios in demos.

Exit criteria:
- Pan, drag, and wiring remain responsive at target graph size.
- Profiling shows clear reduction in redundant work.

## Cross-Phase Notes

- Keep node body content widget-native (`WidgetM`) so existing controls remain reusable.
- Keep editor model deterministic for serialization and undo/redo.
- Add targeted tests per phase in `graphics/afferent` plus interactive coverage in `graphics/afferent-demos`.

## Recommended Delivery Order

1. Phase 1
2. Phase 2
3. Phase 7
4. Phase 5
5. Phase 6
6. Phase 4
7. Phase 3
8. Phase 8
9. Phase 9
10. Phase 10
