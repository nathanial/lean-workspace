# Implement Notebook Section

## Summary

The Notebook section is currently a placeholder stub. Implement a note-taking feature with rich text support, tagging, and organization.

## Current State

- Route exists: `GET /notebook`
- Action: `Notebook.index` only checks login and renders placeholder
- View: Shows "Notebook - Coming soon!" with emoji
- No data model defined

## Requirements

### Data Model (Models.lean)

```lean
-- Notebook attributes
def noteTitle : LedgerAttribute := ...
def noteContent : LedgerAttribute := ...
def noteTags : LedgerAttribute := ...  -- cardinality many
def noteCreatedAt : LedgerAttribute := ...
def noteUpdatedAt : LedgerAttribute := ...
def notebookName : LedgerAttribute := ...
def notebookNotes : LedgerAttribute := ... -- ref many

structure DbNote where
  id : Nat
  title : String
  content : String
  tags : List String
  createdAt : Nat
  updatedAt : Nat
  notebook : Option EntityId
  deriving Repr, BEq

structure DbNotebook where
  id : Nat
  name : String
  deriving Repr, BEq
```

### Routes to Add

```
GET  /notebook                    → List notebooks/notes
GET  /notebook/new                → New note form
POST /notebook/note               → Create note
GET  /notebook/note/:id           → View note
GET  /notebook/note/:id/edit      → Edit note form
PUT  /notebook/note/:id           → Update note
DELETE /notebook/note/:id         → Delete note
GET  /notebook/tag/:tag           → Notes by tag
GET  /notebook/search?q=          → Full-text search
POST /notebook/folder             → Create notebook/folder
```

### Actions (Actions/Notebook.lean)

- `index`: List all notes with sidebar of notebooks
- `newNote`: Show note creation form
- `createNote`: Create new note
- `showNote`: Display note content
- `editNote`: Show edit form
- `updateNote`: Update note content/title/tags
- `deleteNote`: Delete with confirmation
- `byTag`: Filter notes by tag
- `search`: Full-text search across notes
- `createNotebook`: Create organizational folder

### Views (Views/Notebook.lean)

- Notebook/folder sidebar
- Note list with title/preview/date
- Note editor with title and content fields
- Tag input with autocomplete
- Markdown preview toggle
- Search results with highlighting

### Editor Features

- Textarea with monospace font
- Markdown rendering for preview
- Tag pills with click-to-filter
- Auto-save indicator (optional)
- Word/character count

## Acceptance Criteria

- [ ] User can create, edit, and delete notes
- [ ] Notes support title, content, and tags
- [ ] Notes organized into notebooks/folders
- [ ] Tags are clickable to filter
- [ ] Search finds notes by title and content
- [ ] Timestamps show created/updated dates
- [ ] HTMX for smooth editing experience
- [ ] Audit logging for note operations

## Technical Notes

- Content stored as plain text (Markdown)
- Consider client-side Markdown preview library
- Use Ledger's time-travel for note history
- Tags with cardinality many

## Priority

High - Core personal dashboard feature

## Estimate

Large - Full CRUD + search + organization
