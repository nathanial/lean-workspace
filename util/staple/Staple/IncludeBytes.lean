/-
  Staple.IncludeBytes - Compile-time binary file embedding

  Usage: `include_bytes% "path/to/file"`

  The file path is relative to the Lean source file.
-/
import Lean

namespace Staple

open Lean Elab Term Meta

/-- Read a binary file at compile time and embed its contents as a ByteArray literal.
    Path is relative to the source file containing the `include_bytes%` call. -/
elab "include_bytes% " path:str : term => do
  let ctx ← readThe Core.Context
  let srcPath := ctx.fileName
  let srcDir := System.FilePath.parent srcPath |>.getD ""
  let filePath := srcDir / path.getString
  let fileExists ← filePath.pathExists
  if !fileExists then
    throwError "include_bytes%: File not found: {filePath}\n  (resolved from \"{path.getString}\" relative to {srcPath})"
  let contents ← IO.FS.readBinFile filePath
  -- Build the ByteArray using quotation (foldlM to preserve order)
  let bytesExpr ← contents.toList.foldlM (init := ← `(#[])) fun acc b => do
    let bLit := Syntax.mkNumLit (toString b.toNat)
    `(($acc).push $bLit)
  elabTerm (← `(ByteArray.mk $bytesExpr)) none

end Staple
