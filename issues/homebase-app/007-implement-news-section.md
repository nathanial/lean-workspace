# Implement News Section

## Summary

The News section is currently a placeholder stub. Implement a personal news feed/bookmarking feature for saving and organizing interesting links and articles.

## Current State

- Route exists: `GET /news`
- Action: `News.index` only checks login and renders placeholder
- View: Shows "News - Coming soon!" with emoji
- No data model defined

## Requirements

### Data Model (Models.lean)

```lean
-- News/bookmark attributes
def newsItemTitle : LedgerAttribute := ...
def newsItemUrl : LedgerAttribute := ...
def newsItemDescription : LedgerAttribute := ...
def newsItemSource : LedgerAttribute := ...
def newsItemDate : LedgerAttribute := ...
def newsItemRead : LedgerAttribute := ...        -- bool
def newsItemFavorite : LedgerAttribute := ...    -- bool
def newsItemTags : LedgerAttribute := ...        -- cardinality many

structure DbNewsItem where
  id : Nat
  title : String
  url : String
  description : String
  source : String         -- domain or custom name
  date : Nat              -- added date
  read : Bool
  favorite : Bool
  tags : List String
  deriving Repr, BEq
```

### Routes to Add

```
GET  /news                        → Feed view (unread first)
GET  /news/add                    → Add item form
POST /news/item                   → Create item
GET  /news/item/:id               → View item details
PUT  /news/item/:id               → Update item
DELETE /news/item/:id             → Delete item
POST /news/item/:id/read          → Mark as read (HTMX)
POST /news/item/:id/favorite      → Toggle favorite (HTMX)
GET  /news/favorites              → Favorite items only
GET  /news/archive                → All read items
GET  /news/tag/:tag               → Items by tag
GET  /news/search?q=              → Search items
```

### Actions (Actions/News.lean)

- `index`: Feed view with unread items first
- `addForm`: Show add item form
- `createItem`: Create new news item
- `showItem`: Display item details
- `updateItem`: Update item metadata
- `deleteItem`: Delete item
- `markRead`: Toggle read status (HTMX partial)
- `toggleFavorite`: Toggle favorite status (HTMX partial)
- `favorites`: Show only favorited items
- `archive`: Show all read items
- `byTag`: Filter by tag
- `search`: Search title/description

### Views (Views/News.lean)

- Feed list:
  - Item card with title, source, date
  - Read/unread indicator
  - Favorite star
  - Tag pills
  - Open link button
- Add item form:
  - URL input (auto-fetch title/description)
  - Title override
  - Description
  - Tags
- Sidebar:
  - Unread count
  - Favorites link
  - Archive link
  - Tag list with counts
- Item detail modal

### Features

- URL auto-fetch metadata (optional - requires HTTP client)
- Keyboard shortcuts (j/k navigation, m=mark read, s=star)
- Bulk actions (mark all read)
- Import from browser bookmarks (optional)

## Acceptance Criteria

- [ ] User can add news items/bookmarks
- [ ] Items have title, URL, description, source, tags
- [ ] Read/unread status tracking
- [ ] Favorite/star functionality
- [ ] Unread items shown first
- [ ] Tag filtering and search
- [ ] Quick mark-as-read (HTMX)
- [ ] Archive view for read items
- [ ] Audit logging for operations

## Technical Notes

- URL metadata fetching would use wisp (HTTP client)
- Extract domain from URL for source field
- Consider RSS feed integration (future)
- Keyboard shortcuts via JavaScript

## Priority

Medium - Personal knowledge management feature

## Estimate

Medium - Standard CRUD + read/favorite states
