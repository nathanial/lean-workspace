# Implement File Upload System

## Summary

Add file upload capability for images (gallery), attachments (notes, cards), and recipe images. This is a foundational feature needed by multiple sections.

## Current State

- No file upload support
- No multipart form handling
- No file storage system
- Static files served but not user uploads

## Requirements

### File Storage

Store uploaded files on disk:

```
data/
  uploads/
    {user_id}/
      {uuid}_{original_name}
```

### Data Model

```lean
-- File metadata (Models.lean)
def fileFilename : LedgerAttribute := ⟨":file/filename", .string, .one⟩
def fileOriginalName : LedgerAttribute := ⟨":file/original-name", .string, .one⟩
def fileMimeType : LedgerAttribute := ⟨":file/mime-type", .string, .one⟩
def fileSize : LedgerAttribute := ⟨":file/size", .nat, .one⟩
def fileUploadedAt : LedgerAttribute := ⟨":file/uploaded-at", .nat, .one⟩
def fileUser : LedgerAttribute := ⟨":file/user", .ref, .one⟩

structure DbFile where
  id : Nat
  filename : String         -- UUID-based stored filename
  originalName : String     -- Original upload name
  mimeType : String
  size : Nat
  uploadedAt : Nat
  user : EntityId
  deriving Repr, BEq
```

### Loom/Citadel Multipart Support

May need to extend Citadel to handle multipart/form-data:

```lean
-- Citadel/Multipart.lean

structure UploadedFile where
  fieldName : String
  filename : String
  contentType : String
  contents : ByteArray
  deriving Repr

def parseMultipart (contentType : String) (body : ByteArray) : IO (List UploadedFile) := do
  -- Parse boundary from Content-Type
  let boundary := extractBoundary contentType
  -- Split body by boundary
  -- Parse each part's headers and content
  ...
```

### Upload Routes

```
POST /upload                      → Generic file upload
GET  /uploads/:filename           → Serve uploaded file
DELETE /upload/:id                → Delete file
```

### Upload Actions

```lean
-- Actions/Upload.lean

def upload : ActionM Unit := do
  requireAuth
  let userId ← currentUserEntityId

  -- Get uploaded file from multipart form
  let file ← uploadedFile "file"

  -- Validate
  if file.contents.size > maxFileSize then
    return badRequest "File too large (max 10MB)"

  if !allowedMimeTypes.contains file.contentType then
    return badRequest "File type not allowed"

  -- Generate unique filename
  let uuid ← generateUUID
  let storedName := s!"{uuid}_{sanitizeFilename file.filename}"

  -- Save to disk
  let uploadDir := s!"data/uploads/{userId}"
  IO.FS.createDirAll uploadDir
  IO.FS.writeBinFile (uploadDir / storedName) file.contents

  -- Save metadata to database
  let fileEntity ← ctx.db.transact [
    .tempid "file" |>.add ":file/filename" (.string storedName)
    .tempid "file" |>.add ":file/original-name" (.string file.filename)
    .tempid "file" |>.add ":file/mime-type" (.string file.contentType)
    .tempid "file" |>.add ":file/size" (.nat file.contents.size)
    .tempid "file" |>.add ":file/uploaded-at" (.nat now)
    .tempid "file" |>.add ":file/user" (.ref userId)
  ]

  -- Return file metadata as JSON
  respondJson { id := fileEntity.id, url := s!"/uploads/{storedName}" }

def serveFile (filename : String) : ActionM Unit := do
  -- Validate filename (no path traversal)
  if filename.containsSubstr ".." || filename.containsSubstr "/" then
    return notFound

  -- Find file metadata
  let file ← findFileByName ctx.db filename
  match file with
  | none => return notFound
  | some f =>
    -- Check user owns file or file is public
    let userId ← currentUserEntityId
    if f.user != userId then
      return forbidden

    -- Serve file
    let path := s!"data/uploads/{f.user}/{filename}"
    let contents ← IO.FS.readBinFile path
    respondWithFile f.originalName f.mimeType contents

def deleteFile (fileId : Nat) : ActionM Unit := do
  requireAuth
  let userId ← currentUserEntityId

  let file ← getFile ctx.db (EntityId.ofNat fileId)
  match file with
  | none => return notFound
  | some f =>
    if f.user != userId then
      return forbidden

    -- Delete from disk
    IO.FS.removeFile s!"data/uploads/{f.user}/{f.filename}"

    -- Delete from database
    ctx.db.transact [.retract (EntityId.ofNat fileId)]

    respondJson { success := true }
```

### Configuration

```lean
def maxFileSize : Nat := 10 * 1024 * 1024  -- 10MB

def allowedMimeTypes : List String := [
  "image/jpeg",
  "image/png",
  "image/gif",
  "image/webp",
  "application/pdf",
  "text/plain",
  "text/markdown"
]
```

### HTMX Upload Component

```lean
def fileUpload (fieldName : String) : HtmlM Unit := do
  div [class "file-upload"] do
    input [
      type "file",
      name fieldName,
      hxPost "/upload",
      hxTrigger "change",
      hxTarget "#upload-result",
      hxEncoding "multipart/form-data"
    ]
    div [id "upload-result"] do pure ()
    div [class "upload-progress", style "display:none"] do
      div [class "progress-bar"] do pure ()
```

### Integration Examples

```lean
-- Kanban card with attachment
def cardWithAttachment (card : DbCard) : HtmlM Unit := do
  div [class "card"] do
    -- ... card content
    div [class "attachments"] do
      for file in card.attachments do
        a [href s!"/uploads/{file.filename}"] do
          text file.originalName

-- Gallery image upload
def galleryUploadForm : HtmlM Unit := do
  form [action "/gallery/upload", method "post", enctype "multipart/form-data"] do
    csrfToken
    input [type "file", name "image", accept "image/*", multiple]
    input [type "text", name "caption", placeholder "Caption"]
    button [type "submit"] do text "Upload"
```

## Acceptance Criteria

- [ ] Multipart form parsing in Citadel
- [ ] File upload endpoint with validation
- [ ] Size limit enforcement (10MB default)
- [ ] MIME type validation
- [ ] Secure filename handling (no path traversal)
- [ ] User-scoped file storage
- [ ] File metadata in database
- [ ] Serve uploaded files with correct headers
- [ ] Delete files (disk + database)
- [ ] HTMX-compatible upload component

## Technical Notes

- Multipart parsing is complex - may use existing library
- UUID generation needed for unique filenames
- Consider virus scanning for uploads (future)
- CDN/S3 storage for production (future)
- Image resizing for thumbnails (future)

## Priority

High - Blocks Gallery, Recipe images, Attachments

## Estimate

Large - Multipart parsing + storage + security
