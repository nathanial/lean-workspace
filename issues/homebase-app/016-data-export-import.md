# Data Export and Import

## Summary

Allow users to export their data in standard formats (JSON, CSV) and import data from exports or other sources.

## Current State

- No data export functionality
- No data import capability
- Users cannot backup their data
- No migration path from other tools

## Requirements

### Export Formats

1. **JSON Export**: Complete data export
2. **CSV Export**: Tabular data (per section)
3. **Markdown Export**: Human-readable notes/content

### Routes

```
GET  /export                      → Export options page
GET  /export/all                  → Full JSON export
GET  /export/kanban               → Kanban JSON export
GET  /export/kanban/csv           → Kanban CSV export
GET  /export/notes                → Notes JSON export
GET  /export/notes/markdown       → Notes as Markdown files
POST /import                      → Import data (upload)
GET  /import                      → Import form
```

### Export Actions

```lean
-- Actions/Export.lean

def exportAll : ActionM Unit := do
  requireAuth
  let userId ← currentUserEntityId
  let data ← gatherAllUserData ctx.db userId
  let json := toJson data
  respondWithDownload "homebase-export.json" "application/json" json

def exportKanban : ActionM Unit := do
  requireAuth
  let userId ← currentUserEntityId
  let columns ← getColumns ctx.db userId
  let data := {
    exportedAt := now
    version := "1.0"
    columns := columns.map fun col => {
      name := col.name
      order := col.order
      cards := col.cards.map fun card => {
        title := card.title
        description := card.description
        labels := card.labels
        order := card.order
      }
    }
  }
  respondWithDownload "kanban-export.json" "application/json" (toJson data)

def exportKanbanCsv : ActionM Unit := do
  requireAuth
  let cards ← getAllCardsWithColumns ctx.db userId
  let csv := toCsv cards
  respondWithDownload "kanban-cards.csv" "text/csv" csv

def exportNotesMarkdown : ActionM Unit := do
  requireAuth
  -- Create zip file with markdown files
  let notes ← getAllNotes ctx.db userId
  let zip ← createNotesZip notes
  respondWithDownload "notes-export.zip" "application/zip" zip
```

### Export Data Structures

```lean
structure KanbanExport where
  exportedAt : Nat
  version : String
  columns : List ColumnExport
  deriving ToJson, FromJson

structure ColumnExport where
  name : String
  order : Nat
  cards : List CardExport
  deriving ToJson, FromJson

structure CardExport where
  title : String
  description : String
  labels : String
  order : Nat
  deriving ToJson, FromJson

structure FullExport where
  exportedAt : Nat
  version : String
  user : UserExport
  kanban : KanbanExport
  notes : List NoteExport
  -- Add other sections as implemented
  deriving ToJson, FromJson
```

### Import Actions

```lean
-- Actions/Import.lean

def importForm : ActionM Unit := do
  requireAuth
  render Views.Import.form

def importData : ActionM Unit := do
  requireAuth
  let file ← uploadedFile "file"
  let format ← param "format"  -- "json", "csv", "trello", etc.

  match format with
  | "json" => importJson file.contents
  | "trello" => importTrello file.contents
  | "csv" => importCsv file.contents
  | _ => flash "error" "Unknown format"

def importJson (contents : ByteArray) : ActionM Unit := do
  let json ← parseJson contents
  match fromJson? json with
  | Except.ok (data : FullExport) =>
    -- Validate and import
    importKanbanData data.kanban
    flash "success" "Data imported successfully"
  | Except.error e =>
    flash "error" s!"Invalid export file: {e}"

def importTrello (contents : ByteArray) : ActionM Unit := do
  -- Parse Trello export format
  let trelloData ← parseTrelloExport contents
  -- Convert to our format
  let kanban := convertTrelloToKanban trelloData
  importKanbanData kanban
```

### Trello Import

Support importing from Trello JSON export:

```lean
structure TrelloExport where
  name : String
  lists : List TrelloList
  cards : List TrelloCard
  deriving FromJson

structure TrelloList where
  id : String
  name : String
  pos : Float
  deriving FromJson

structure TrelloCard where
  id : String
  name : String
  desc : String
  idList : String
  pos : Float
  labels : List TrelloLabel
  deriving FromJson

def convertTrelloToKanban (trello : TrelloExport) : KanbanExport := {
  exportedAt := now
  version := "1.0"
  columns := trello.lists.map fun list => {
    name := list.name
    order := list.pos.toNat
    cards := trello.cards
      .filter (·.idList == list.id)
      .map fun card => {
        title := card.name
        description := card.desc
        labels := card.labels.map (·.name) |> String.intercalate ","
        order := card.pos.toNat
      }
  }
}
```

### Views

```lean
-- Views/Export.lean

def options : HtmlM Unit := do
  layout "Export Data" do
    h1 do text "Export Your Data"

    div [class "export-options"] do
      h2 do text "Full Export"
      p do text "Export all your data in JSON format"
      a [href "/export/all", class "btn"] do text "Export All (JSON)"

      h2 do text "Kanban Board"
      a [href "/export/kanban", class "btn"] do text "Export (JSON)"
      a [href "/export/kanban/csv", class "btn"] do text "Export (CSV)"

      h2 do text "Notes"
      a [href "/export/notes", class "btn"] do text "Export (JSON)"
      a [href "/export/notes/markdown", class "btn"] do text "Export (Markdown)"

-- Views/Import.lean

def form : HtmlM Unit := do
  layout "Import Data" do
    h1 do text "Import Data"

    form [action "/import", method "post", enctype "multipart/form-data"] do
      csrfToken

      label do text "File"
      input [type "file", name "file", accept ".json,.csv"]

      label do text "Format"
      select [name "format"] do
        option [value "json"] do text "Homebase Export (JSON)"
        option [value "trello"] do text "Trello Export (JSON)"
        option [value "csv"] do text "CSV"

      div [class "warning"] do
        text "⚠️ Import will add new items. Existing data will not be modified."

      button [type "submit"] do text "Import"
```

## Acceptance Criteria

- [ ] Full JSON export of all user data
- [ ] Section-specific exports (Kanban, Notes, etc.)
- [ ] CSV export for tabular data
- [ ] Markdown export for notes
- [ ] JSON import with validation
- [ ] Trello board import
- [ ] Import preview before committing
- [ ] Clear error messages for invalid files
- [ ] Export includes all entity data

## Technical Notes

- JSON export should use deriving ToJson/FromJson
- CSV needs escaping for special characters
- Large exports may need streaming
- Consider async export for large datasets
- Zip files for multi-file exports (Markdown notes)

## Priority

Medium - Important for data portability

## Estimate

Medium - Multiple formats + Trello conversion
