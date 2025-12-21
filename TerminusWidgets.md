# Terminus Widget Brainstorm

This document brainstorms new widgets to add to Terminus to achieve parity with [ratatui](https://ratatui.rs) and its [third-party widget ecosystem](https://ratatui.rs/showcase/third-party-widgets/).

## Current Terminus Widgets (16)

| Widget | Description |
|--------|-------------|
| Block | Container with borders and title |
| Paragraph | Multi-line styled text with alignment/wrapping |
| List | Selectable list with scrolling |
| Table | Data table with headers |
| Gauge | Horizontal progress bar |
| Tabs | Tab bar navigation |
| Sparkline | Inline mini-chart using Unicode blocks |
| BarChart | Vertical bar chart with labels |
| LineChart | Line graph with Braille rendering |
| Canvas | Free-form Braille drawing |
| TextInput | Single-line text input |
| TextArea | Multi-line text editor |
| Tree | Hierarchical tree view |
| Calendar | Monthly calendar widget |
| Scrollbar | Visual scroll position indicator |
| Popup | Centered overlay dialog |

---

## Priority 1: Core Ratatui Widgets Missing

These are built-in ratatui widgets we should add first.

### LineGauge
A thin horizontal progress bar using line/bar characters instead of block fills.

```
Progress: ━━━━━━━━━━━━━━━━░░░░░░░░░░░░░░ 50%
```

**Implementation notes:**
- Simpler than Gauge, uses `─`, `━`, `░`, `▒` characters
- Supports label positioning (left, right, inline)

### Clear
Fills an area with empty cells. Useful for layered rendering.

```lean
structure Clear where
  style : Style := default  -- Optional background color
```

**Use case:** Reset an area before redrawing, especially for popups/overlays.

---

## Priority 2: Essential Third-Party Widgets

High-value widgets from the ratatui ecosystem.

### Spinner / Throbber
Animated loading indicator using Unicode spinners.

```
⠋ Loading...
⠙ Loading...
⠹ Loading...
```

**Features:**
- Multiple spinner styles: dots (Braille), bars, arrows, bouncing
- Configurable frame rate
- Optional label text

**Reference:** [throbber-widgets-tui](https://github.com/arkbig/throbber-widgets-tui)

### BigText
Renders large pixel text using 8x8 font glyphs.

```
█▀▀▀█ █  █ █▀▀▀█
█   █ ██ █ █
█   █ █▀██ █▀▀▀
█   █ █  █ █
█▄▄▄█ █  █ █▄▄▄█
```

**Features:**
- Multiple fonts (block, slant, small)
- Pixel-level control
- Useful for headers, splash screens

**Reference:** [tui-big-text](https://github.com/joshka/tui-big-text)

### Checkbox / RadioButton
Selection controls for forms.

```
[x] Enable notifications
[ ] Dark mode
( ) Option A
(•) Option B  ← selected
```

**Features:**
- Custom symbols (ASCII, Unicode, emoji)
- Label text
- Grouped radio buttons with single selection

**Reference:** [tui-checkbox](https://github.com/Kazooki123/tui-checkbox)

### Menu
Nestable dropdown/popup menu system.

```
┌──────────────┐
│ File         │──┐
│ Edit         │  │ ┌──────────┐
│ View       ▶ │  └─│ Zoom In  │
│ Help         │    │ Zoom Out │
└──────────────┘    │ Reset    │
                    └──────────┘
```

**Features:**
- Keyboard navigation
- Submenus with arrow indicators
- Hotkey display
- Separator lines

**Reference:** [tui-menu](https://github.com/andyleiserson/tui-menu)

### PieChart
Circular/semi-circular data visualization.

```
    ▄▄████▄▄
  ▄████████████▄
 ████████████████
████░░░░████████░░   40% A
████░░░░████████░░   35% B
 ████░░░░██████░░    25% C
  ▀███░░░░███▀
    ▀▀████▀▀
```

**Features:**
- Standard and high-resolution (Braille) modes
- Legend display
- Percentage labels

**Reference:** [tui-piechart](https://github.com/ArcticOJ/tui-piechart)

### ScrollView
Scrollable container for content larger than viewport.

```lean
structure ScrollView (α : Type) where
  content : α
  offset : Nat × Nat  -- (x, y) scroll position
  viewport : Rect
```

**Features:**
- Wraps any widget
- Horizontal + vertical scrolling
- Integrates with Scrollbar

**Reference:** [tui-scrollview](https://github.com/joshka/tui-scrollview)

### Logger
Live log display with filtering and levels.

```
┌─ Logs ─────────────────────────────────┐
│ [INFO]  12:03:45 Server started        │
│ [DEBUG] 12:03:46 Connection from x.x.x │
│ [WARN]  12:03:47 Rate limit exceeded   │
│ [ERROR] 12:03:48 Database timeout      │
└────────────────────────────────────────┘
```

**Features:**
- Color-coded log levels
- Scrolling with follow mode
- Level filtering
- Timestamp display

**Reference:** [tui-logger](https://github.com/gin66/tui-logger)

---

## Priority 3: Advanced Widgets

More complex widgets for specialized use cases.

### Image
Display images in the terminal using various protocols.

**Rendering methods (by compatibility):**
1. **Halfblocks** - `▀▄` characters, works everywhere
2. **Braille** - `⠿` dots for higher resolution
3. **Sixel** - Native graphics (xterm, mlterm)
4. **Kitty** - Kitty terminal graphics protocol
5. **iTerm2** - iTerm2 inline images

**Reference:** [ratatui-image](https://github.com/benjajaja/ratatui-image)

### Pseudoterminal
Embed a terminal emulator inside a widget.

**Use cases:**
- Show command output in a pane
- Build terminal multiplexers
- Display ANSI art

**Reference:** [tui-term](https://github.com/a-kenji/tui-term)

### FileExplorer (Enhanced)
Full-featured file browser beyond the current Tree widget.

**Features:**
- Directory navigation
- File icons (Nerd Fonts)
- Size/date columns
- Hidden file toggle
- Multi-selection
- Preview pane

**Reference:** [ratatui-explorer](https://github.com/tatounee/ratatui-explorer)

### CodeEditor
Syntax-highlighted code editing.

**Features:**
- Tree-sitter integration for syntax highlighting
- Line numbers
- Current line highlight
- Bracket matching
- Multiple cursors (stretch goal)

**Reference:** [ratatui-code-editor](https://github.com/snobee/ratatui-code-editor)

### NodeGraph
Visualize node-based graphs/flowcharts.

```
┌───────┐     ┌───────┐
│ Input │────▶│ Process│────▶┌───────┐
└───────┘     └───────┘      │Output │
                  │          └───────┘
                  ▼
             ┌───────┐
             │ Log   │
             └───────┘
```

**Features:**
- Nodes with ports
- Directed edges
- Panning/zooming
- Selection

**Reference:** [tui-nodes](https://github.com/Philipp-M/tui-nodes)

### Dialog
Modal dialog with buttons.

```
┌── Confirm ──────────────────┐
│                             │
│  Are you sure you want to   │
│  delete this file?          │
│                             │
│      [ Cancel ]  [ OK ]     │
└─────────────────────────────┘
```

**Features:**
- Title bar
- Message content (text or widget)
- Button row with keyboard navigation
- Focus trap

**Reference:** [tui-dialog](https://github.com/preiter93/tui-dialog)

### Prompt
Interactive input prompts for CLIs.

**Types:**
- Text input with validation
- Password (masked input)
- Select (single choice from list)
- Multi-select (checkboxes)
- Confirm (yes/no)

**Reference:** [tui-prompts](https://github.com/joshka/tui-prompts)

---

## Priority 4: Visual Effects & Polish

Decorative and enhancement widgets.

### StatusBar
Bottom status bar with sections.

```
 NORMAL │ main.lean │ Ln 42, Col 15 │ UTF-8 │ 4 spaces │ Lean
```

**Features:**
- Left/center/right alignment
- Separator characters
- Mode indicator (vim-style)

### Breadcrumb
Navigation path display.

```
Home > Documents > Projects > terminus
```

### ProgressBar (Multi-segment)
Progress bar with multiple colored segments.

```
████████░░░░░░░░░░░░  Download: 40%
▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒░░░░  Upload/Download/Pending
```

### Tooltip
Floating hint text on hover/focus.

### Toast
Temporary notification that auto-dismisses.

### Rain / Matrix Effect
Decorative falling character animation.

**Reference:** [tui-rain](https://github.com/OkiMusix05/tui-rain)

### SplashScreen
Full-screen image/text for app startup.

---

## Priority 5: Specialized Widgets

Niche but potentially useful.

### DataGrid
Excel-like grid with editable cells.

**Features:**
- Column resizing
- Cell editing
- Sorting
- Filtering
- Frozen rows/columns

### Timeline
Horizontal timeline visualization.

```
──●──────●──────●──────●──────●──▶
  v1.0   v1.1   v1.2   v2.0   v2.1
```

### Diff
Side-by-side or unified diff display.

```
- old line
+ new line
  unchanged
```

### Kanban
Kanban board with draggable cards.

```
┌─ Todo ──┐ ┌─ Doing ─┐ ┌─ Done ──┐
│ Task 1  │ │ Task 3  │ │ Task 5  │
│ Task 2  │ │         │ │ Task 6  │
│         │ │         │ │ Task 7  │
└─────────┘ └─────────┘ └─────────┘
```

### HexEditor
Hex dump with editing.

```
00000000: 4865 6c6c 6f20 576f 726c 6421 0a00 0000  Hello World!....
```

### Markdown
Render markdown with styling.

**Features:**
- Headers, bold, italic
- Code blocks
- Lists
- Links (displayed, not clickable)

### Form
Container for grouped input widgets.

```
┌─ User Details ────────────────┐
│ Name:  [________________]     │
│ Email: [________________]     │
│ Age:   [__]                   │
│ [x] Subscribe to newsletter   │
│                               │
│    [ Cancel ]  [ Submit ]     │
└───────────────────────────────┘
```

### ColorPicker
Color selection widget.

```
┌─ Pick Color ─┐
│ ████████████ │
│ R: [255]     │
│ G: [128]     │
│ B: [64 ]     │
│ #FF8040      │
└──────────────┘
```

### VimEditor
Full vim-inspired text editor widget.

**Reference:** [edtui](https://github.com/preiter93/edtui)

---

## Implementation Roadmap Suggestion

### Phase 1: Core Essentials
1. LineGauge
2. Clear
3. Spinner
4. Checkbox/RadioButton
5. Menu

### Phase 2: Interactive Widgets
6. Dialog (enhance current Popup)
7. ScrollView
8. BigText
9. Logger

### Phase 3: Data Visualization
10. PieChart
11. NodeGraph
12. Timeline

### Phase 4: Advanced Input
13. CodeEditor (syntax highlighting)
14. Prompt system
15. Form

### Phase 5: Rich Media
16. Image (halfblocks first, then protocols)
17. Pseudoterminal
18. Markdown renderer

---

## Sources

- [Ratatui Built-in Widgets](https://ratatui.rs/showcase/widgets/)
- [Ratatui Third-Party Widgets](https://ratatui.rs/showcase/third-party-widgets/)
- [Awesome Ratatui](https://github.com/ratatui/awesome-ratatui)
- [rat-widget](https://github.com/thscharler/rat-widget) - Comprehensive widget suite
