/-
  Ask.Image - Image generation utilities
  Helpers for generating images via Oracle's image generation API.
-/

import Oracle
import Ask.History

namespace Ask.Image

open Oracle

/-- Get the image output directory path (~/.ask/images/) -/
def getImageDir : IO System.FilePath := do
  if let some home ← IO.getEnv "HOME" then
    pure (home ++ "/.ask/images")
  else
    pure ".ask/images"

/-- Ensure the image directory exists -/
def ensureImageDir : IO Unit := do
  let dir ← getImageDir
  IO.FS.createDirAll dir

/-- Default model for image generation -/
def defaultImageModel : String := Models.geminiFlashImage

/-- Check if a model supports image generation -/
def isImageCapableModel (model : String) : Bool :=
  (model.splitOn "image").length > 1 ||
  model == Models.geminiFlashImage ||
  model == Models.geminiProImage

/-- Generate a filename for auto-generated images -/
def generateFilename (model : String) : IO String := do
  let timestamp ← Ask.History.nowSeconds
  let slug := Ask.History.modelToSlug model
  pure s!"{timestamp}-{slug}.png"

/-- Resolve output path: use explicit path if provided, otherwise generate one in ~/.ask/images/ -/
def resolveOutputPath (explicitPath : Option String) (model : String) : IO System.FilePath := do
  match explicitPath with
  | some path =>
    -- If it's a relative path without directory, put in images dir
    if !path.startsWith "/" && !path.contains '/' then
      let dir ← getImageDir
      pure (dir / path)
    else
      pure path
  | none =>
    ensureImageDir
    let dir ← getImageDir
    let filename ← generateFilename model
    pure (dir / filename)

end Ask.Image
