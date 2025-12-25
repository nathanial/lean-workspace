# Implement Gallery Section

## Summary

The Gallery section is currently a placeholder stub. Implement a photo gallery feature for organizing and viewing images.

## Current State

- Route exists: `GET /gallery`
- Action: `Gallery.index` only checks login and renders placeholder
- View: Shows "Gallery - Coming soon!" with emoji
- No data model defined

## Requirements

### Data Model (Models.lean)

```lean
-- Gallery attributes
def imageFilename : LedgerAttribute := ...
def imageCaption : LedgerAttribute := ...
def imageUploadDate : LedgerAttribute := ...
def imageTags : LedgerAttribute := ...       -- cardinality many
def imageAlbum : LedgerAttribute := ...      -- ref to album
def albumName : LedgerAttribute := ...
def albumDescription : LedgerAttribute := ...
def albumCover : LedgerAttribute := ...      -- ref to image

structure DbImage where
  id : Nat
  filename : String
  caption : String
  uploadDate : Nat
  tags : List String
  album : Option EntityId
  deriving Repr, BEq

structure DbAlbum where
  id : Nat
  name : String
  description : String
  cover : Option EntityId
  deriving Repr, BEq
```

### Routes to Add

```
GET  /gallery                     → All images grid
GET  /gallery/upload              → Upload form
POST /gallery/image               → Upload image
GET  /gallery/image/:id           → View image (lightbox)
GET  /gallery/image/:id/edit      → Edit metadata form
PUT  /gallery/image/:id           → Update metadata
DELETE /gallery/image/:id         → Delete image
GET  /gallery/album               → List albums
POST /gallery/album               → Create album
GET  /gallery/album/:id           → View album images
PUT  /gallery/album/:id           → Update album
DELETE /gallery/album/:id         → Delete album
GET  /gallery/tag/:tag            → Images by tag
```

### Actions (Actions/Gallery.lean)

- `index`: Grid view of all images
- `uploadForm`: Show upload form
- `uploadImage`: Handle file upload, create metadata
- `showImage`: Lightbox view with details
- `editImage`: Edit caption/tags form
- `updateImage`: Update image metadata
- `deleteImage`: Delete image and file
- `listAlbums`: Show all albums
- `createAlbum`: Create new album
- `showAlbum`: Grid of album images
- `updateAlbum`: Update album info
- `deleteAlbum`: Delete album (images optional)
- `byTag`: Filter images by tag

### Views (Views/Gallery.lean)

- Image grid (responsive)
- Thumbnail component
- Lightbox modal:
  - Full-size image
  - Caption
  - Tags
  - Navigation (prev/next)
  - Edit/delete buttons
- Upload form:
  - File input (multiple)
  - Caption field
  - Tag input
  - Album selector
- Album grid
- Album detail view
- Tag cloud/filter

### File Storage

- Images stored in `data/uploads/` directory
- Thumbnails generated on upload (optional, deferred)
- Filename: `{uuid}_{original_name}`
- Serve via static file middleware

## Acceptance Criteria

- [ ] User can upload images
- [ ] Images have caption, tags, album assignment
- [ ] Responsive grid layout
- [ ] Lightbox for full-size viewing
- [ ] Album organization
- [ ] Tag filtering
- [ ] Image deletion removes file
- [ ] HTMX for smooth interactions
- [ ] Audit logging for uploads/deletes

## Dependencies

- Requires file upload system (see issue #017)
- Static file serving for uploaded images

## Technical Notes

- File upload is a significant feature - may need chunked upload for large files
- Consider max file size limit
- Image validation (check it's actually an image)
- EXIF data extraction (optional, advanced)

## Priority

Low - Requires file upload infrastructure first

## Estimate

Large - File handling + multiple views + lightbox
