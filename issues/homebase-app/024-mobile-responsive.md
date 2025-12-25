# Mobile Responsive Design

## Summary

Make the application fully responsive for mobile and tablet devices.

## Current State

- Desktop-focused layout
- Sidebar may not work on mobile
- Kanban board likely overflows
- No touch-friendly interactions

## Requirements

### Breakpoints

```css
/* Mobile first approach */
/* Default: Mobile (< 640px) */
/* sm: >= 640px */
/* md: >= 768px */
/* lg: >= 1024px */
/* xl: >= 1280px */

:root {
  --sidebar-width: 64px;   /* Collapsed on mobile */
  --sidebar-width-expanded: 240px;
}

@media (min-width: 768px) {
  :root {
    --sidebar-width: 240px;
  }
}
```

### Mobile Sidebar

Collapsible sidebar with hamburger menu:

```lean
def sidebar (currentPath : String) : HtmlM Unit := do
  -- Mobile toggle button (hidden on desktop)
  button [
    class "sidebar-toggle md:hidden",
    onclick "toggleSidebar()"
  ] do text "☰"

  nav [class "sidebar", id "sidebar"] do
    -- Close button for mobile
    button [
      class "sidebar-close md:hidden",
      onclick "closeSidebar()"
    ] do text "×"

    for item in sidebarItems do
      a [
        href item.path,
        class (if item.path == currentPath then "active" else "")
      ] do
        span [class "icon"] do text item.icon
        span [class "label"] do text item.label
```

```css
/* Mobile sidebar */
.sidebar {
  position: fixed;
  top: 0;
  left: -100%;
  width: 240px;
  height: 100vh;
  background: var(--sidebar-bg);
  transition: left 0.3s ease;
  z-index: 100;
}

.sidebar.open {
  left: 0;
}

/* Desktop sidebar */
@media (min-width: 768px) {
  .sidebar {
    position: sticky;
    left: 0;
  }

  .sidebar-toggle,
  .sidebar-close {
    display: none;
  }
}

/* Overlay when sidebar open on mobile */
.sidebar-overlay {
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.5);
  z-index: 99;
}

.sidebar.open ~ .sidebar-overlay {
  display: block;
}
```

### Kanban Board Mobile

Stack columns vertically or swipe horizontally:

```css
/* Mobile: Stack columns or horizontal scroll */
.kanban-board {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 16px;
}

@media (min-width: 768px) {
  .kanban-board {
    flex-direction: row;
    overflow-x: auto;
    padding: 24px;
  }
}

/* Column tabs on mobile */
.column-tabs {
  display: flex;
  overflow-x: auto;
  gap: 8px;
  padding: 8px;
  background: var(--bg-secondary);
}

@media (min-width: 768px) {
  .column-tabs {
    display: none;
  }
}

.kanban-column {
  width: 100%;
  min-width: 0;
}

@media (min-width: 768px) {
  .kanban-column {
    width: 300px;
    min-width: 300px;
    flex-shrink: 0;
  }
}
```

### Touch-Friendly Cards

```css
/* Larger touch targets */
.kanban-card {
  padding: 16px;
  min-height: 60px;
}

.kanban-card .actions button {
  width: 44px;
  height: 44px;
  font-size: 18px;
}

/* Swipe actions (optional) */
.kanban-card {
  position: relative;
  overflow: hidden;
}

.kanban-card .swipe-actions {
  position: absolute;
  right: -100px;
  top: 0;
  bottom: 0;
  width: 100px;
  display: flex;
  transition: right 0.2s;
}

.kanban-card.swiped .swipe-actions {
  right: 0;
}
```

### Forms on Mobile

```css
/* Full-width inputs on mobile */
.form-group {
  margin-bottom: 16px;
}

.form-group input,
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 12px;
  font-size: 16px;  /* Prevents iOS zoom */
}

.form-group label {
  display: block;
  margin-bottom: 8px;
}

/* Stack buttons on mobile */
.button-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

@media (min-width: 640px) {
  .button-group {
    flex-direction: row;
    justify-content: flex-end;
  }
}
```

### Modal on Mobile

```css
/* Full-screen modals on mobile */
.modal-content {
  width: 100%;
  height: 100%;
  max-width: none;
  max-height: none;
  border-radius: 0;
}

@media (min-width: 640px) {
  .modal-content {
    width: auto;
    height: auto;
    max-width: 500px;
    max-height: 80vh;
    border-radius: 8px;
  }
}

/* Bottom sheet style on mobile (optional) */
.modal-content.bottom-sheet {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  top: auto;
  max-height: 90vh;
  border-radius: 16px 16px 0 0;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from { transform: translateY(100%); }
  to { transform: translateY(0); }
}
```

### Navbar Mobile

```css
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 16px;
}

.navbar .logo {
  font-size: 18px;
}

.navbar .user-menu {
  display: none;  /* Hidden on mobile */
}

@media (min-width: 768px) {
  .navbar .user-menu {
    display: flex;
  }
}

/* Mobile user dropdown */
.navbar .mobile-menu {
  display: block;
}

@media (min-width: 768px) {
  .navbar .mobile-menu {
    display: none;
  }
}
```

### JavaScript Touch Support

```javascript
// Touch-friendly drag and drop
document.querySelectorAll('.kanban-card').forEach(card => {
  let startX, startY;

  card.addEventListener('touchstart', (e) => {
    startX = e.touches[0].clientX;
    startY = e.touches[0].clientY;
  });

  card.addEventListener('touchmove', (e) => {
    const deltaX = e.touches[0].clientX - startX;
    if (Math.abs(deltaX) > 50) {
      card.classList.add('swiped');
    }
  });

  card.addEventListener('touchend', () => {
    setTimeout(() => card.classList.remove('swiped'), 3000);
  });
});
```

## Acceptance Criteria

- [ ] Sidebar collapses on mobile
- [ ] Hamburger menu toggle
- [ ] Kanban columns stack or scroll
- [ ] Touch-friendly button sizes (44px+)
- [ ] Full-width forms on mobile
- [ ] Full-screen modals on mobile
- [ ] No horizontal scroll on content
- [ ] Readable font sizes (16px+ for inputs)
- [ ] Works on iOS and Android

## Technical Notes

- Test on actual devices, not just browser emulation
- iOS Safari has specific quirks (100vh, input zoom)
- Consider PWA manifest for home screen
- Test with slow network conditions

## Priority

Medium - Expands potential user base

## Estimate

Medium - CSS refactoring + testing
