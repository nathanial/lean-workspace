# Add Dark Mode and Theme Support

## Summary

Add dark mode support and theme customization. Currently, the app uses a fixed light color scheme.

## Current State

- Fixed light theme
- No user theme preference
- No CSS custom properties for theming

## Requirements

### CSS Architecture

Create a CSS custom properties system for theming:

```css
/* themes.css */

:root {
  /* Light theme (default) */
  --bg-primary: #ffffff;
  --bg-secondary: #f5f5f5;
  --bg-tertiary: #e5e5e5;

  --text-primary: #1a1a1a;
  --text-secondary: #666666;
  --text-muted: #999999;

  --accent-primary: #3b82f6;
  --accent-secondary: #60a5fa;
  --accent-hover: #2563eb;

  --border-color: #e5e5e5;
  --shadow-color: rgba(0, 0, 0, 0.1);

  --success: #22c55e;
  --warning: #f59e0b;
  --error: #ef4444;
  --info: #3b82f6;

  --sidebar-bg: #1e293b;
  --sidebar-text: #e2e8f0;
  --sidebar-hover: #334155;
}

[data-theme="dark"] {
  --bg-primary: #1a1a1a;
  --bg-secondary: #2d2d2d;
  --bg-tertiary: #3d3d3d;

  --text-primary: #f5f5f5;
  --text-secondary: #a3a3a3;
  --text-muted: #737373;

  --accent-primary: #60a5fa;
  --accent-secondary: #93c5fd;
  --accent-hover: #3b82f6;

  --border-color: #404040;
  --shadow-color: rgba(0, 0, 0, 0.3);

  --sidebar-bg: #0f172a;
  --sidebar-text: #e2e8f0;
  --sidebar-hover: #1e293b;
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    /* Same as dark theme */
  }
}
```

### Update Existing CSS

Replace hardcoded colors with CSS variables:

```css
/* Before */
body {
  background: #ffffff;
  color: #1a1a1a;
}

/* After */
body {
  background: var(--bg-primary);
  color: var(--text-primary);
}
```

### Theme Switching JavaScript

```javascript
// theme.js

function setTheme(theme) {
  if (theme === 'system') {
    document.documentElement.removeAttribute('data-theme');
    localStorage.removeItem('theme');
  } else {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);
  }
}

function initTheme() {
  const saved = localStorage.getItem('theme');
  if (saved) {
    document.documentElement.setAttribute('data-theme', saved);
  }
}

// Run immediately to prevent flash
initTheme();
```

### Layout Integration

```lean
-- Layout.lean

def layout (title : String) (content : HtmlM Unit) : HtmlM Unit := do
  doctype
  html [lang "en"] do
    head do
      -- ...
      link [rel "stylesheet", href "/css/themes.css"]
      script [] do
        -- Inline script to prevent flash of wrong theme
        rawText """
          (function() {
            var theme = localStorage.getItem('theme');
            if (theme) document.documentElement.setAttribute('data-theme', theme);
          })();
        """
    body do
      -- ...
      script [src "/js/theme.js"] do pure ()
```

### Theme Toggle Component

```lean
def themeToggle : HtmlM Unit := do
  div [class "theme-toggle"] do
    button [
      onclick "setTheme('light')",
      class "theme-btn",
      title "Light mode"
    ] do text "☀️"

    button [
      onclick "setTheme('dark')",
      class "theme-btn",
      title "Dark mode"
    ] do text "🌙"

    button [
      onclick "setTheme('system')",
      class "theme-btn",
      title "System preference"
    ] do text "💻"
```

### Server-Side Preference

Store user's preference in database:

```lean
-- On settings save
def updateTheme (userId : EntityId) (theme : String) : IO Unit := do
  -- Save to database
  db.transact [
    .add userId ":user/theme" (.string theme)
  ]

-- On page render, include preference in HTML
def getThemeAttribute (user : Option UserProfile) : String :=
  match user with
  | some u => s!"""data-theme="{u.theme}""""
  | none => ""
```

### CSS Components to Update

All existing styles need variable updates:

- [ ] Sidebar (`--sidebar-bg`, `--sidebar-text`)
- [ ] Navbar (`--bg-secondary`, `--text-primary`)
- [ ] Cards (`--bg-primary`, `--border-color`, `--shadow-color`)
- [ ] Buttons (`--accent-primary`, `--accent-hover`)
- [ ] Forms (`--bg-secondary`, `--border-color`)
- [ ] Flash messages (`--success`, `--error`, `--info`)
- [ ] Kanban board (`--bg-tertiary`, `--text-secondary`)

## Acceptance Criteria

- [ ] Light and dark themes available
- [ ] System preference detection (prefers-color-scheme)
- [ ] User can override system preference
- [ ] Theme persisted in localStorage
- [ ] Theme persisted in user preferences (when logged in)
- [ ] No flash of wrong theme on page load
- [ ] All UI components properly themed
- [ ] Accessible contrast ratios in both themes

## Technical Notes

- CSS custom properties have good browser support
- Inline script needed to prevent theme flash
- Consider high-contrast theme for accessibility
- Test all views in both themes

## Priority

Low - Nice to have, cosmetic improvement

## Estimate

Medium - CSS refactor + JavaScript + testing all views
