/-
  Tests for Cellar File I/O Operations
-/
import Crucible
import Cellar

open Crucible
open Cellar

namespace CellarTests.IO

testSuite "File I/O"

-- Use a unique temp directory for each test run
def testDir : IO String := do
  let ts ← IO.monoNanosNow
  pure s!"/tmp/cellar-test-{ts}"

test "writeFile and readFile roundtrip" := do
  let dir ← testDir
  let path := s!"{dir}/test.bin"
  let data := ByteArray.mk #[1, 2, 3, 4, 5]
  let writeResult ← writeFile path data
  let _ ← shouldBeOk writeResult "writeFile"
  let readResult ← readFile path
  let readData ← shouldBeOk readResult "readFile"
  ensure (readData == data) "read data matches written data"
  -- Cleanup
  let _ ← deleteFile path

test "writeFile creates parent directories" := do
  let dir ← testDir
  let path := s!"{dir}/nested/deep/file.bin"
  let data := ByteArray.mk #[10, 20, 30]
  let result ← writeFile path data
  let _ ← shouldBeOk result "writeFile"
  let filePresent ← fileExists path
  filePresent ≡ true
  -- Cleanup
  let _ ← deleteFile path

test "fileExists returns true for existing file" := do
  let dir ← testDir
  let path := s!"{dir}/exists.bin"
  let _ ← writeFile path (ByteArray.mk #[1])
  let filePresent ← fileExists path
  filePresent ≡ true
  -- Cleanup
  let _ ← deleteFile path

test "fileExists returns false for missing file" := do
  let filePresent ← fileExists "/nonexistent/path/file.bin"
  filePresent ≡ false

test "getFileSize returns correct size" := do
  let dir ← testDir
  let path := s!"{dir}/sized.bin"
  let data := ByteArray.mk #[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  let _ ← writeFile path data
  let result ← getFileSize path
  let size ← shouldBeOk result "getFileSize"
  size ≡ 10
  -- Cleanup
  let _ ← deleteFile path

test "deleteFile removes existing file" := do
  let dir ← testDir
  let path := s!"{dir}/to-delete.bin"
  let _ ← writeFile path (ByteArray.mk #[1])
  let presentBefore ← fileExists path
  presentBefore ≡ true
  let _ ← deleteFile path
  let presentAfter ← fileExists path
  presentAfter ≡ false

test "deleteFile succeeds on missing file" := do
  let result ← deleteFile "/nonexistent/file.bin"
  -- deleteFile is best-effort and ignores errors
  let _ ← shouldBeOk result "deleteFile"

test "readFile returns error for missing file" := do
  let result ← readFile "/nonexistent/path/file.bin"
  match result with
  | .error _ => ensure true "got expected error"
  | .ok _ => throw (IO.userError "expected error for missing file")

test "nowMs returns increasing timestamps" := do
  let t1 ← nowMs
  -- Small delay
  for _ in [:100] do
    let _ ← pure ()
  let t2 ← nowMs
  ensure (t2 >= t1) "timestamps should be non-decreasing"

test "getModTime returns valid timestamp" := do
  let dir ← testDir
  let path := s!"{dir}/modtime.bin"
  let _ ← writeFile path (ByteArray.mk #[1])
  let result ← getModTime path
  let modTime ← shouldBeOk result "getModTime"
  -- Should be a reasonable timestamp (after year 2020)
  ensure (modTime > 1577836800) "modTime should be after 2020"
  -- Cleanup
  let _ ← deleteFile path


end CellarTests.IO
