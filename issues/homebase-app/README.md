# Homebase App Issues

This directory contains feature requests, bug fixes, and improvements for the homebase-app project.

## Overview

The homebase-app is a personal dashboard application built with the Lean 4 web stack (Loom, Citadel, Scribe, Ledger). Currently, only the Kanban board and authentication are fully implemented. The remaining 7 sections are stubbed out.

## Issue Categories

### Section Implementations (High Priority)

These issues implement the 7 stubbed dashboard sections:

| Issue | Section | Description | Estimate |
|-------|---------|-------------|----------|
| [001](001-implement-chat-section.md) | Chat | Real-time chat/messaging | Large |
| [002](002-implement-notebook-section.md) | Notebook | Note-taking with tags | Large |
| [003](003-implement-time-tracking-section.md) | Time | Time tracking & reports | Large |
| [004](004-implement-health-tracker-section.md) | Health | Crohn's disease tracker | Large |
| [005](005-implement-recipes-section.md) | Recipes | Recipe management | Medium |
| [006](006-implement-gallery-section.md) | Gallery | Photo gallery | Large |
| [007](007-implement-news-section.md) | News | Bookmarks/read later | Medium |

### Security & Infrastructure (High Priority)

| Issue | Title | Description | Estimate |
|-------|-------|-------------|----------|
| [008](008-production-password-hashing.md) | Password Hashing | Upgrade to Argon2/bcrypt | Medium |
| [009](009-input-validation-sanitization.md) | Input Validation | Add comprehensive validation | Medium |
| [010](010-user-data-isolation.md) | User Data Isolation | Scope data per user | Large |
| [021](021-rate-limiting.md) | Rate Limiting | Protect against abuse | Small |
| [022](022-csrf-improvements.md) | CSRF Improvements | Strengthen CSRF protection | Small |

### Configuration & Deployment (Medium Priority)

| Issue | Title | Description | Estimate |
|-------|-------|-------------|----------|
| [011](011-environment-configuration.md) | Environment Config | Env-based configuration | Small |
| [020](020-docker-deployment.md) | Docker Deployment | Containerization | Medium |

### Feature Enhancements (Medium Priority)

| Issue | Title | Description | Estimate |
|-------|-------|-------------|----------|
| [012](012-user-profile-settings.md) | User Profile | Settings page | Medium |
| [013](013-global-search.md) | Global Search | Cross-section search | Medium |
| [016](016-data-export-import.md) | Export/Import | Data portability | Medium |
| [017](017-file-upload-system.md) | File Uploads | Upload infrastructure | Large |
| [026](026-home-dashboard-widgets.md) | Dashboard Widgets | Enhanced home page | Medium |

### Testing (High Priority)

| Issue | Title | Description | Estimate |
|-------|-------|-------------|----------|
| [018](018-test-coverage-auth.md) | Auth Tests | Authentication test suite | Medium |
| [019](019-comprehensive-test-suite.md) | Test Suite | Full test coverage | Large |

### UX Improvements (Low Priority)

| Issue | Title | Description | Estimate |
|-------|-------|-------------|----------|
| [014](014-dark-mode-themes.md) | Dark Mode | Theme support | Medium |
| [015](015-time-travel-ui.md) | Time Travel | Expose Ledger history | Medium |
| [023](023-keyboard-shortcuts.md) | Keyboard Shortcuts | Power user shortcuts | Small |
| [024](024-mobile-responsive.md) | Mobile Responsive | Responsive design | Medium |
| [025](025-notifications-alerts.md) | Notifications | In-app notifications | Medium |

## Current State

### Implemented (Working)

- **Authentication**: Registration, login, logout, sessions
- **Kanban Board**: Full CRUD for columns and cards, drag-and-drop, SSE, audit logging
- **Layout**: Sidebar navigation, navbar, flash messages
- **Database**: Ledger-based persistence with JSONL journal

### Stubbed (Placeholder Only)

- Chat
- Notebook
- Time Tracking
- Health Tracker
- Recipes
- Gallery
- News

## Recommended Implementation Order

### Phase 1: Security & Foundation
1. [008](008-production-password-hashing.md) - Critical security fix
2. [010](010-user-data-isolation.md) - Required for multi-user
3. [009](009-input-validation-sanitization.md) - Security hardening
4. [018](018-test-coverage-auth.md) - Test critical auth paths

### Phase 2: Core Sections
5. [002](002-implement-notebook-section.md) - Most universally useful
6. [003](003-implement-time-tracking-section.md) - Productivity feature
7. [017](017-file-upload-system.md) - Blocks gallery/recipes

### Phase 3: Remaining Sections
8. [005](005-implement-recipes-section.md)
9. [007](007-implement-news-section.md)
10. [004](004-implement-health-tracker-section.md)
11. [006](006-implement-gallery-section.md) - Requires file uploads
12. [001](001-implement-chat-section.md)

### Phase 4: Polish
13. [013](013-global-search.md)
14. [012](012-user-profile-settings.md)
15. [026](026-home-dashboard-widgets.md)
16. [024](024-mobile-responsive.md)
17. [014](014-dark-mode-themes.md)

### Phase 5: Deployment
18. [011](011-environment-configuration.md)
19. [020](020-docker-deployment.md)
20. [019](019-comprehensive-test-suite.md)

## Contributing

When working on an issue:

1. Create a feature branch: `git checkout -b feature/issue-NNN-description`
2. Implement the feature following existing patterns
3. Add tests using Crucible framework
4. Update CLAUDE.md if architecture changes
5. Submit PR referencing the issue

## Tech Stack Reference

- **Loom**: Rails-like web framework
- **Citadel**: HTTP/1.1 server
- **Scribe**: Type-safe HTML builder
- **Ledger**: Fact-based database (Datomic-like)
- **Chronicle**: Structured logging
- **Crucible**: Test framework
