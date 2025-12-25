# Add Keyboard Shortcuts

## Summary

Add keyboard shortcuts for common actions to improve power-user experience.

## Current State

- No keyboard shortcuts
- All interactions require mouse clicks
- HTMX provides some progressive enhancement

## Requirements

### Global Shortcuts

| Shortcut | Action |
|----------|--------|
| `g h` | Go to Home |
| `g k` | Go to Kanban |
| `g n` | Go to Notebook |
| `g t` | Go to Time |
| `g c` | Go to Chat |
| `/` | Focus search box |
| `?` | Show keyboard shortcuts help |
| `Escape` | Close modal/cancel |

### Kanban Shortcuts

| Shortcut | Action |
|----------|--------|
| `n` | New card in current column |
| `N` | New column |
| `e` | Edit selected card |
| `d` | Delete selected card (with confirm) |
| `j` / `↓` | Select next card |
| `k` / `↑` | Select previous card |
| `h` / `←` | Move to previous column |
| `l` / `→` | Move to next column |
| `Enter` | Open selected card |
| `m` | Move card (opens column picker) |

### Notebook Shortcuts (when implemented)

| Shortcut | Action |
|----------|--------|
| `n` | New note |
| `e` | Edit selected note |
| `d` | Delete selected note |
| `Ctrl+S` | Save current note |
| `Ctrl+B` | Bold (in editor) |
| `Ctrl+I` | Italic (in editor) |

### Implementation

```javascript
// public/js/shortcuts.js

class KeyboardShortcuts {
  constructor() {
    this.sequence = '';
    this.sequenceTimeout = null;
    this.shortcuts = new Map();
    this.active = true;

    document.addEventListener('keydown', this.handleKeydown.bind(this));
  }

  register(keys, action, description) {
    this.shortcuts.set(keys, { action, description });
  }

  handleKeydown(event) {
    // Skip if in input/textarea
    if (this.isTyping(event.target)) return;
    if (!this.active) return;

    const key = this.getKeyString(event);

    // Handle sequence (e.g., "g h")
    if (this.sequence) {
      clearTimeout(this.sequenceTimeout);
      const fullSequence = this.sequence + ' ' + key;

      if (this.shortcuts.has(fullSequence)) {
        event.preventDefault();
        this.shortcuts.get(fullSequence).action();
        this.sequence = '';
        return;
      }

      this.sequence = '';
    }

    // Check for sequence start
    if (key === 'g') {
      this.sequence = 'g';
      this.sequenceTimeout = setTimeout(() => {
        this.sequence = '';
      }, 1000);
      return;
    }

    // Single key shortcuts
    if (this.shortcuts.has(key)) {
      event.preventDefault();
      this.shortcuts.get(key).action();
    }
  }

  isTyping(element) {
    const tag = element.tagName.toLowerCase();
    return tag === 'input' || tag === 'textarea' ||
           element.isContentEditable;
  }

  getKeyString(event) {
    let key = event.key;
    if (event.ctrlKey) key = 'Ctrl+' + key;
    if (event.metaKey) key = 'Cmd+' + key;
    if (event.altKey) key = 'Alt+' + key;
    return key;
  }

  showHelp() {
    const modal = document.createElement('div');
    modal.className = 'shortcuts-modal';
    modal.innerHTML = `
      <div class="shortcuts-content">
        <h2>Keyboard Shortcuts</h2>
        <button class="close" onclick="this.parentElement.parentElement.remove()">×</button>
        <table>
          ${Array.from(this.shortcuts.entries())
            .map(([key, {description}]) =>
              `<tr><td><kbd>${key}</kbd></td><td>${description}</td></tr>`)
            .join('')}
        </table>
      </div>
    `;
    document.body.appendChild(modal);
  }

  disable() { this.active = false; }
  enable() { this.active = true; }
}

// Initialize
const shortcuts = new KeyboardShortcuts();

// Global shortcuts
shortcuts.register('g h', () => window.location.href = '/', 'Go to Home');
shortcuts.register('g k', () => window.location.href = '/kanban', 'Go to Kanban');
shortcuts.register('g n', () => window.location.href = '/notebook', 'Go to Notebook');
shortcuts.register('g t', () => window.location.href = '/time', 'Go to Time');
shortcuts.register('/', () => document.querySelector('.search-input')?.focus(), 'Focus search');
shortcuts.register('?', () => shortcuts.showHelp(), 'Show shortcuts');
shortcuts.register('Escape', () => {
  document.querySelector('.modal.open')?.classList.remove('open');
}, 'Close modal');
```

### Kanban-Specific

```javascript
// public/js/kanban-shortcuts.js

if (window.location.pathname === '/kanban') {
  let selectedCard = null;

  shortcuts.register('n', () => {
    const col = document.querySelector('.kanban-column');
    if (col) htmx.ajax('GET', `/kanban/column/${col.dataset.id}/add-card-form`, col);
  }, 'New card');

  shortcuts.register('N', () => {
    htmx.ajax('GET', '/kanban/add-column-form', '#column-form-container');
  }, 'New column');

  shortcuts.register('j', () => selectNextCard(), 'Next card');
  shortcuts.register('k', () => selectPrevCard(), 'Previous card');
  shortcuts.register('e', () => {
    if (selectedCard) {
      htmx.ajax('GET', `/kanban/card/${selectedCard.dataset.id}/edit`, '#modal');
    }
  }, 'Edit card');

  function selectNextCard() {
    const cards = Array.from(document.querySelectorAll('.kanban-card'));
    const idx = cards.indexOf(selectedCard);
    if (idx < cards.length - 1) {
      selectCard(cards[idx + 1]);
    }
  }

  function selectCard(card) {
    if (selectedCard) selectedCard.classList.remove('selected');
    selectedCard = card;
    card.classList.add('selected');
    card.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }
}
```

### Visual Feedback

```css
/* Keyboard selection styling */
.kanban-card.selected {
  outline: 2px solid var(--accent-primary);
  outline-offset: 2px;
}

/* Shortcut hints on hover (optional) */
[data-shortcut]::after {
  content: attr(data-shortcut);
  position: absolute;
  right: 8px;
  top: 8px;
  font-size: 10px;
  color: var(--text-muted);
  background: var(--bg-secondary);
  padding: 2px 4px;
  border-radius: 2px;
}

/* Shortcuts modal */
.shortcuts-modal {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.shortcuts-content {
  background: var(--bg-primary);
  padding: 24px;
  border-radius: 8px;
  max-width: 500px;
  max-height: 80vh;
  overflow-y: auto;
}

.shortcuts-content kbd {
  background: var(--bg-tertiary);
  padding: 2px 6px;
  border-radius: 3px;
  font-family: monospace;
  border: 1px solid var(--border-color);
}
```

## Acceptance Criteria

- [ ] Global navigation shortcuts (g + key)
- [ ] Search focus with `/`
- [ ] Help modal with `?`
- [ ] Kanban card navigation (j/k)
- [ ] Kanban card actions (n, e, d)
- [ ] Escape closes modals
- [ ] Visual selection indicator
- [ ] Shortcuts disabled in text inputs
- [ ] Shortcuts documented in help modal

## Technical Notes

- Disable shortcuts when typing in inputs
- Vim-style navigation (h/j/k/l)
- Sequence shortcuts with timeout
- Consider user preference to disable
- Test with screen readers

## Priority

Low - Nice to have for power users

## Estimate

Small - JavaScript implementation
